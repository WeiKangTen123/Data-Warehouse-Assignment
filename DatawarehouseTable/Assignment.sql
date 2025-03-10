-- Information / Business Rule
-- ======================================
-- 10 years data from (1/1/2013) to (31/12/2023)
-- 40 tenants, each year will have 1 or 2 tenant resign


-- TABLE USED FOR DATA WAREHOUSE
-- ======================================
-- Tenants
-- contract
-- menu
-- stall
-- orders
-- delivery
-- platform
-- customers    
-- orderdetails

-- =====================================
-- |     Table created check list      |
-- =====================================
-- Tenants                      | /  |
-- contract                     | /  |
-- menu                         | /  |
-- stall                        | /  |
-- orders                       | /  |
-- delivery                     | /  |
-- platform                     | /  |
-- customers                    | /  |
-- orderdetails                 | /  |
-- =====================================

-- sequence pf create table
-- =====================================
-- Tenants
-- platform
-- customers
-- delivery
-- orders
-- menu

-- tenants
-- stall    
-- contract
-- =====================================


-- Update format
-- =======================================
COLUMN CUSTEMAIL FORMAT A35


-- IMPORTANT!!!!!!!!!
-- ======================================
-- After duplicate data must commit
  commit;


-- VERIFY WHICH SYSTEM CAN BE USE
SELECT FILE_NAME 
FROM DBA_DATA_FILES 
WHERE TABLESPACE_NAME = 'SYSTEM';

-- ADD system resource
ALTER TABLESPACE SYSTEM
ADD DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE\SYSTEM02.DBF' SIZE 700M;

-- SET THE SYSTEM RESOURCE TO UNLIMITED
ALTER DATABASE DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE\SYSTEM02.DBF'
AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED;

-- SET SYSTEM UNDO RESOURCE TO UNLIMITED
ALTER TABLESPACE UNDOTBS1 
ADD DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\undotbs1_02.dbf' 
SIZE 1024M 
AUTOEXTEND ON 
NEXT 100M 
MAXSIZE UNLIMITED;









-- ======================================================
-- |                    ASSIGNMENT                      |
-- ======================================================


-- ======================================================
-- |                    BASE TABLE                      |
-- ======================================================

-- ==========================================
-- Step 1 create table and duplicate data 
-- ==========================================
-- New Customer table (Approximate 100k data)
Drop table new_cust;
create table new_cust(
  CUSTID number NOT NULL,
  CUSTNAME varchar(20) NOT NULL,
  CUSTPHONE varchar(12) not null,
  CUSTEMAIL varchar(35) not null,
  CUSTBIRTHDATE date,
  CUSTGENDER char(1),
  constraint PK_CUSTID primary key  (CUSTID)
);

  -- sequence
drop sequence CUST_SEQ;
create sequence CUST_SEQ
start with 100001
increment by 1;

  -- insert base value
insert into new_cust
select CUST_SEQ.NEXTVAL, customerName, customerPhone,customerEmail,null,null
from customers;

  -- duplicate new_cust value
INSERT INTO new_cust (CUSTID, CUSTNAME, CUSTPHONE, CUSTEMAIL, CUSTBIRTHDATE, CUSTGENDER)
SELECT 
    CUST_SEQ.NEXTVAL, 
    CUSTNAME, 
    LPAD(TRUNC(DBMS_RANDOM.VALUE(10, 19)), 3, '0') || '-' || 
    LPAD(TRUNC(DBMS_RANDOM.VALUE(100,999)),3,'0') || '-' ||
    LPAD(TRUNC(DBMS_RANDOM.VALUE(1000,9999)),4,'0') AS CUSTPHONE,
    CUSTEMAIL, 
    CUSTBIRTHDATE, 
    CUSTGENDER
FROM 
    new_cust;


--   -- insert birth and gender data into new_cust (先不要用)
-- DECLARE
--   CURSOR cust_cursor IS
--     SELECT CUSTID
--     FROM new_cust
--     WHERE CUSTBIRTHDATE IS NULL; -- Only update records with NULL birthdate

--   v_custID        new_cust.CUSTID%TYPE;
--   v_custBirthDate DATE;
--   v_custGender    CHAR(1);
--   counter         NUMBER := 0;
--   v_randomValue   NUMBER;
--   v_dateRange      NUMBER := TO_DATE('31-12-2005', 'DD-MM-YYYY') - TO_DATE('01-01-1940', 'DD-MM-YYYY');
  
--   bias_exponent NUMBER:= 0.8;

-- BEGIN
--   FOR cust_rec IN cust_cursor LOOP
--     v_custID := cust_rec.CUSTID;

--     v_randomValue := POWER(DBMS_RANDOM.VALUE(0, 1), bias_exponent);

--     -- Generate random birthdate between 1940 and 2005
--     v_custBirthDate := TO_DATE('01-01-1940', 'DD-MM-YYYY') + TRUNC(v_randomValue * v_dateRange);

--     v_randomValue:=dbms_random.VALUE(0,1);

--     -- Determine gender based on modulus operation
--     IF v_randomValue <= 0.6 THEN
--       v_custGender := 'F';
--     ELSE
--       v_custGender := 'M';
--     END IF;

--     -- Update the record in new_cust table
--     UPDATE new_cust
--     SET CUSTBIRTHDATE = v_custBirthDate,
--         CUSTGENDER = v_custGender
--     WHERE CUSTID = v_custID;

--     -- Increment counter for each update
--     counter := counter + 1;
--   END LOOP;

--   -- Output the number of customers updated
--   DBMS_OUTPUT.PUT_LINE(counter || ' customers updated in new_cust table.');
-- END;
-- /


  -- Default
INSERT INTO new_cust (CUSTID, CUSTNAME, CUSTPHONE, CUSTEMAIL, CUSTBIRTHDATE, CUSTGENDER)
Values(-1,'-----','-----','------',TO_DATE('15-09-1990', 'DD-MM-YYYY'),'-');



  -- count value (total customer row)
SELECT COUNT(*) AS total_rows
FROM new_cust;

-- count value (total male and female)
SELECT CUSTGENDER, COUNT(*) AS total
FROM new_cust
GROUP BY CUSTGENDER;

-- age range frequency
SELECT age, COUNT(*) AS frequency
FROM (
    SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, CUSTBIRTHDATE) / 12) AS age
    FROM new_cust
    WHERE CUSTBIRTHDATE IS NOT NULL
)
GROUP BY age
ORDER BY age;

-- value needed
--   COUNT(*)
-- ----------
--     331776

-- Incase data not relevant to format
DELETE FROM new_cust;


-- ===============================================================================================
-- new_platform
drop table new_platform;
create table new_platform (
  platformID varchar(5) not null,
  platformName varchar(10) not null,
  platformContact varchar(12) NOT NULL,
  platformEmail varchar(35) not null,
  constraint PK_platformID primary key  (platformID)
);

  -- sequence
drop sequence platform_id_seq;
create sequence platform_id_seq
start with 1001
increment by 1;


  -- insert data 
  -- GRAB
INSERT INTO new_platform(platformID, platformName, platformContact, platformEmail)
VALUES ('G'||platform_id_seq.nextval, 'GRAB', '012-345-6782', 'grab@gmail.com');

  -- FOODPANDA
INSERT INTO new_platform(platformID, platformName, platformContact, platformEmail)
VALUES ('F'||platform_id_seq.nextval, 'FOODPANDA', '013-776-9881', 'foodpanda@gmail.com');

  -- SHOPEEFOOD
INSERT INTO new_platform(platformID, platformName, platformContact, platformEmail)
VALUES ('S'||platform_id_seq.nextval, 'SHOPEEFOOD', '011-103-2231', 'shopee@gmail.com');

  -- In stall
INSERT INTO new_platform(platformID, platformName, platformContact, platformEmail)
VALUES ('9999', 'In Stall', '-------', '-------');


-- ===============================================================================================
-- new_tenants (require 40 data)
drop table new_tenants;
create table new_tenants(
  tenantID varchar(4) not null,
  tenantPerson varchar(20) not null,
  tenantEmail varchar(35) NOT NULL,
  tenantPhone varchar(12) NOT NULL, 
  tenantBirthDate date,
  constraint PK_tenantID primary key  (tenantID)
);


  -- sequence
drop sequence tenants_seq;
create sequence tenants_seq
start with 101
increment by 1;


  -- insert data
