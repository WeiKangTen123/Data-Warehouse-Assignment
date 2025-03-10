SET SERVEROUTPUT ON
SET VERIFY OFF
SET FEEDBACK OFF
SET LINESIZE 1000
SET PAGESIZE 50000

-- Start spooling to a CSV file
SPOOL "C:\Users\weika\OneDrive\Desktop\Degree Y2S3\Data Warehouse\Assignment\platform_sales_report.csv"

-- Output the CSV headers
PROMPT "Year,Quarter,Platform,Revenue (RM), Contribution, Frequency"

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

    FOR rec IN c_platform_sales LOOP
        -- Output data as CSV (Year, Quarter, Platform, Revenue, Contribution, Frequency)
        DBMS_OUTPUT.PUT_LINE(
            rec.year || ',' ||
            rec.quarter || ',' ||
            rec.platform || ',' ||
            TO_CHAR(rec.revenue, '9999999.99') || ',' ||
            TO_CHAR(rec.contribution, '999.99') || '%,' ||
            rec.frequency
        );

        -- Accumulate total sales per year
        v_total_sales_per_year := v_total_sales_per_year + rec.revenue;

        -- Track yearly highest and lowest sales
        IF rec.total_revenue_per_year > v_yearly_highest_revenue THEN
            v_yearly_highest_revenue := rec.total_revenue_per_year;
            v_yearly_highest_sales := rec.platform || ' RM ' || TO_CHAR(rec.total_revenue_per_year, '9999999.99');
        END IF;

        IF v_yearly_lowest_revenue IS NULL OR rec.total_revenue_per_year < v_yearly_lowest_revenue THEN
            v_yearly_lowest_revenue := rec.total_revenue_per_year;
            v_yearly_lowest_sales := rec.platform || ' RM ' || TO_CHAR(rec.total_revenue_per_year, '9999999.99');
        END IF;
    END LOOP;

END;
/

-- Stop spooling
SPOOL OFF;
