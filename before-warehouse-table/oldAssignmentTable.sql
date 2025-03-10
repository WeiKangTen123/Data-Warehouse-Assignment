DROP TABLE ORDERDETAILS; 
DROP TABLE Orders; 
DROP TABLE Customers;
DROP TABLE Delivery;
DROP TABLE platform;
DROP TABLE Menu;
DROP TABLE RentalCollection;
DROP TABLE Staff;
DROP TABLE CONTRACT;
DROP TABLE Tenants;
DROP TABLE stall;

CREATE TABLE stall(
 stallId varchar(4) NOT NULL,
 stallSize varchar(35) NOT NULL,
 stallType varchar(35) NOT NULL,
 Availability varchar(1) NOT NULL,
 PRIMARY KEY(stallId),
 CONSTRAINT chk_Availability CHECK (UPPER(Availability) in ('Y','N'))
);

CREATE TABLE Tenants(
 tenantId varchar(4) NOT NULL,
 tenantPerson varchar(20) NOT NULL,
 tenantEmail varchar(35) NOT NULL,
 tenantPhone varchar(12) NOT NULL,
 PRIMARY KEY(tenantId)
);

CREATE TABLE CONTRACT(
 contractID varchar(4) NOT NULL,
 StallName Varchar(35),
 penaltyAmount number(6,2) NOT NULL,
 contractStartDate date NOT NULL,
 contractEndDate date NOT NULL,
 tenantId varchar(4) NOT NULL,
 stallId varchar(4) NOT NULL,
 PRIMARY KEY(contractID),
 FOREIGN KEY (tenantId) REFERENCES Tenants(tenantId),
 FOREIGN KEY (stallId) REFERENCES stall(stallId)
);

CREATE TABLE Staff(
 staffID varchar(4) NOT NULL,
 staffName varchar(20) NOT NULL,
 staffContractDate date NOT NULL,
 salary number(8,2) NOT NULL,
 position varchar(20) NOT NULL,
 PRIMARY KEY(staffID)
);

CREATE TABLE RentalCollection(
 stallId varchar(4) NOT NULL,
 staffID varchar(4) NOT NULL,
 RentalCollectionID varchar(5) NOT NULL,
 Rentaldate date NOT NULL,
 rentalFee number(8,2) NOT NULL,
 paymentStatus varchar(1) NOT NULL,
 WaterPaymentDate date NOT NULL,
 WaterPaymentAmount number(5,2) NOT NULL,
 ElectricalPaymentDate date NOT NULL,
 ElectricalPaymentAmount number(5,2) NOT NULL,
 PRIMARY KEY(stallId,staffID,RentalCollectionID),
 CONSTRAINT chk_paymentStatus CHECK (UPPER(paymentStatus) in ('Y','N')),
 FOREIGN KEY (stallId) REFERENCES stall(stallId),
 FOREIGN KEY (staffID) REFERENCES Staff(staffID)
);

CREATE TABLE Menu(
 menuID varchar(4) NOT NULL,
 FoodNDrink varchar(25) NOT NULL,
 ItemDesc varchar(100) NOT NULL,
 ItemPrice number(5,2) NOT NULL,
 AveRating number(4,2),
 stallId varchar(4) NOT NULL,
 PRIMARY KEY(menuID),
 FOREIGN KEY (stallId) REFERENCES stall(stallId)
);

CREATE TABLE platform(
 platformID varchar(4) NOT NULL,
 platformName varchar(10) NOT NULL,
 platformContact varchar(12) NOT NULL,
 platformEmail varchar(35),
 PRIMARY KEY(platformID)
);

CREATE TABLE Delivery(
 deliveryID varchar(4) NOT NULL,
 driverName varchar(20) NOT NULL,
 driverContract varchar(12) NOT NULL,
 pickupTime VARCHAR(8) NOT NULL,
 arrivedTime VARCHAR(8) NOT NULL,
 deliveryStatus varchar(1) NOT NULL,
 deliveryCost number(4,2),
 deliveryAddress varchar(50) NOT NULL,
 platformID varchar(4) NOT NULL,
 PRIMARY KEY(deliveryID),
 CONSTRAINT chk_deliveryStatus CHECK (UPPER(deliveryStatus) in ('Y','N')),
FOREIGN KEY (platformID) REFERENCES platform(platformID)
);