DECLARE
  v_tenantID    varchar(4);
  v_personName  varchar(20);

  TYPE name_array IS VARRAY(20) OF VARCHAR2(20);
  first_names name_array := name_array(
    'John', 'Alice', 'Bob', 'Emma', 'Michael', 
    'Sophia', 'David', 'Olivia', 'Ethan', 'Isabella',
    'James', 'Mia', 'Alexander', 'Charlotte', 'William',
    'Ava', 'Benjamin', 'Amelia', 'Daniel', 'Sophia'
  );
  last_names name_array := name_array(
    'Doe', 'Smith', 'Johnson', 'Brown', 'Lee', 
    'Wang', 'Martinez', 'Kim', 'Garcia', 'Rodriguez',
    'Nguyen', 'Patel', 'Wilson', 'Gupta', 'Lee',
    'Johnson', 'Jones', 'Smith', 'Kim', 'Brown'
    );

  v_tenantEmail varchar(35);
  v_tenantPhone varchar(12);
  v_tenantBirthDate date;
  counter number :=1;

  begin
    while(counter<=40) LOOP
      v_tenantID:= 'T' || tenants_seq.NEXTVAL;
      v_personName:= first_names(TRUNC(DBMS_RANDOM.VALUE(1,21))) || ' ' || last_names(TRUNC(DBMS_RANDOM.VALUE(1,21)));
      -- v_tenantEmail:= LOWER(v_personName) || '@gmail.com';
      v_tenantEmail := LOWER(SUBSTR(first_names(TRUNC(DBMS_RANDOM.VALUE(1, 21))), 1, 1) || last_names(TRUNC(DBMS_RANDOM.VALUE(1, 21)))) || '@gmail.com';
      v_tenantBirthDate := TO_DATE('01-01-1950', 'DD-MM-YYYY') + TRUNC(DBMS_RANDOM.VALUE(0, 18628));
      v_tenantPhone:= LPAD(TRUNC(DBMS_RANDOM.VALUE(10, 19)), 3, '0') || '-' || 
                      LPAD(TRUNC(DBMS_RANDOM.VALUE(100, 999)), 3, '0') || '-' ||
                      LPAD(TRUNC(DBMS_RANDOM.VALUE(1000, 9999)), 4, '0');

      INSERT INTO new_tenants (tenantID, tenantPerson, tenantEmail, tenantPhone, tenantBirthDate)
      VALUES (v_tenantID, v_personName, v_tenantEmail, v_tenantPhone, v_tenantBirthDate);
      counter := counter + 1;
    end loop;
  end;
/


-- Date of Birth
SELECT TO_DATE('31-12-2000', 'DD-MM-YYYY') - TO_DATE('01-01-1950', 'DD-MM-YYYY') AS days_between FROM dual;
-- DAYS_BETWEEN
-- ------------
--        18627


-- age group frequency
SELECT age, COUNT(*) AS frequency
FROM (
    SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, tenantBirthDate) / 12) AS age
    FROM new_tenants
    WHERE tenantBirthDate IS NOT NULL
)
GROUP BY age
ORDER BY age;

-- ====================================================================================================================
-- Stall

-- tempepory table for renew data
create table temp_stall(
 stallId varchar(4) NOT NULL,
 stallSize varchar(35) NOT NULL,
 stallType varchar(35) NOT NULL,
 Availability varchar(1) NOT NULL,
 PRIMARY KEY(stallId)
);

-- @insert_stall.txt
-- from adbms


-- use for assignment
drop table new_stall;
create table new_stall(
  stallID varchar(4) NOT NULL,
  stallSize varchar(35) NOT NULL,
  stallType varchar(35) NOT NULL,
  constraint PK_stallID primary key  (stallID)
);

-- sequence
drop sequence new_stall_seq;
create sequence new_stall_seq
start with 101
increment by 1;

-- insert data
insert into new_stall
select 'S'||new_stall_seq.NEXTVAL, stallSize, STALLTYPE
from temp_stall;


-- =====================================================================================================================
-- Menu

-- tempepory table for renew data
drop table temp_menu;
create table temp_menu(
 menuID varchar(4) NOT NULL,
 FoodNDrink varchar(25) NOT NULL,
 ItemDesc varchar(100) NOT NULL,
 ItemPrice number(5,2) NOT NULL,
 AveRating number(4,2),
 stallId varchar(4) NOT NULL,
 PRIMARY KEY(menuID),
 FOREIGN KEY (stallId) REFERENCES new_stall(stallId)
);

-- @insert_menu.txt
-- from adbms

-- assignment
drop table new_menu;
CREATE TABLE new_menu (
  menuID varchar(4) NOT NULL,
  foodNDrink varchar(25),
  ItemDesc varchar(100),
  ItemPrice number(5,2),
  stallID varchar(4),
  CONSTRAINT PK_menuID PRIMARY KEY (menuID),
  CONSTRAINT FK_stallID FOREIGN KEY (stallID) REFERENCES new_stall(stallID)
);


-- sequence
drop sequence new_menu_seq;
create sequence new_menu_seq
start with 001
increment by 1;

-- copy data from the temp_menu
INSERT INTO new_menu
SELECT 'M' || TO_CHAR(new_menu_seq.NEXTVAL, 'FM000'), foodNDrink, ItemDesc, ItemPrice, stallID
FROM temp_menu;


-- =====================================================================================================================
-- Delivery

drop table new_delivery;
create table new_delivery (
  deliveryID number NOT NULL,
  driverName varchar(20),
  driverContact varchar(12),
  pickupTime  varchar(10),
  arrivedTime  varchar(10),
  deliveryCost number(4,2),
  deliveryAddress varchar(50),
  platformID  varchar(5),
  CONSTRAINT PK_deliveryID PRIMARY KEY (deliveryID),
  CONSTRAINT FK_platformID FOREIGN KEY (platformID) REFERENCES new_platform(platformID)
);


-- sequence
drop sequence new_delivery_seq;
create sequence new_delivery_seq
start with 100001
increment by 1;

-- Insert valid data into new_delivery
insert into new_delivery (deliveryID, driverName, driverContact,deliveryAddress)
select new_delivery_seq.NEXTVAL, drivername, drivercontract, deliveryAddress
from delivery;

-- duplicate data
insert into new_delivery (deliveryID, driverName, driverContact,deliveryAddress)
select new_delivery_seq.NEXTVAL, drivername, drivercontact, deliveryAddress
from new_delivery;

-- delete row (i need 1096630 row only)
  -- first method to delete
DELETE FROM new_delivery
WHERE deliveryID IN (
  SELECT deliveryID
  FROM (
    SELECT deliveryID, ROWNUM AS rn
    FROM (
      SELECT deliveryID
      FROM new_delivery
      ORDER BY deliveryID -- Ensure consistent ordering, adjust this column as necessary
    )
  )
  WHERE rn > 1096630
);
  -- second method to delete
DELETE FROM new_delivery
WHERE deliveryID IN (
    SELECT deliveryID
    FROM new_delivery
    WHERE ROWNUM <= (SELECT COUNT(*) FROM new_delivery) - 1096630
);




-- generate new data
declare
  cursor delivery_cursor IS
    select deliveryID 
    from new_delivery
    where pickuptime iS null
      AND arrivedTime IS NULL
      AND deliveryCost IS NULL
      AND platformID IS NULL;

    v_deliveryID   new_delivery.deliveryID%TYPE;
    v_pickupTime   VARCHAR2(10);
    v_arrivedTime  VARCHAR2(10);
    v_deliveryCost NUMBER(4,2);
    v_platformID   VARCHAR2(5);
    counter          NUMBER := 0;
    random_hour      NUMBER;
    random_minute    NUMBER;
    random_second    NUMBER;
    random_minutes_offset NUMBER;
    random_second_offset NUMBER;
