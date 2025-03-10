SET SERVEROUTPUT ON;
SET VERIFY off;
SET FEEDBACK off;
SET LINESIZE 150;
SET PAGESIZE 120;

PROMPT
PROMPT
PROMPT ~ Sales Growth Report ~

-- Create or replace the procedure for revenue growth
CREATE OR REPLACE PROCEDURE revenue_growth (start_year NUMBER, end_year NUMBER) AS
  CURSOR c_revenue IS
    WITH cte_revenue_data AS (
      SELECT 
        D.cal_year AS Year,
        D.cal_quarter AS Quarter,
        SUM(O.quantity * O.unit_price) AS Current_Revenue
      FROM Order_Facts O
      JOIN Date_dim D ON O.Date_key = D.Date_key
      WHERE D.cal_year BETWEEN start_year AND end_year
      GROUP BY D.cal_year, D.cal_quarter
      ORDER BY D.cal_year, D.cal_quarter
    ),
    formatted_data AS (
      SELECT 
        Year,
        Quarter,
        Current_Revenue,
        LAG(Current_Revenue) OVER (PARTITION BY Year ORDER BY Quarter) AS Previous_Revenue,
        ROUND(Current_Revenue - LAG(Current_Revenue) OVER (PARTITION BY Year ORDER BY Quarter), 2) AS Difference,
        CASE 
          WHEN LAG(Current_Revenue) OVER (PARTITION BY Year ORDER BY Quarter) IS NOT NULL THEN
            ROUND(((Current_Revenue - LAG(Current_Revenue) OVER (PARTITION BY Year ORDER BY Quarter)) / 
                  LAG(Current_Revenue) OVER (PARTITION BY Year ORDER BY Quarter)) * 100, 2)
          ELSE NULL
        END AS Revenue_Growth_Percentage
      FROM cte_revenue_data
    )
    SELECT Year, Quarter, Current_Revenue, Previous_Revenue, Difference, Revenue_Growth_Percentage
    FROM formatted_data;

  v_year NUMBER := NULL;
  v_curr_rev NUMBER;
  v_prev_rev NUMBER;
  v_diff NUMBER;
  v_growth_pct NUMBER;
  
  v_tot_rev NUMBER := 0;
  v_tot_growth NUMBER := 0;
  v_count_growth NUMBER := 0;
  
  v_overall_tot_rev NUMBER := 0;
  v_overall_growth NUMBER := 0;
  v_overall_count NUMBER := 0;

  TYPE Yearly_Sales IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  yearly_totals Yearly_Sales;

BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(13));
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Sales Growth Report');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(CHR(13));

  FOR rec IN c_revenue LOOP
    -- Check if the year has changed
    IF v_year IS NULL OR v_year != rec.Year THEN
      -- Output totals for the previous year
      IF v_year IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('| Total revenue for year ' || v_year || ' : ' || RPAD(TO_CHAR(v_tot_rev, 'FM999G999G999D00'), 54) || ' |');
        IF yearly_totals.EXISTS(v_year - 1) THEN
          v_growth_pct := ((v_tot_rev - yearly_totals(v_year - 1)) / yearly_totals(v_year - 1)) * 100;
          DBMS_OUTPUT.PUT_LINE('| Total revenue growth percentage for year: ' || RPAD(ROUND(v_growth_pct, 2) || '%', 42) || ' |');
        ELSE
          DBMS_OUTPUT.PUT_LINE('| Total revenue growth percentage for year: N/A' || RPAD(' ', 39) || ' |');
        END IF;
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------');
        
        -- Store yearly totals for final comparison
        yearly_totals(v_year) := v_tot_rev;
      END IF;

      -- Reset year-specific totals
      v_tot_rev := 0;
      v_tot_growth := 0;
      v_count_growth := 0;

      -- Set the new year
      v_year := rec.Year;
      DBMS_OUTPUT.PUT_LINE(CHR(13));
      DBMS_OUTPUT.PUT_LINE('Year: ' || v_year);

      DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('| Quarter   |   Current Sales    |   Previous Sales  |    Difference     |   Growth %  |');
      DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------');
    END IF;

    -- Output quarterly data
    DBMS_OUTPUT.PUT_LINE('|   Q' || rec.Quarter || '      | ' || RPAD(TO_CHAR(rec.Current_Revenue, 'FM999G999G999D00'), 17) || ' | ' || 
                      RPAD(NVL(TO_CHAR(rec.Previous_Revenue, 'FM999G999G999D00'), '-'), 17) || ' | ' || 
                      RPAD(NVL(TO_CHAR(rec.Difference, 'FM999G999G999D00'), '-'), 17) || ' | ' || 
                      RPAD(NVL(TO_CHAR(rec.Revenue_Growth_Percentage, 'FM999D00'), '-'), 7) || '%    |');
    
    -- Update totals
    v_tot_rev := v_tot_rev + rec.Current_Revenue;
  END LOOP;

  -- Output totals for the last year
  IF v_year IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('| Total revenue for year ' || v_year || ' : ' || RPAD(TO_CHAR(v_tot_rev, 'FM999G999G999D00'), 54) || ' |');
    IF yearly_totals.EXISTS(v_year - 1) THEN
      v_growth_pct := ((v_tot_rev - yearly_totals(v_year - 1)) / yearly_totals(v_year - 1)) * 100;
      DBMS_OUTPUT.PUT_LINE('| Total revenue growth percentage for year: ' || RPAD(ROUND(v_growth_pct, 2) || '%', 42) || ' |');
    ELSE
      DBMS_OUTPUT.PUT_LINE('| Total revenue growth percentage for year: N/A' || RPAD(' ', 39) || ' |');
    END IF;
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------');
    
    -- Store yearly totals for final comparison
    yearly_totals(v_year) := v_tot_rev;
  END IF;

  -- Output overall summary: Comparison by Year
  DBMS_OUTPUT.PUT_LINE(CHR(13));
  DBMS_OUTPUT.PUT_LINE('Yearly Sales Comparison');

  DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('| Year     |    Total Sales      |  Growth from Previous Year |');
  DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');

  -- Iterate through yearly totals and print the comparison
  FOR i IN yearly_totals.FIRST..yearly_totals.LAST LOOP
    IF yearly_totals.EXISTS(i) THEN
      IF yearly_totals.EXISTS(i - 1) THEN
        DBMS_OUTPUT.PUT_LINE('| ' || i || '     | ' || RPAD(TO_CHAR(yearly_totals(i), 'FM999G999G999D00'), 19) || ' | ' || 
                          RPAD(ROUND(((yearly_totals(i) - yearly_totals(i - 1)) / yearly_totals(i - 1)) * 100, 2) || '%', 26) || ' |');
      ELSE
        DBMS_OUTPUT.PUT_LINE('| ' || i || '     | ' || RPAD(TO_CHAR(yearly_totals(i), 'FM999G999G999D00'), 19) || ' | ' || 
                          RPAD('N/A', 26) || ' |');
      END IF;
    END IF;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------');

  DBMS_OUTPUT.PUT_LINE(CHR(13));
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('End of Report');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(CHR(13));
    DBMS_OUTPUT.PUT_LINE(CHR(13));

END;
/

-- Execute the procedure
DECLARE
  v_start_year NUMBER;
  v_end_year NUMBER;
BEGIN
  -- Accept user input
  v_start_year := &start_year;
  v_end_year := &end_year;

  -- Call the procedure
  revenue_growth(v_start_year, v_end_year);
END;
/