CREATE TABLE Customers(
 customerID varchar(4) NOT NULL,
 customerName varchar(20) NOT NULL,
 customerPhone varchar(12) NOT NULL,
 customerEmail varchar(35) NOT NULL,
 PRIMARY KEY(customerID)
);



CREATE TABLE Orders(
 orderID varchar(4) NOT NULL,
 orderDate date NOT NULL,
 DIneInNumber number(3) NULL,
 feedbackDesc varchar(100) NOT NULL,
 rating number(1) NOT NULL,
 deliveryID varchar(4) NULL,
 customerID varchar(4) NULL,
 PRIMARY KEY(orderID),
 FOREIGN KEY (customerID) REFERENCES Customers(customerID),
 FOREIGN KEY (deliveryID) REFERENCES Delivery(deliveryID)
);

CREATE TABLE ORDERDETAILS(
 orderID varchar(4) NOT NULL,
 menuID varchar(4) NOT NULL, 
 quantity varchar(2) NOT NULL,
 price number(6,2) NOT NULL,
 Subtotal number(8,2) ,
 PRIMARY KEY (orderID,menuID),
 FOREIGN KEY (orderID) REFERENCES Orders(orderID),
 FOREIGN KEY (menuID) REFERENCES Menu(menuID)
);




CREATE OR REPLACE TRIGGER calculate_subtotal
BEFORE INSERT ON ORDERDETAILS
FOR EACH ROW
DECLARE
    v_menu_price Menu.ItemPrice%TYPE;
BEGIN
    SELECT ItemPrice INTO v_menu_price
    FROM Menu
    WHERE menuID = :NEW.menuID;

    :NEW.price := v_menu_price;

    :NEW.Subtotal := :NEW.quantity * v_menu_price;
END;
/


CREATE OR REPLACE TRIGGER calculate_delivery_cost
BEFORE INSERT ON Delivery
FOR EACH ROW
BEGIN
    CASE
        WHEN SUBSTR(:NEW.platformID, 1, 1) = 'G' THEN
            :NEW.deliveryCost := 10;
        WHEN SUBSTR(:NEW.platformID, 1, 1) = 'F' THEN
            :NEW.deliveryCost := 20.10;
        WHEN SUBSTR(:NEW.platformID, 1, 1) = 'S' THEN
            :NEW.deliveryCost := 5.10;
        ELSE
            :NEW.deliveryCost := 0; -- Default delivery cost if platformID doesn't match any case
    END CASE;
END;
/

CREATE OR REPLACE TRIGGER check_rating_trigger
BEFORE INSERT OR UPDATE ON Orders
FOR EACH ROW
DECLARE
    invalid_rating EXCEPTION;
BEGIN
    IF (:NEW.rating < 1 OR :NEW.rating > 5) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Rating must be between 1 and 5.');
    END IF;
EXCEPTION
    WHEN invalid_rating THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid rating value detected.');
END;
/




CREATE OR REPLACE TRIGGER calculate_average_rating
AFTER INSERT ON ORDERDETAILS
FOR EACH ROW
DECLARE
    total_rating NUMBER;
    total_orders NUMBER;
    average_rating NUMBER;
BEGIN
   
    SELECT SUM(rating), COUNT(*) INTO total_rating, total_orders
    FROM Orders
    WHERE orderID = :NEW.orderID;
 
    IF total_orders > 0 THEN
        average_rating := total_rating / total_orders;
    ELSE
        average_rating := 0; -- or set to NULL if you prefer
    END IF;

    UPDATE Menu
    SET AveRating = average_rating
    WHERE menuID = :NEW.menuID;
END;
/




CREATE OR REPLACE TRIGGER check_contract_dates
BEFORE INSERT ON CONTRACT
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM CONTRACT
    WHERE stallId = :NEW.stallId
    AND ((contractStartDate <= :NEW.contractStartDate AND contractEndDate >= :NEW.contractStartDate)
         OR (contractStartDate <= :NEW.contractEndDate AND contractEndDate >= :NEW.contractEndDate));

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Another contract with overlapping dates already exists for the same stallId.');
    END IF;
END;
/