BEGIN
  FOR delivery_rec IN delivery_cursor LOOP
    v_deliveryID := delivery_rec.deliveryID;

    v_deliveryCost := DBMS_RANDOM.VALUE(3,12);
    random_hour:=TRUNC(DBMS_RANDOM.VALUE(10,20));
    random_minute := TRUNC(DBMS_RANDOM.VALUE(0, 60));
    random_second := TRUNC(DBMS_RANDOM.VALUE(0, 60));

    v_pickupTime := LPAD(random_hour, 2, '0') || ':' ||
                    LPAD(random_minute, 2, '0') || ':' ||
                    LPAD(random_second, 2, '0');

    -- Generate random arrived time within 1 hour after the pickup time
    random_minutes_offset := TRUNC(DBMS_RANDOM.VALUE(25, 60));
    random_second_offset := TRUNC(DBMS_RANDOM.VALUE(0, 60));

    random_minute := random_minute + random_minutes_offset;
    random_second := random_second + random_second_offset;

    IF random_second >= 60 THEN
      random_second := random_second - 60;
      random_minute := random_minute + 1;
    END IF;

    -- Adjust if minutes exceed 60
    IF random_minute >= 60 THEN
      random_minute := random_minute - 60;
      random_hour := random_hour + 1;
    END IF;

    -- Format the arrived time
    v_arrivedTime := LPAD(random_hour, 2, '0') || ':' ||
                     LPAD(random_minute, 2, '0') || ':' ||
                     LPAD(random_second, 2, '0');

    SELECT platformID 
    INTO v_platformID
    FROM (
      SELECT platformID 
      FROM new_platform
      ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE ROWNUM = 1;

    -- Update the record in the new_delivery table
    UPDATE new_delivery
    SET pickupTime = v_pickupTime,
        arrivedTime = v_arrivedTime,
        deliveryCost = v_deliveryCost,
        platformID = v_platformID
    WHERE deliveryID = v_deliveryID;

    -- Increment counter for each update
    counter := counter + 1;
  END LOOP;

  -- Output the number of deliveries updated
  DBMS_OUTPUT.PUT_LINE(counter || ' deliveries updated in new_delivery table.');
END;
/


  -- default value
INSERT INTO new_delivery(deliveryID, driverName, driverContact,pickupTime,arrivedTime,deliveryCost,deliveryAddress,platformID)
VALUES (-1, '--------', '-------', '-------','-------',00.00,'------','9999');



select count(*) AS total_row
from new_delivery;

-- Value need for DELIVERY
-- Total Delivery Orders: 1096630

-- Testing usage
-- ================================
create table temp_delivery as
select * from delivery;

insert into temp_delivery 
select * from temp_delivery;
-- ================================


select to_char(to_date('01/01/2024','dd/mm/yyyy')*0.01,'hi:mi:ss')
from dual;

-- =====================================================================================================================
-- Orders

drop table new_orders;
create table new_orders (
  orderID number not null,
  orderdate date,
  dineInNumber number,
  rating    number,
  deliveryID number,
  customerID number,
  CONSTRAINT PK_orderID PRIMARY KEY (orderID),
  CONSTRAINT FK_deliveryID FOREIGN KEY (deliveryID) REFERENCES new_delivery(deliveryID),
  CONSTRAINT FK_customerID FOREIGN KEY (customerID) REFERENCES new_cust(custID)
);


-- sequence
drop sequence new_orders_seq;
create sequence new_orders_seq
start with 1000001
increment by 1;

-- deliveryID exp: 100205
-- custID exp: 100145
-- cust start with 100001 and end with 331776

drop sequence newOrderDelivery_seq;
create sequence newOrderDelivery_seq
start with 100001
increment by 1;


declare
  v_orderID number;
  startDate date := to_date('01/01/2014','dd/mm/yyyy');
  endDate date := to_date('31/12/2023','dd/mm/yyyy');
  v_orderDate date;
  v_dineInNumber number;
  v_rating number;
  v_deliveryID number;
  v_customerID number;
  counter number :=0;
  v_random_number number;
  totalOrders number;
  dineIn_count NUMBER := 0;
  delivery_count NUMBER := 0;
  valid_custID NUMBER;

BEGIN
  while(startDate<=endDate) LOOP
    v_orderDate := startDate;
    totalOrders := 700 + TRUNC(DBMS_RANDOM.VALUE(0,101));

    for i in 1..totalOrders LOOP
      v_orderID:= new_orders_seq.NEXTVAL;
      v_rating := TRUNC(DBMS_RANDOM.VALUE(1,6));
      v_random_number := DBMS_RANDOM.VALUE(0, 1);
      
      if v_random_number > 0.6 THEN
        v_deliveryID:= newOrderDelivery_seq.NEXTVAL;
        LOOP
          v_customerID := TRUNC(DBMS_RANDOM.VALUE(100001, 331776));
          
          BEGIN
            -- Check if the custID exists
            SELECT COUNT(*)
            INTO valid_custID
            FROM new_cust
            WHERE custID = v_customerID;

            EXIT WHEN valid_custID > 0; -- Found a valid custID
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              -- Continue looping if the custID does not exist
              NULL;
          END;
        END LOOP;


        v_dineInNumber := null;
        delivery_count := delivery_count + 1;
      ELSE
        v_dineInNumber := 999;
        v_deliveryID := null;
        v_customerID := null;
        dineIn_count := dineIn_count + 1;
      end if;

      insert into new_orders (orderID, orderDate, dineInNumber, rating, deliveryID, customerID)
      values (v_orderID,v_orderDate,v_dineInNumber,v_rating,v_deliveryID,v_customerID);

      counter := counter + 1;
    end loop;

    startDate:=startDate+1;
  end loop;
  DBMS_OUTPUT.PUT_LINE(counter || ' orders inserted.');
  DBMS_OUTPUT.PUT_LINE('Total Delivery Orders: ' || delivery_count);
  DBMS_OUTPUT.PUT_LINE('Total Dine-In Orders: ' || dineIn_count);
end;
/

-- update customerID and deliveryID
Declare 
    cursor order_cursor IS 
        select orderID
        from new_orders
        where deliveryID IS NULL 
        AND customerID IS Null;

    v_orderID new_orders.orderID%TYPE;
    v_deliveryID NUMBER := -1;
    v_customerID NUMBER := -1;

BEGIN
 -- Open the cursor
    OPEN order_cursor;
    
    -- Loop through each order where deliveryID and customerID are NULL
    LOOP
        FETCH order_cursor INTO v_orderID;
        
        EXIT WHEN order_cursor%NOTFOUND;

        -- Update the record to set deliveryID and customerID to -1
        UPDATE new_orders
        SET deliveryID = v_deliveryID, 
            customerID = v_customerID
        WHERE orderID = v_orderID;
    END LOOP;
    
    -- Close the cursor
    CLOSE order_cursor;
    
    -- Commit the changes
    COMMIT;
END;
/

-- update dinein number
Declare 
    cursor order_cursor IS 
        select orderID
        from new_orders
        where dineInNumber IS NULL;

    v_orderID new_orders.orderID%TYPE;
    v_dineIN NUMBER := -1;

BEGIN
 -- Open the cursor
    OPEN order_cursor;
    
    -- Loop through each order where deliveryID and customerID are NULL
    LOOP
        FETCH order_cursor INTO v_orderID;
        
        EXIT WHEN order_cursor%NOTFOUND;

        -- Update the record to set deliveryID and customerID to -1
        UPDATE new_orders
        SET dineInNumber = v_dineIN
        WHERE orderID = v_orderID;
    END LOOP;
    
    -- Close the cursor
    CLOSE order_cursor;
    
    -- Commit the changes
    COMMIT;
END;
/



-- update statement (Currently not using)
-- DECLARE
--   CURSOR order_cursor IS
--     SELECT orderID
--     FROM new_orders
--     WHERE dineInNumber IS NULL
--       AND deliveryID IS NULL
--       AND customerID IS NULL;

--   v_orderID    new_orders.orderID%TYPE;
--   v_deliveryID new_delivery.deliveryID%TYPE;
--   v_customerID new_cust.custID%TYPE;

-- BEGIN
--   FOR order_rec IN order_cursor LOOP
--     -- Select the next available deliveryID from new_delivery
--     SELECT deliveryID
--     INTO v_deliveryID
--     FROM new_delivery
--     WHERE ROWNUM = 1
--     ORDER BY deliveryID;

--     -- Randomly select a customerID from new_cust
--     SELECT custID
--     INTO v_customerID
--     FROM (
--       SELECT custID
--       FROM new_cust
--       ORDER BY DBMS_RANDOM.VALUE
--     )
--     WHERE ROWNUM = 1;

--     -- Update the order with the selected deliveryID and customerID
--     UPDATE new_orders
--     SET deliveryID = v_deliveryID,
--         customerID = v_customerID
--     WHERE orderID = order_rec.orderID;

--   END LOOP;

--   -- Output to confirm update
--   DBMS_OUTPUT.PUT_LINE('Orders updated with deliveryID and customerID.');
-- END;
-- /


-- customer row
--   COUNT(*)
-- ----------
--     331776

select count(*) AS Total_order
from new_orders;

-- TOTAL_ORDER
-- -----------
--     2741809
-- Total Delivery Orders: 1096630
-- Total Dine-In Orders: 1645179

SELECT COUNT(*)
FROM new_orders
WHERE deliveryID IS NULL AND customerID IS NULL AND dineInNumber iS NULL;

select count(*)
from new_orders
where dineInNumber IS NOT NULL;

-- =====================================================================================================================
-- Order Details

drop table new_order_details;
CREATE TABLE new_order_details (
  orderID     NUMBER NOT NULL,
  menuID      VARCHAR2(4),
  quantity    NUMBER(2),
  price       NUMBER(6,2),
  subtotal    NUMBER,
  CONSTRAINT PK_order_details PRIMARY KEY (orderID, menuID),
  CONSTRAINT FK_orderID FOREIGN KEY (orderID) REFERENCES new_orders(orderID),
  CONSTRAINT FK_menuID FOREIGN KEY (menuID) REFERENCES new_menu(menuID)
);



DECLARE
  v_orderID     NUMBER;
  v_menuID      VARCHAR2(4);
  v_quantity    NUMBER;
  v_price       NUMBER;
  v_subtotal    NUMBER;
  v_totalOrders NUMBER := 2738867; 
  v_numItems    NUMBER;
  v_counter     NUMBER := 0;
  
  CURSOR order_cursor IS
    SELECT orderID
    FROM new_orders; -- Assuming you have a list of orderIDs in new_orders table

BEGIN
  FOR order_rec IN order_cursor LOOP
    v_orderID := order_rec.orderID;
    v_numItems := TRUNC(DBMS_RANDOM.VALUE(1, 4));
    
    FOR i IN 1..v_numItems LOOP
      SELECT menuID
      INTO v_menuID
      FROM (
        SELECT menuID
        FROM new_menu 
        ORDER BY DBMS_RANDOM.VALUE
      )
      WHERE ROWNUM = 1;

      SELECT ItemPrice
      INTO v_price
      FROM new_menu
      WHERE menuID = v_menuID;
      
      v_quantity := TRUNC(DBMS_RANDOM.VALUE(1, 6));
      v_subtotal := v_quantity * v_price;
      
      -- Check if the combination of orderID and menuID already exists
      BEGIN
        -- Attempt to insert
        INSERT INTO new_order_details (orderID, menuID, quantity, price, subtotal)
        VALUES (v_orderID, v_menuID, v_quantity, v_price, v_subtotal); 
      
        v_counter := v_counter + 1;
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          -- Handle the case where the combination already exists
          DBMS_OUTPUT.PUT_LINE('Duplicate entry for orderID ' || v_orderID || ' and menuID ' || v_menuID);
      END;
    END LOOP;
  END LOOP;
  -- Output the total number of rows inserted
  DBMS_OUTPUT.PUT_LINE(v_counter || ' rows inserted into new_order_details.');
END;
/



--   COUNT(*)
-- ----------
--    5438936

-- COLUMN orderID FORMAT 999999999999999

-- ====================================================================================
-- CONTRACT

drop table new_contract;
create table new_contract (
 CONTRACTID VARCHAR2(5)  NOT NULL, 
 TENANTID            VARCHAR2(4) NOT NULL, 
 STALLID             VARCHAR2(4) NOT NULL, 
 STALLNAME           VARCHAR2(35) NOT NULL,
 PENALTYAMOUNT       NUMBER(6,2) NOT NULL,
 CONTRACTSTARTDATE   DATE NOT NULL,
 CONTRACTENDDATE     DATE NOT NULL,
 RENTALFEE           NUMBER(6,2) NOT NULL,
 PAYMENTDUEDATE       NUMBER(2) NOT NULL,
constraint PK_contractID primary key(contractID),
constraint FK_C_tenantID foreign key(tenantID) references new_tenants(tenantID),
constraint FK_C_stallID foreign key(stallID) references new_stall(stallID)
);


drop sequence new_contract_seq;
create sequence new_contract_seq
start with 1001
increment by 1;



-- generate based data
DECLARE
  v_contractID         VARCHAR2(5);
  v_tenantID           VARCHAR2(4);
  v_stallID            VARCHAR2(4);
  v_stallName          VARCHAR2(50);
  v_penaltyAmount      NUMBER(6, 2);
  v_contractStartDate  DATE;
  v_contractEndDate    DATE;
  v_rentalFee          NUMBER(6, 2);
  v_paymentDueDate     NUMBER(2);
  v_currentYear        NUMBER;
  v_currentStall       NUMBER;
  v_totalTenants       NUMBER;
  v_totalStalls        NUMBER;

BEGIN
  -- Fetch the total number of tenants and stalls
  SELECT COUNT(*)
  INTO v_totalTenants
  FROM new_tenants;

  SELECT COUNT(*)
  INTO v_totalStalls
  FROM new_stall;

  -- Loop through each year
  FOR v_currentYear IN 2014..2023 LOOP

    -- Loop through the first 20 stalls and create new contracts
    FOR v_currentStall IN 1 .. LEAST(20, v_totalStalls) LOOP

      -- Fetch tenant sequentially by ID for the first 20 records
      SELECT tenantID
      INTO v_tenantID
      FROM (
        SELECT tenantID, ROW_NUMBER() OVER (ORDER BY tenantID) AS rn
        FROM new_tenants
      )
      WHERE rn = v_currentStall;

      -- Generate contract ID
      SELECT new_contract_seq.NEXTVAL INTO v_contractID FROM dual;

      -- Fetch stall details sequentially by ID for the first 20 records
      SELECT stallID
      INTO v_stallID
      FROM (
        SELECT stallID, ROW_NUMBER() OVER (ORDER BY stallID) AS rn
        FROM new_stall
      )
      WHERE rn = v_currentStall;

      v_stallName := 'Stall ' || v_stallID;

      -- Generate contract dates
      v_contractStartDate := TO_DATE('01-01-' || v_currentYear, 'DD-MM-YYYY');
      v_contractEndDate := LAST_DAY(ADD_MONTHS(v_contractStartDate, 11));

      -- Set random rental fee and penalty amount
      v_rentalFee := 1000 + 100 * TRUNC(DBMS_RANDOM.VALUE(1, 10));
      v_penaltyAmount := 100 * TRUNC(DBMS_RANDOM.VALUE(1, 6));
      v_paymentDueDate := TRUNC(DBMS_RANDOM.VALUE(10, 16)); -- Random day for payment due date

      INSERT INTO new_contract (
        CONTRACTID, TENANTID, STALLID, STALLNAME, PENALTYAMOUNT,
        CONTRACTSTARTDATE, CONTRACTENDDATE, RENTALFEE, PAYMENTDUEDATE
      ) VALUES (
        v_contractID, v_tenantID, v_stallID, v_stallName, v_penaltyAmount,
        v_contractStartDate, v_contractEndDate, v_rentalFee, v_paymentDueDate
      );

      DBMS_OUTPUT.PUT_LINE('ContractID: ' || v_contractID ||
                           ', TenantID: ' || v_tenantID ||
                           ', StallID: ' || v_stallID ||
                           ', StallName: ' || v_stallName ||
                           ', StartDate: ' || TO_CHAR(v_contractStartDate, 'DD-MM-YYYY') ||
                           ', EndDate: ' || TO_CHAR(v_contractEndDate, 'DD-MM-YYYY'));

    END LOOP;

  END LOOP;
END;
/


-- every year resign 1 to 2 people
DECLARE
  v_oldTenantID       VARCHAR2(4);
  v_newTenantID       VARCHAR2(4);
  v_stallID           VARCHAR2(4);
  v_contractID        VARCHAR2(5);
  v_currentYear       NUMBER;
  v_tenantCount       NUMBER;
  v_randomChangeCount NUMBER;
  v_randomTenantNum   NUMBER;

BEGIN
  -- Loop through each year
  FOR v_currentYear IN 2014..2023 LOOP
    -- Determine how many tenants to change (1 or 2)
    v_randomChangeCount := TRUNC(DBMS_RANDOM.VALUE(1, 3)); -- 1 or 2

    -- Loop to update the required number of tenants
    FOR i IN 1 .. v_randomChangeCount LOOP
      -- Get a contract that needs to be updated for the current year
      SELECT CONTRACTID, TENANTID, STALLID
      INTO v_contractID, v_oldTenantID, v_stallID
      FROM (
        SELECT CONTRACTID, TENANTID, STALLID
        FROM new_contract
        WHERE EXTRACT(YEAR FROM CONTRACTSTARTDATE) = v_currentYear
        ORDER BY DBMS_RANDOM.VALUE
      )
      WHERE ROWNUM = 1;

      -- Select a new tenant that is not currently assigned to this stall
      SELECT tenantID
      INTO v_newTenantID
      FROM (
        SELECT tenantID
        FROM new_tenants
        WHERE tenantID != v_oldTenantID
        ORDER BY DBMS_RANDOM.VALUE
      )
      WHERE ROWNUM = 1;

      -- Update the contract for the current year
      UPDATE new_contract
      SET TENANTID = v_newTenantID
      WHERE CONTRACTID = v_contractID;

      -- Update all future contracts for the same stall and previous tenant
      UPDATE new_contract
      SET TENANTID = v_newTenantID
      WHERE TENANTID = v_oldTenantID
        AND EXTRACT(YEAR FROM CONTRACTSTARTDATE) > v_currentYear
        AND STALLID = v_stallID;

      DBMS_OUTPUT.PUT_LINE('Updated ContractID: ' || v_contractID ||
                           ', OldTenantID: ' || v_oldTenantID ||
                           ', NewTenantID: ' || v_newTenantID ||
                           ', StallID: ' || v_stallID);

    END LOOP;

  END LOOP;
END;
/


-- update stallname statement
DECLARE
  TYPE name_array IS VARRAY(20) OF VARCHAR2(20);
  stallname name_array := name_array(
    'Bite n Savor',
    'Flavors of the World',
    'Street Eats',
    'Taste Temptations',
    'Food Fusion',
    'Gourmet Corner',
    'Snack Haven',
    'The Grub Hub',
    'Savory Delights',
    'Urban Taste',
    'Epicurean Express',
    'Flavor Junction',
    'Culinary Carousel',
    'The Snack Spot',
    'Tasty Treats',
    'Fusion Feast',
    'Flavorful Bites',
    'Delicious Junction',
    'Sizzling Plates',
    'Gourmet Garden'
  );

  v_contractID       VARCHAR2(5);
  v_stallName        VARCHAR2(50);
  v_index            NUMBER := 1;  -- Start with the first stall name

BEGIN
  -- Loop through each contract and assign stall names
  FOR contract_rec IN (
    SELECT CONTRACTID
    FROM new_contract
    ORDER BY CONTRACTID
  ) LOOP
    -- Determine the stall name for the current contract
    v_stallName := stallname(v_index);

    -- Update the contract with the stall name
    UPDATE new_contract
    SET STALLNAME = v_stallName
    WHERE CONTRACTID = contract_rec.CONTRACTID;

    -- Move to the next stall name, wrapping around if needed
    v_index := v_index + 1;
    IF v_index > stallname.COUNT THEN
      v_index := 1;  -- Reset to the first stall name if end is reached
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Updated ContractID: ' || contract_rec.CONTRACTID ||
                         ', StallName: ' || v_stallName);

  END LOOP;
  
  COMMIT;
