SET SERVEROUTPUT ON
SET VERIFY OFF
SET FEEDBACK OFF
SET LINESIZE 180
SET PAGESIZE 180

PROMPT
PROMPT
PROMPT ~ Platform Sales Report ~

DECLARE
    start_year CHAR(4);
    end_year CHAR(4);
    
    CURSOR c_platform_sales IS
        WITH platform_sales AS (
            SELECT 
                dd.cal_year AS year,
                dd.cal_quarter AS quarter,
                pd.PlatformName AS platform,
                SUM(o.quantity * o.unit_price) AS revenue,
                COUNT(CASE WHEN pd.PlatformName != 'In Stall' THEN o.orderID END) AS frequency -- Count only delivery orders
            FROM 
                Order_Facts o
            JOIN 
                Platform_dim pd ON o.Platform_key = pd.Platform_key
            JOIN
                Date_dim dd ON o.Date_key = dd.Date_key
            WHERE 
                pd.PlatformName != 'In Stall'
                AND dd.cal_year BETWEEN start_year AND end_year
            GROUP BY 
                dd.cal_year,
                dd.cal_quarter,
                pd.PlatformName
        ),
        yearly_sums AS (
            SELECT 
                year,
                platform,
                SUM(revenue) AS total_revenue_per_year
            FROM 
                platform_sales
            GROUP BY 
                year, platform
        ),
        quarterly_sums AS (
            SELECT 
                year,
                quarter,
                SUM(revenue) AS sum_of_revenue
            FROM 
                platform_sales
            GROUP BY 
                year, quarter
        )
        SELECT 
            ps.year,
            ps.quarter,
            ps.platform,
            ps.revenue,
            ps.frequency, -- Include frequency in the final result
            ROUND((ps.revenue / qs.sum_of_revenue) * 100, 2) AS contribution,
            qs.sum_of_revenue,
            ys.total_revenue_per_year, -- Add yearly total revenue for platform
            ROW_NUMBER() OVER (PARTITION BY ps.year, ps.quarter ORDER BY ps.revenue DESC) AS rn,
            COUNT(*) OVER (PARTITION BY ps.year, ps.quarter) AS total_platforms
        FROM 
            platform_sales ps
        JOIN 
            quarterly_sums qs ON ps.year = qs.year AND ps.quarter = qs.quarter
        JOIN
            yearly_sums ys ON ps.year = ys.year AND ps.platform = ys.platform
        ORDER BY 
            ps.year ASC, 
            ps.quarter ASC, 
            ps.revenue DESC;

    v_highest_sales VARCHAR2(100);
    v_lowest_sales VARCHAR2(100);
    v_highest_revenue NUMBER := 0;
    v_lowest_revenue NUMBER := 0;
    v_difference NUMBER := 0;
    v_yearly_highest_sales VARCHAR2(100); -- To store highest yearly platform sales
    v_yearly_lowest_sales VARCHAR2(100);  -- To store lowest yearly platform sales
    v_yearly_highest_revenue NUMBER := 0;
    v_yearly_lowest_revenue NUMBER := NULL;
    v_previous_year VARCHAR2(4);
    v_total_sales_per_year NUMBER := 0;