CREATE OR REPLACE TRIGGER update_stall_availability
AFTER INSERT OR UPDATE OR DELETE ON CONTRACT
FOR EACH ROW
BEGIN
    IF INSERTING OR UPDATING THEN
        UPDATE stall
        SET Availability = 'N'
        WHERE stallId = :NEW.stallId
        AND (:NEW.contractStartDate <= SYSDATE AND :NEW.contractEndDate >= SYSDATE);
    END IF;

    IF DELETING THEN
        UPDATE stall
        SET Availability = 'Y'
        WHERE stallId = :OLD.stallId
        AND NOT EXISTS (
            SELECT 1
            FROM CONTRACT
            WHERE stallId = :OLD.stallId
            AND (:OLD.contractStartDate <= SYSDATE AND :OLD.contractEndDate >= SYSDATE)
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER check_phone_format_customers
BEFORE INSERT OR UPDATE ON Customers
FOR EACH ROW
BEGIN
    IF NOT REGEXP_LIKE(:NEW.customerPhone, '^\d{3}-\d{3}-\d{4}$') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid phone number format for Customers. Use xxx-xxx-xxxx format.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER check_phone_format_platform
BEFORE INSERT OR UPDATE ON platform
FOR EACH ROW
BEGIN
    IF NOT REGEXP_LIKE(:NEW.platformContact, '^\d{3}-\d{3}-\d{4}$') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid phone number format for platform. Use xxx-xxx-xxxx format.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER check_phone_format_delivery
BEFORE INSERT OR UPDATE ON Delivery
FOR EACH ROW
BEGIN
    IF NOT REGEXP_LIKE(:NEW.driverContract, '^\d{3}-\d{3}-\d{4}$') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid phone number format for driverContract. Use xxx-xxx-xxxx format.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER check_phone_format_tenants
BEFORE INSERT OR UPDATE ON Tenants
FOR EACH ROW
BEGIN
    IF NOT REGEXP_LIKE(:NEW.tenantPhone, '^\d{3}-\d{3}-\d{4}$') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid phone number format for Tenants. Use xxx-xxx-xxxx format.');
    END IF;
END;
/





DECLARE
  CURSOR cust_cursor IS
    SELECT CUSTID
    FROM new_cust
    WHERE CUSTBIRTHDATE IS NULL; -- Only update records with NULL birthdate

  v_custID        new_cust.CUSTID%TYPE;
  v_custBirthDate DATE;
  v_custGender    CHAR(1);
  counter         NUMBER := 0;
BEGIN
  FOR cust_rec IN cust_cursor LOOP
    v_custID := cust_rec.CUSTID;

    -- Generate random birthdate between 1940 and 2005
    v_custBirthDate := TO_DATE('01-01-1940', 'DD-MM-YYYY') + TRUNC(DBMS_RANDOM.VALUE(0, TO_DATE('31-12-2005', 'DD-MM-YYYY') - TO_DATE('01-01-1940', 'DD-MM-YYYY')));

    -- Determine gender based on modulus operation
    IF MOD(TO_NUMBER(TO_CHAR(v_custBirthDate, 'YYYY')), 2) = 1 THEN
      v_custGender := 'M';
    ELSE
      v_custGender := 'F';
    END IF;

    -- Update the record in new_cust table
    UPDATE new_cust
    SET CUSTBIRTHDATE = v_custBirthDate,
        CUSTGENDER = v_custGender
    WHERE CUSTID = v_custID;

    -- Increment counter for each update
    counter := counter + 1;
  END LOOP;

  -- Output the number of customers updated
  DBMS_OUTPUT.PUT_LINE(counter || ' customers updated in new_cust table.');
END;
/


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


DECLARE
    v_random_number NUMBER;
    v_greater_count NUMBER := 0;
    v_lesser_count NUMBER := 0;
BEGIN
    FOR i IN 1..100 LOOP
        v_random_number := DBMS_RANDOM.VALUE(0, 1);

        IF v_random_number > 0.39 THEN
            v_greater_count := v_greater_count + 1;
        ELSE
            v_lesser_count := v_lesser_count + 1;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Count of numbers > 0.4: ' || v_greater_count);
    DBMS_OUTPUT.PUT_LINE('Count of numbers <= 0.4: ' || v_lesser_count);
END;
/