END;
/


-- ====================================================================================

-- ======================================================
-- |                    DIMENSION                      |
-- ======================================================

-- Date Dimension /

drop table Date_dim;
CREATE TABLE Date_dim
(
    date_key            NUMBER NOT NULL,    -- Primary Key, Running Number
    cal_date            DATE NOT NULL,      -- Calendar Date
    full_desc           VARCHAR2(31),       -- Full spelling of the date
    day_num_year        NUMBER(3),          -- 1 to 366 (Day number of the year)
    cal_week_year       NUMBER(2),          -- 1 to 52 (Week of the year)
    cal_quarter         CHAR(2),            -- Q1 to Q4 (Quarter of the year)
    cal_year_quarter    CHAR(7),            -- 'YYYY-QX' (Year and Quarter)
    cal_year            NUMBER(4),          -- Calendar Year
    holiday_ind         CHAR(1),            -- 'Y'/'N' (Holiday indicator)
    festive_event       VARCHAR2(28),       -- Name of festive event (if any)
    weekDay_ind         CHAR(1),            -- 'Y'/'N' (Is a weekday)
    
    CONSTRAINT PK_date_key PRIMARY KEY(date_key)
);

-- sequence
Drop sequence Date_seq;
Create sequence Date_seq
START WITH 100001
INCREMENT BY 1;


