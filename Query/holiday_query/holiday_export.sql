SET SERVEROUTPUT ON
SET VERIFY OFF
SET FEEDBACK OFF
SET LINESIZE 180
SET PAGESIZE 180

-- Start spooling the output to a CSV file
SPOOL "C:\Users\weika\OneDrive\Desktop\Degree Y2S3\Data Warehouse\Assignment\holiday_sales_report.csv"

-- Output headers for CSV
PROMPT Year,Holiday,Sales (RM),Contribution (%)

ACCEPT v_start_year NUMBER PROMPT 'Enter Start Year (YYYY)   : '
ACCEPT v_end_year   NUMBER PROMPT 'Enter End Year (YYYY)     : '

CREATE OR REPLACE VIEW HOLIDAY_SALES_VIEW AS
SELECT 
    d.cal_year AS Year,
    d.festive_event AS Holiday,
    SUM(o.quantity * o.unit_price) AS Sales
FROM 
    Order_Facts o
JOIN 
    Date_dim d ON o.date_key = d.date_key
WHERE 
    d.holiday_ind = 'Y'
GROUP BY 
    d.cal_year, d.festive_event
ORDER BY 
    d.festive_event;

CREATE OR REPLACE VIEW PUBLIC_DAY_SALES_VIEW AS
SELECT 
    d.cal_year AS Year,
    SUM(o.quantity * o.unit_price) AS Sales
FROM 
    Order_Facts o
JOIN 
    Date_dim d ON o.date_key = d.date_key
WHERE 
    d.holiday_ind = 'N'
GROUP BY 
    d.cal_year;


DECLARE
  v_start_year    NUMBER := &v_start_year;
  v_end_year      NUMBER := &v_end_year;
  v_total_sales   NUMBER := 0;
  v_public_sales  NUMBER := 0;
  v_holiday_sales NUMBER := 0;
  v_holiday_count NUMBER := 0;
  v_avg_holiday   NUMBER := 0;
  v_avg_public    NUMBER := 0;

BEGIN
    -- Loop for each year
    FOR current_year IN v_start_year..v_end_year LOOP
        -- Fetch total holiday sales for the year (for calculating contribution percentage)
        SELECT 
            SUM(Sales)
        INTO 
            v_holiday_sales
        FROM 
            HOLIDAY_SALES_VIEW
        WHERE 
            Year = current_year;

        -- Fetch and display holiday sales for each holiday from the view
        FOR holiday_sales_rec IN (
            SELECT 
                Year, Holiday, Sales 
            FROM 
                HOLIDAY_SALES_VIEW 
            WHERE 
                Year = current_year
        ) LOOP
            -- Calculate contribution percentage for each holiday
            DECLARE
                v_contribution NUMBER := (holiday_sales_rec.Sales / v_holiday_sales) * 100;
            BEGIN
                -- Output each holiday sales as CSV
                DBMS_OUTPUT.PUT_LINE(
                    holiday_sales_rec.Year || ',' ||
                    '"' || holiday_sales_rec.Holiday || '",' ||
                    TO_CHAR(holiday_sales_rec.Sales, '999999999.99') || ',' ||
                    TO_CHAR(v_contribution, '999.99') || '%'
                );
            END;

            -- Accumulate holiday count
            v_holiday_count := v_holiday_count + 1;
        END LOOP;

        -- Fetch public day sales for the current year from the view
        SELECT 
            Sales
        INTO 
            v_public_sales
        FROM 
            PUBLIC_DAY_SALES_VIEW
        WHERE 
            Year = current_year;

        -- Calculate total sales for the year
        v_total_sales := v_holiday_sales + v_public_sales;
        v_avg_holiday := (v_holiday_sales / v_holiday_count);
        v_avg_public  := (v_public_sales / (365 - v_holiday_count));

        -- Output total and average sales
        DBMS_OUTPUT.PUT_LINE('Total Holiday Sales,' || TO_CHAR(v_holiday_sales, '999999999.99'));
        DBMS_OUTPUT.PUT_LINE('Public Day Sales,' || TO_CHAR(v_public_sales, '999999999.99'));
        DBMS_OUTPUT.PUT_LINE('Average Holiday Sales,' || TO_CHAR(v_avg_holiday, '999999999.99'));
        DBMS_OUTPUT.PUT_LINE('Average Public Day Sales,' || TO_CHAR(v_avg_public, '999999999.99'));
        DBMS_OUTPUT.PUT_LINE('Difference In Avg (Holiday vs Public),' || TO_CHAR((v_avg_holiday - v_avg_public), '999999999.99'));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('End of Report');
    
END;
/

-- Turn off spooling
SPOOL OFF;