BEGIN
    -- Prompt for start and end year
    start_year := '&start_year';
    end_year := '&end_year';
    
    v_previous_year := NULL; 
    v_total_sales_per_year := 0; 

    DBMS_OUTPUT.PUT_LINE(CHR(13));
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Platform Sales Report');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(CHR(13));
    
    FOR rec IN c_platform_sales LOOP
        -- New year -> Show header
        IF v_previous_year IS NULL OR rec.year != v_previous_year THEN
            IF v_previous_year IS NOT NULL THEN
                -- Display total sales and separator for the previous year
                dbms_output.put_line('---------------------------------------------------------------------');
                dbms_output.put_line('| Total Sales for Year ' || v_previous_year || ' : RM ' || TO_CHAR(v_total_sales_per_year, '999,999,999.00') || RPAD(' ',20) || '|');
                dbms_output.put_line('---------------------------------------------------------------------');
                dbms_output.put_line('| Highest Sales: ' || v_yearly_highest_sales || RPAD(' ',22) || '|');
                dbms_output.put_line('| Lowest Sales:  ' || v_yearly_lowest_sales || RPAD(' ',22) || '|');
                dbms_output.put_line('| Difference: RM ' || TO_CHAR(v_yearly_highest_revenue - v_yearly_lowest_revenue, '999,999,999.00') || RPAD(' ',36) || '|');
                dbms_output.put_line('---------------------------------------------------------------------');
                v_total_sales_per_year := 0;  -- Reset total for the new year
            END IF;

            -- Start the new year section
            DBMS_OUTPUT.PUT_LINE(CHR(13));
            dbms_output.put_line('Year: ' || rec.year);
            dbms_output.put_line('---------------------------------------------------------------------');
            dbms_output.put_line('| Quarter | Platform   |       Revenue   | Contribution | Frequency |');
            dbms_output.put_line('---------------------------------------------------------------------');

            -- Reset yearly highest and lowest values
            v_yearly_highest_revenue := 0;
            v_yearly_lowest_revenue := NULL;
            v_yearly_highest_sales := NULL;
            v_yearly_lowest_sales := NULL;
            v_previous_year := rec.year;
        END IF;

        -- Display the platform's data for the current quarter
        dbms_output.put_line('| ' || CASE WHEN rec.rn = 1 THEN 'Q' || rec.quarter ELSE '   ' END || 
                            '     | ' || RPAD(rec.platform, 10) || ' | ' || 
                            TO_CHAR(rec.revenue, '999,999,999.00') || ' | ' || 
                            RPAD(TO_CHAR(rec.contribution, '999.99') || '%', 12) || ' | ' ||
                            RPAD(TO_CHAR(rec.frequency, '999,999'), 9) || ' | ');

        -- Accumulate total sales per quarter and year
        v_total_sales_per_year := v_total_sales_per_year + rec.revenue;

        -- Track yearly highest and lowest sales
        IF rec.total_revenue_per_year > v_yearly_highest_revenue THEN
            v_yearly_highest_revenue := rec.total_revenue_per_year;
            v_yearly_highest_sales := RPAD(rec.platform, 10) || ' RM ' || TO_CHAR(rec.total_revenue_per_year, '999,999,999.00');
        END IF;

        IF v_yearly_lowest_revenue IS NULL OR rec.total_revenue_per_year < v_yearly_lowest_revenue THEN
            v_yearly_lowest_revenue := rec.total_revenue_per_year;
            v_yearly_lowest_sales := RPAD(rec.platform, 10) || ' RM ' || TO_CHAR(rec.total_revenue_per_year, '999,999,999.00');
        END IF;
    END LOOP;

    -- Display total sales for the last year after the loop ends
    IF v_previous_year IS NOT NULL THEN
        dbms_output.put_line('---------------------------------------------------------------------');
        dbms_output.put_line('| Total Sales for Year ' || v_previous_year || ' : RM ' || TO_CHAR(v_total_sales_per_year, '999,999,999.00') || RPAD(' ',20) || '|');
        dbms_output.put_line('---------------------------------------------------------------------');
        dbms_output.put_line('| Highest Sales: ' || v_yearly_highest_sales || RPAD(' ',22) || '|');
        dbms_output.put_line('| Lowest Sales:  ' || v_yearly_lowest_sales || RPAD(' ',22) || '|');
        dbms_output.put_line('| Difference: RM ' || TO_CHAR(v_yearly_highest_revenue - v_yearly_lowest_revenue, '999,999,999.00') || RPAD(' ',36) || '|');
        dbms_output.put_line('---------------------------------------------------------------------');
    END IF;


    DBMS_OUTPUT.PUT_LINE(CHR(13));
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('End of Report');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(CHR(13));
    DBMS_OUTPUT.PUT_LINE(CHR(13));

END;
/