-- generate data
DECLARE
    startDate           DATE := TO_DATE('01/01/2014', 'dd/mm/yyyy'); -- Start date: January 1, 2014
    endDate             DATE := TO_DATE('31/12/2023', 'dd/mm/yyyy'); -- End date: December 31, 2023
    v_CAL_DATE          DATE;
    v_FULL_DESC         VARCHAR2(40);
    v_DAY_NUM_YEAR      NUMBER(3);
    v_CAL_WEEK_YEAR     NUMBER(2);
    v_CAL_QUARTER       CHAR(2);
    v_CAL_YEAR_QUARTER  CHAR(7);
    v_CAL_YEAR          NUMBER(4);
    v_HOLIDAY_IND       CHAR(1);
    v_WEEKDAY_IND       CHAR(1);
    v_FESTIVE_EVENT     VARCHAR2(25);
    counter             NUMBER := 0;

BEGIN
    WHILE (startDate <= endDate) LOOP
        -- Assign values to the variables based on startDate
        v_CAL_DATE := startDate;                                         
        v_FULL_DESC := SUBSTR(TO_CHAR(startDate, 'Year') || ' ' || TO_CHAR(startDate, 'MONTH') || ' ' || TO_CHAR(startDate, 'DD'), 1, 31);

        v_DAY_NUM_YEAR := TO_CHAR(startDate, 'DDD');  -- Day number of the year
        v_CAL_WEEK_YEAR := TO_CHAR(startDate, 'IW');  -- Week number in the year
        v_CAL_QUARTER := TO_CHAR(startDate, 'Q');     -- Quarter of the year
        v_CAL_YEAR_QUARTER := TO_CHAR(startDate, 'YYYY-Q');  -- Year-Quarter format
        v_CAL_YEAR := TO_CHAR(startDate, 'YYYY');     -- Year

        -- Set holiday indicator to 'N' for now (can be updated for actual holidays)
        v_HOLIDAY_IND := 'N';

        -- Determine if the current day is a weekday or weekend
        IF TO_CHAR(startDate, 'D') BETWEEN 2 AND 6 THEN  -- Weekday (Mon-Fri)
            v_WEEKDAY_IND := 'Y';
        ELSE  -- Weekend (Sat-Sun)
            v_WEEKDAY_IND := 'N';
        END IF;

        -- Set festive event to NULL (can be updated with actual events)
        v_FESTIVE_EVENT := NULL;

        -- Insert the values into the Date_dim table
        INSERT INTO Date_dim (
            date_key,
            cal_date,
            full_desc,
            day_num_year,
            cal_week_year,
            cal_quarter,
            cal_year_quarter,
            cal_year,
            holiday_ind,
            weekDay_ind,
            festive_event
        )
        VALUES (
            date_seq.NEXTVAL,
            v_CAL_DATE,
            v_FULL_DESC,
            v_DAY_NUM_YEAR,
            v_CAL_WEEK_YEAR,
            v_CAL_QUARTER,
            v_CAL_YEAR_QUARTER,
            v_CAL_YEAR,
            v_HOLIDAY_IND,
            v_WEEKDAY_IND,
            v_FESTIVE_EVENT
        );

        -- Increment the date by one day
        startDate := startDate + 1;
    END LOOP;
END;
/





select sysdate, 
    to_char(sysdate,'Q')||''||
    to_char(sysdate,'MONTH')||''|| 
    to_char(sysdate,'YYYY-Q') Full_Desc
from dual;                                                                                          

select cal_date,
    last_day_ind,
    cal_week_end_date,
    cal_quarter,
    cal_year_month,
    cal_year_quarter,
    week_ind
from date_dim
where cal_year = 2023
order by 1;

new_cust
new_orders
new_order_details
date_dim


select A.country, C.cal_quarter,count(*) No_of_orders
from new_cust A
JOIN new_orders B on A.customerID = B.customerID
JOIN date_dim C on B.orderDate = C.cal_date
WHERE C.cal_year = 2023 AND C.cal_quarter = 'Q1'
group by A.country, C.cal_quarter
order by C.cal_quarter;

update date_dim
set holiday_ind = 'Y'
WHERE cal_date to_date()


-- ====================================================================================
-- Platform dim /

drop table Platform_dim;
CREATE TABLE Platform_dim (
    platform_key NUMBER  not null,      
    platformID varchar(5) NOT NULL,
    deliveryID number not null,
    PlatformName varchar(10) NOT NULL,       
    DriverName varchar(20) not null,                 
    PickUpTime varchar(10) not null,                   
    ArrivedTime varchar(10) not null,                  
    DeliveryCost number(4,2) not null,               
    DeliveryAddress varchar(50) not null,
CONSTRAINT PK_Platform_dim PRIMARY KEY(platform_key)         
);

drop sequence platform_dim_seq;
create sequence platform_dim_seq
START WITH 1001
increment by 1;


INSERT INTO platform_dim
select platform_dim_seq.nextval,
 P.platformID,
 D.deliveryID,
 P.PlatformName,
 D.DriverName,
 D.PickUpTime,
 D.ArrivedTime,
 D.DeliveryCost,
 D.DeliveryAddress
from new_platform P
JOIN new_delivery D on P.platformID = D.platformID;

-- default key (dine in purpose)
UPDATE platform_dim
SET platform_key = -1
WHERE platform_key = 1229801;


-- ====================================================================================
-- Business_dim

drop sequence business_dim_seq;
create sequence business_dim_seq
 start with 1001
 increment by 1;

drop table business_dim;
create table business_dim
(business_key number NOT NULL,
 stallID   varchar(4) NOT NULL,
 tenantID  varchar(4) NOT NULL,
 tenantName varchar(20) NOT NULL,
 tenantEmail varchar(35) NOT NULL,
 stallSize varchar(35) NOT NULL,
 stallType varchar(35) NOT NULL,
 stallName varchar(35) NOT NULL,
constraint PK_business_key primary key(business_key)
);

INSERT INTO business_dim
select business_dim_seq.nextval,
 S.stallID,
 T.tenantID,
 T.tenantPerson,
 T.tenantEmail,
 S.stallSize,
 S.stallType,
 C.stallName
from new_stall    S
JOIN new_contract C on S.stallID = C.stallID
JOIN new_tenants  T on C.tenantID = T.tenantID;


-- ====================================================================================
-- Menu Dim
drop table MENU_DIM;
CREATE TABLE MENU_DIM (
  MENU_KEY     NUMBER NOT NULL ,
  menuID       varchar(4) NOT NULL,
  FOODNDRINK   VARCHAR(25) NOT NULL,
  ITEM_DESC    VARCHAR(100) NOT NULL,
  ITEM_PRICE   NUMBER(5,2) NOT NULL,
  CONSTRAINT PK_MENU PRIMARY KEY (MENU_KEY)
);

drop sequence menu_dim_seq
CREATE sequence menu_dim_seq
 	start with 100001
 	increment by 1;

INSERT INTO MENU_DIM (
    MENU_KEY,
    menuID,
    FOODNDRINK,
    ITEM_DESC,
    ITEM_PRICE
)
SELECT
    menu_dim_seq.NEXTVAL,
    menuID, 
    foodNDrink,
    ItemDesc,
    ItemPrice
FROM new_menu;


-- ====================================================================================
-- cust dim

drop sequence cust_dim_seq;
create sequence cust_dim_seq
 	start with 100001
 	increment by 1;


drop table customer_dim;
CREATE TABLE Customer_dim (
  CUSTOMER_KEY     NUMBER NOT NULL,
  CUSTOMER_ID      NUMBER NOT NULL,
  CUSTOMER_BIRTHDATE DATE  NOT NULL,
  CUSTOMER_GENDER  CHAR(1)  NOT NULL,
  CONSTRAINT PK_customer PRIMARY KEY (CUSTOMER_KEY)
);


INSERT INTO Customer_dim (
    CUSTOMER_KEY,
    CUSTOMER_ID,
    CUSTOMER_BIRTHDATE,
    CUSTOMER_GENDER
)
SELECT
    cust_dim_seq.NEXTVAL, 
    CUSTID,
    CUSTBIRTHDATE,
    CUSTGENDER
FROM new_cust;


-- Default (dine in)
UPDATE customer_dim
SET customer_key = -1
WHERE customer_key = 100007;


-- ====================================================================================

-- ======================================================
-- |                    Fact Table                      |
-- ======================================================

-- Contract
drop table contract_fact;
create table contract_fact
(date_key          number      not null,
 business_key      number      not null,
 contractID        varchar2(5) not null,
 contractStartDate date        not null,
 contractEndDate   date        not null,
 penaltyAmount     number(6,2) not null,
constraint PK_contract_fact primary key(date_key,business_key,contractID),
constraint FK_contract_date_key foreign key(date_key) references date_dim(date_key),
constraint FK_contract_business_key foreign key(business_key) references 			business_dim(business_key)
);

insert into contract_fact
select
 B.date_key,
 C.Business_key,
 A.contractID,
 A.contractStartDate,
 A.contractEndDate,
 A.penaltyAmount
from new_contract    A
join date_dim        B on A.contractStartDate = B.cal_date
join business_dim    C on A.stallID           = C.stallID
;


-- ====================================================================================

-- Order_facts
drop table order_facts;
CREATE TABLE Order_Facts (
    CUSTOMER_KEY NUMBER NOT NULL,
    Platform_key NUMBER NOT NULL,
    Menu_key NUMBER NOT NULL,
    Business_key NUMBER NOT NULL,
    DATE_KEY NUMBER NOT NULL,
    orderID NUMBER NOT NULL,
    quantity NUMBER NOT NULL,
    OrderRating NUMBER NOT NULL,
    unit_price NUMBER(5, 2) NOT NULL,
    CONSTRAINT PK_ORDER_fact PRIMARY KEY (date_key, customer_key, platform_key, orderid, Menu_key, business_key),
    CONSTRAINT FK_date_key FOREIGN KEY (date_key) REFERENCES date_dim (date_key),
    CONSTRAINT FK_customer_key FOREIGN KEY (customer_key) REFERENCES customer_dim (customer_key),
    CONSTRAINT FK_Plat_key FOREIGN KEY (Platform_key) REFERENCES platform_dim (Platform_key),
    CONSTRAINT FK_Business_key FOREIGN KEY (Business_key) REFERENCES Business_dim (Business_key),
    CONSTRAINT FK_Menu_key FOREIGN KEY (Menu_key) REFERENCES Menu_dim (Menu_key)
);


-- use this 
INSERT INTO Order_Facts (
    CUSTOMER_KEY, Platform_key, Menu_key, Business_key, DATE_KEY, orderID, quantity, OrderRating, unit_price
)
SELECT
    D.Customer_key, 
    E.Platform_key, 
    F.MENU_KEY,
    H.Business_key,
    C.DATE_KEY,
    A.orderID,
    B.quantity,
    A.rating AS OrderRating,
    F.ITEM_PRICE AS unit_price
FROM new_orders A
JOIN new_order_details B ON A.orderID = B.orderID
JOIN Date_dim C ON A.orderDate = C.cal_date
JOIN customer_dim D ON A.customerID = D.customer_ID
JOIN Platform_dim E ON A.deliveryID = E.deliveryID
JOIN Menu_dim F ON B.menuID = F.menuID
JOIN new_menu G ON F.menuID = G.menuID
JOIN Business_dim H ON G.stallID = H.stallID;






-- subsequent loading

--Platform 
INSERT INTO platform_dim
SELECT platform_dim_seq.nextval,  
       P.platformID,
       D.deliveryID,
       P.PlatformName,
       D.DriverName,
       D.PickUpTime,
       D.ArrivedTime,
       D.DeliveryCost,
       D.DeliveryAddress
FROM new_platform P
JOIN new_delivery D ON P.platformID = D.platformID
WHERE (P.platformID, D.deliveryID) NOT IN (
    SELECT platformID, deliveryID 
    FROM platform_dim
);

--  business_dim 
INSERT INTO business_dim (
    business_key,  
    stallID,
    tenantID,
    tenantName,    
    tenantEmail,
    stallSize,
    stallType,
    stallName
)
SELECT
    business_dim_seq.nextval,  
    S.stallID,
    T.tenantID,
    T.tenantPerson,
    T.tenantEmail,
    S.stallSize,
    S.stallType,
    C.stallName
FROM
    new_stall S
JOIN
    new_contract C ON S.stallID = C.stallID
JOIN
    new_tenants T ON C.tenantID = T.tenantID
WHERE 
    (S.stallID, T.tenantID) NOT IN (
        SELECT BD.stallID, BD.tenantID
        FROM business_dim BD
    );


--Menu
INSERT INTO MENU_DIM (
    MENU_KEY,
    menuID,
    FOODNDRINK,
    ITEM_DESC,
    ITEM_PRICE
)
SELECT
    menu_dim_seq.NEXTVAL,
    nm.menuID, 
    nm.foodNDrink,
    nm.ItemDesc,
    nm.ItemPrice
FROM new_menu nm
WHERE nm.menuID NOT IN (SELECT md.menuID FROM MENU_DIM md);


--Customer 
INSERT INTO Customer_dim (
    CUSTOMER_KEY,
    CUSTOMER_ID,
    CUSTOMER_BIRTHDATE,
    CUSTOMER_GENDER
)
SELECT
    cust_dim_seq.NEXTVAL, 
    nc.CUSTID,
    nc.CUSTBIRTHDATE,
    nc.CUSTGENDER
FROM new_cust nc
WHERE nc.CUSTID NOT IN (
    SELECT CUSTOMER_ID 
    FROM Customer_dim
);

--date 

CREATE OR REPLACE PROCEDURE Prod_Insert_Date_Dim AS
    startDate           DATE := TO_DATE('01/01/2014', 'DD/MM/YYYY');
    endDate             DATE := TO_DATE('31/12/2023', 'DD/MM/YYYY');
    v_CAL_DATE          DATE;
    v_FULL_DESC         VARCHAR2(40);
    v_DAY_NUM_YEAR      NUMBER(3);
    v_CAL_WEEK_YEAR     NUMBER(2);
    v_CAL_QUARTER       CHAR(2);
    v_CAL_YEAR_QUARTER  CHAR(7);
    v_CAL_YEAR          NUMBER(4);
    v_HOLIDAY_IND       CHAR(1);
    v_WEEKDAY_IND       CHAR(1);
    v_FESTIVE_EVENT     VARCHAR2(25);
    v_count             NUMBER;
BEGIN
    WHILE (startDate <= endDate) LOOP
        v_CAL_DATE := startDate;                                         
        v_FULL_DESC := SUBSTR(TO_CHAR(startDate, 'YYYY') || ' ' || TO_CHAR(startDate, 'MONTH') || ' ' || TO_CHAR(startDate, 'DD'), 1, 31);
        v_DAY_NUM_YEAR := TO_CHAR(startDate, 'DDD');  -- Day number of the year
        v_CAL_WEEK_YEAR := TO_CHAR(startDate, 'IW');  -- Week number of the year
        v_CAL_QUARTER := TO_CHAR(startDate, 'Q');     -- Quarter of the year
        v_CAL_YEAR_QUARTER := TO_CHAR(startDate, 'YYYY-Q');  -- Year and Quarter
        v_CAL_YEAR := TO_CHAR(startDate, 'YYYY');     -- Calendar year
        v_HOLIDAY_IND := 'N';  -- You can update this later for actual holidays

        -- Determine if the current day is a weekday or weekend
        IF TO_CHAR(startDate, 'D') BETWEEN 2 AND 6 THEN
            v_WEEKDAY_IND := 'Y';  -- Weekday
        ELSE
            v_WEEKDAY_IND := 'N';  -- Weekend
        END IF;

        v_FESTIVE_EVENT := NULL;  -- You can update this later with actual festive events

        -- Check if the date already exists in date_dim
        BEGIN
            SELECT COUNT(*)
            INTO v_count
            FROM date_dim
            WHERE cal_date = v_CAL_DATE;

            IF v_count = 0 THEN
                -- Insert new row if date doesn't exist
                INSERT INTO date_dim (
                    date_key, cal_date, full_desc, day_num_year, cal_week_year, 
                    cal_quarter, cal_year_quarter, cal_year, holiday_ind, weekday_ind, festive_event
                ) VALUES (
                    date_seq.NEXTVAL, v_CAL_DATE, v_FULL_DESC, v_DAY_NUM_YEAR, 
                    v_CAL_WEEK_YEAR, v_CAL_QUARTER, v_CAL_YEAR_QUARTER, 
                    v_CAL_YEAR, v_HOLIDAY_IND, v_WEEKDAY_IND, v_FESTIVE_EVENT
                );
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error checking or inserting date: ' || SQLERRM);
        END;

        -- Increment the date by one day
        startDate := startDate + 1;
    END LOOP;
END Prod_Insert_Date_Dim;
/
EXEC Prod_Insert_Date_Dim;


--contract fact 
INSERT INTO contract_fact (
    date_key, 
    business_key, 
    contractID, 
    contractStartDate, 
    contractEndDate, 
    penaltyAmount
)
SELECT
    B.date_key,
    C.business_key,
    A.contractID,
    A.contractStartDate,
    A.contractEndDate,
    A.penaltyAmount
FROM 
    new_contract A
JOIN 
    date_dim B ON A.contractStartDate = B.cal_date
JOIN 
    business_dim C ON A.stallID = C.stallID
WHERE 
    A.contractID NOT IN (
        SELECT CF.contractID
        FROM contract_fact CF
    );


    -- order fact
INSERT INTO Order_Facts (
    CUSTOMER_KEY, Platform_key, Menu_key, Business_key, DATE_KEY, orderID, quantity, OrderRating, unit_price
)
SELECT
    D.Customer_key, 
    E.Platform_key, 
    F.MENU_KEY,
    H.Business_key,
    C.DATE_KEY,
    A.orderID,
    B.quantity,
    A.rating AS OrderRating,
    F.ITEM_PRICE AS unit_price
FROM 
    new_orders A
JOIN 
    new_order_details B ON A.orderID = B.orderID
JOIN 
    Date_dim C ON A.orderDate = C.cal_date
JOIN 
    customer_dim D ON A.customerID = D.customer_ID
JOIN 
    Platform_dim E ON A.deliveryID = E.deliveryID
JOIN 
    Menu_dim F ON B.menuID = F.menuID
JOIN 
    new_menu G ON F.menuID = G.menuID
JOIN 
    Business_dim H ON G.stallID = H.stallID
WHERE 
    A.orderID NOT IN (
        SELECT orderID
        FROM Order_Facts
    );




-- -- testing
-- -- Insert into order_facts (dont)
-- INSERT INTO order_facts (
--   Customer_key, Platform_key, Menu_key, Business_key, Date_key, orderID, quantity, OrderRating, unit_price
-- )
-- SELECT 
--   CASE 
--       WHEN ord.customerID IS NULL THEN -1 
--       ELSE cust.Customer_key 
--     END AS Customer_key,
--   CASE 
--       WHEN ord.deliveryID IS NULL THEN -1 
--       ELSE plat.Platform_key 
--     END AS Platform_key,
--     menu.Menu_key,       
--     bus.Business_key,    
--     D.Date_key,        
--     ord.orderID,         
--     ord_details.quantity, 
--     ord.rating,  
--     ord_details.price    
-- FROM 
--     new_orders ord
-- JOIN 
--     new_order_details ord_details ON ord.orderID = ord_details.orderID 
-- LEFT JOIN 
--     Customer_dim cust ON ord.customerID = cust.CUSTOMER_ID  
-- LEFT JOIN 
--     new_delivery del ON ord.deliveryID = del.deliveryID 
-- LEFT JOIN 
--     Platform_dim plat ON del.platformID = plat.platformID 
-- JOIN 
--     Menu_dim menu ON ord_details.menuID = menu.menuID   
-- JOIN 
--     new_menu nm ON menu.menuID = nm.menuID
-- JOIN 
--     Business_dim bus ON nm.stallID = bus.stallID 
-- JOIN 
--     Date_dim D ON ord.orderdate = D.cal_date;  
-- /





SELECT sid, serial#, status, username, osuser, machine, program
FROM v$session
WHERE username = 'weikang';




-- ====================================================================================
-- ====================================================================================
-- TESTING PURPOSE

-- DECLARE
--     v_random_number NUMBER;
--     v_greater_count NUMBER := 0;
--     v_lesser_count NUMBER := 0;
-- BEGIN
--     FOR i IN 1..100000 LOOP
--         v_random_number := DBMS_RANDOM.VALUE(0, 1);

--         IF v_random_number > 0.4 THEN
--             v_greater_count := v_greater_count + 1;
--         ELSE
--             v_lesser_count := v_lesser_count + 1;
--         END IF;
--     END LOOP;

--     DBMS_OUTPUT.PUT_LINE('Count of numbers > 0.4: ' || v_greater_count);
--     DBMS_OUTPUT.PUT_LINE('Count of numbers <= 0.4: ' || v_lesser_count);
-- END;
-- /








DECLARE
  CURSOR order_cursor IS
    SELECT orderID
    FROM new_orders
    WHERE dineInNumber IS NULL
      AND deliveryID IS NULL
      AND customerID IS NULL;

  v_orderID    new_orders.orderID%TYPE;
  v_deliveryID new_delivery.deliveryID%TYPE;
  v_customerID new_cust.custID%TYPE;
  counter      NUMBER := 0;  -- Numeric variable to track the row number

BEGIN
  FOR order_rec IN order_cursor LOOP
    counter := counter + 1;  -- Increment the counter for each row

    -- Select the next available deliveryID from new_delivery
    SELECT deliveryID
    INTO v_deliveryID
    FROM new_delivery
    WHERE ROWNUM = 1
    ORDER BY deliveryID;

    -- Randomly select a customerID from new_cust
    SELECT custID
    INTO v_customerID
    FROM (
      SELECT custID
      FROM new_cust
      ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE ROWNUM = 1;

    -- Update the order with the selected deliveryID and customerID
    UPDATE new_orders
    SET deliveryID = v_deliveryID,
        customerID = v_customerID
    WHERE orderID = order_rec.orderID;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Orders updated with deliveryID and customerID.');
END;
/


drop table test_orders;
create table test_orders (
  orderID number not null,
  orderdate date,
  dineInNumber number,
  rating    number,
  deliveryID number,
  customerID number,
  CONSTRAINT PK_orderID1 PRIMARY KEY (orderID),
  CONSTRAINT FK_deliveryID1 FOREIGN KEY (deliveryID) REFERENCES new_delivery(deliveryID),
  CONSTRAINT FK_customerID1 FOREIGN KEY (customerID) REFERENCES new_cust(custID)
);



drop sequence test_orders_seq;
create sequence test_orders_seq
start with 1000001
increment by 1;


declare
  v_orderID number;
  startDate date := to_date('01/10/2023','dd/mm/yyyy');
  endDate date := to_date('31/12/2023','dd/mm/yyyy');
  v_orderDate date;
  v_dineInNumber number;
  v_rating number;
  v_deliveryID number;
  v_customerID number;
  counter number :=0;
  v_random_number number;
  totalOrders number;

  dineIn_count NUMBER := 0;
  delivery_count NUMBER := 0;

BEGIN
  while(startDate<=endDate) LOOP
    v_orderDate := startDate;
    totalOrders := 700 + TRUNC(DBMS_RANDOM.VALUE(0,101));

    for i in 1..totalOrders LOOP
      v_orderID:= test_orders_seq.NEXTVAL;
      v_rating := TRUNC(DBMS_RANDOM.VALUE(1,6));
      v_random_number := DBMS_RANDOM.VALUE(0, 1);
      
      if v_random_number > 0.6 THEN
        SELECT deliveryID
        INTO v_deliveryID
        FROM new_delivery
        WHERE ROWNUM = 1
        ORDER BY deliveryID;

        SELECT custID
        INTO v_customerID
        FROM (
          SELECT custID
          FROM new_cust
          ORDER BY DBMS_RANDOM.VALUE
        )
        WHERE ROWNUM = 1;

        v_dineInNumber := null;
        delivery_count := delivery_count + 1;
      ELSE
        v_dineInNumber := 999;
        v_deliveryID := null;
        v_customerID := null;
        dineIn_count := dineIn_count + 1;
      end if;

      insert into test_orders (orderID, orderDate, dineInNumber, rating, deliveryID, customerID)
      values (v_orderID,v_orderDate,v_dineInNumber,v_rating,v_deliveryID,v_customerID);

      counter := counter + 1;
    end loop;

    startDate:=startDate+1;
  end loop;
  DBMS_OUTPUT.PUT_LINE(counter || ' orders inserted.');
  DBMS_OUTPUT.PUT_LINE('Total Delivery Orders: ' || delivery_count);
  DBMS_OUTPUT.PUT_LINE('Total Dine-In Orders: ' || dineIn_count);
end;
/








declare
  v_contractID         VARCHAR2(5);
  v_tenantID           VARCHAR2(4);
  v_stallID            VARCHAR2(4);
  v_stallName          VARCHAR2(50);
  v_penaltyAmount      NUMBER(6, 2);
  v_contractStartDate  DATE;
  v_contractEndDate    DATE;
  v_rentalFee          NUMBER(6, 2);
  v_currentYear        NUMBER;
  v_currentStall       NUMBER;
  v_totalTenants       NUMBER;
  v_totalStalls        NUMBER;
  startDate date := to_date('01/01/2014','dd/mm/yyyy');
  endDate date := to_date('31/12/2023','dd/mm/yyyy');
  v_paymentDueDate Date;

  CURSOR tenant_cursor IS 
    SELECT tenantID 
    FROM new_tenants;

  CURSOR stall_cursor IS 
    SELECT stallID 
    FROM new_stall;

BEGIN 
  SELECT COUNT(*)
  INTO v_totalTenants
  FROM new_tenants;    
-- 40 tenants
  SELECT COUNT(*)
  INTO v_totalStalls
  FROM new_stall;
-- 20 stall

  while(startDate<=endDate) LOOP
    v_contractStartDate := startDate;
    v_contractEndDate := ADD_MONTHS(v_contractStartDate, 12);
    FOR tenant_rec IN tenant_cursor LOOP
      v_tenantID := tenant_rec.tenantID;
      
      -- Loop through all stalls
      FOR stall_rec IN stall_cursor LOOP
        v_stallID := stall_rec.stallID;

        -- Here you can insert the contract into your contract table
        v_contractID := v_tenantID || '_' || v_stallID || '_' || TO_CHAR(startDate, 'YYYY');
        v_rentalFee := TRUNC(DBMS_RANDOM.VALUE(1000, 3000), 2);
        v_electricfee := TRUNC(DBMS_RANDOM.VALUE(100, 500), 2);
        v_penaltyAmount := TRUNC(DBMS_RANDOM.VALUE(50, 200), 2);
        v_paymentDueDate := TRUNC(DBMS_RANDOM.VALUE(1, 28));

        INSERT INTO contracts (
          contractID,
          tenantID,
          stallID,
          contractStartDate,
          contractEndDate,
          rentalFee,
          electricfee,
          penaltyAmount,
          paymentDueDate
        )
        VALUES (
          v_contractID,
          v_tenantID,
          v_stallID,
          v_contractStartDate,
          v_contractEndDate,
          v_rentalFee,
          v_electricfee,
          v_penaltyAmount,
          v_paymentDueDate
        );

      END LOOP;
    END LOOP;
    startDate := ADD_MONTHS(startDate, 12); 
  end loop;


END;
/




DECLARE
  CURSOR cust_cursor IS
    SELECT CUSTID
    FROM new_cust
    WHERE CUSTBIRTHDATE IS NULL; -- Only update records with NULL birthdate

  v_custID         new_cust.CUSTID%TYPE;
  v_custBirthDate  DATE;
  v_custGender     CHAR(1);
  v_age            NUMBER;
  counter          NUMBER := 0;
  v_randomValue    NUMBER;
  v_dateRange      NUMBER := TO_DATE('31-12-2005', 'DD-MM-YYYY') - TO_DATE('01-01-1940', 'DD-MM-YYYY');
  
  -- Variables for age range counts
  age_18_25        NUMBER := 0;
  age_26_33        NUMBER := 0;
  age_34_41        NUMBER := 0;
  age_42_49        NUMBER := 0;
  age_50_above     NUMBER := 0;

  -- Bias exponent
  bias_exponent    NUMBER := 0.8; -- Adjust this value as needed

BEGIN
  FOR cust_rec IN cust_cursor LOOP
    v_custID := cust_rec.CUSTID;

    -- Generate a biased random value using the specified exponent
    v_randomValue := POWER(DBMS_RANDOM.VALUE(0, 1), bias_exponent);

    -- Generate biased random birthdate between 1940 and 2005
    v_custBirthDate := TO_DATE('01-01-1940', 'DD-MM-YYYY') + TRUNC(v_randomValue * v_dateRange);

    -- Calculate age (current year - birth year)
    v_age := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM v_custBirthDate);

    -- Assign gender based on random value
    v_randomValue := DBMS_RANDOM.VALUE(0, 1);
    IF v_randomValue <= 0.6 THEN
      v_custGender := 'F';
    ELSE
      v_custGender := 'M';
    END IF;

    -- Categorize age into ranges
    IF v_age BETWEEN 18 AND 25 THEN
      age_18_25 := age_18_25 + 1;
    ELSIF v_age BETWEEN 26 AND 33 THEN
      age_26_33 := age_26_33 + 1;
    ELSIF v_age BETWEEN 34 AND 41 THEN
      age_34_41 := age_34_41 + 1;
    ELSIF v_age BETWEEN 42 AND 49 THEN
      age_42_49 := age_42_49 + 1;
    ELSE
      age_50_above := age_50_above + 1;
    END IF;

    -- Increment counter for each customer processed
    counter := counter + 1;
  END LOOP;

  -- Output the total number of customers processed
  DBMS_OUTPUT.PUT_LINE(counter || ' customers processed for birthdate generation.');

  -- Display the count of customers in each age range
  DBMS_OUTPUT.PUT_LINE('Age 18-25: ' || age_18_25);
  DBMS_OUTPUT.PUT_LINE('Age 26-33: ' || age_26_33);
  DBMS_OUTPUT.PUT_LINE('Age 34-41: ' || age_34_41);
  DBMS_OUTPUT.PUT_LINE('Age 42-49: ' || age_42_49);
  DBMS_OUTPUT.PUT_LINE('Age 50 and above: ' || age_50_above);
END;
/
