-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2022-12-19 12:39:35.252

-- tables
-- Table: CourseCategories
CREATE TABLE CourseCategories (
    CourseCategoryID int NOT NULL identity,
    CourseCategoryName varchar(50)  NOT NULL,
    Description varchar(100)  NOT NULL,
    CONSTRAINT CourseCategories_ak_1 UNIQUE (CourseCategoryName),
    CONSTRAINT CourseCategories_pk PRIMARY KEY  (CourseCategoryID)
);

-- Table: Courses
CREATE TABLE Courses (
    CourseID int  NOT NULL identity,
    CourseName varchar(50)  NOT NULL,
    CourseCategoryID int  NOT NULL,
    UnitPrice money  NOT NULL CHECK (UnitPrice > 0),
    UnitsInStock int  NOT NULL CHECK (UnitsInStock >= 0),
    CONSTRAINT Courses_ak_1 UNIQUE (CourseName),
    CONSTRAINT Courses_pk PRIMARY KEY  (CourseID)
);

-- Table: Currencies
CREATE TABLE Currencies (
    Name varchar(50)  NOT NULL,
    PLNValue money  NOT NULL CHECK (PLNValue > 0),
    StartDate date  NOT NULL,
    EndDate date  NOT NULL,
    CONSTRAINT Currencies_pk PRIMARY KEY  (Name)
);

-- Table: Customers
CREATE TABLE Customers (
    CustomerID int  NOT NULL identity,
    CustomerName varchar(50)  NOT NULL,
    CustomerCategoryID bit  NOT NULL,
    CONSTRAINT Customers_pk PRIMARY KEY  (CustomerID)
);

-- Table: Discounts
CREATE TABLE Discounts (
    CustomerID int  NOT NULL,
    ValidOrderCount int  NOT NULL DEFAULT 0 CHECK (ValidOrderCount >= 0),
    TotalOutcome money  NOT NULL DEFAULT 0 CHECK (TotalOutcome >= 0),
    DiscountType bit  NOT NULL DEFAULT 0,
    Expires datetime  NULL,
    CONSTRAINT Discounts_pk PRIMARY KEY  (CustomerID)
);

-- Table: DiscountsTypes
CREATE TABLE DiscountsTypes (
    DiscountType bit  NOT NULL,
    DiscountName varchar(50)  NOT NULL,
    Discount float  NOT NULL CHECK (Discount > 0 AND Discount < 1),
    MinimalOutcome money check (MinimalOutcome > 0),
    MinimalOrderCount int check (MinimalOrderCount > 0),
    CONSTRAINT DiscountsTypes_pk PRIMARY KEY  (DiscountType)
);

-- Table: Employees
CREATE TABLE Employees (
    EmployeeID int  NOT NULL identity,
    LastName varchar(50)  NOT NULL,
    FirstName varchar(50)  NOT NULL,
    ReportPermission bit  NOT NULL DEFAULT 0,
    ReservationPermission bit  NOT NULL DEFAULT 0,
    OrderPermission bit  NOT NULL DEFAULT 1,
    InvoicePermission bit  NOT NULL DEFAULT 0,
    CONSTRAINT Employees_pk PRIMARY KEY  (EmployeeID)
);

-- Table: InvoiceData
CREATE TABLE InvoiceData (
    CustomerID int  NOT NULL,
    CompanyName varchar(50)  NOT NULL,
    Address varchar(50)  NOT NULL,
    PostalCode char(6)  NOT NULL,
    City varchar(50)  NOT NULL,
    Country varchar(50)  NOT NULL,
    NIP varchar(10)  NOT NULL CHECK (NIP like '[0-9]{10}'),
    CONSTRAINT InvoiceData_pk PRIMARY KEY  (CustomerID)
);

-- Table: Menu
CREATE TABLE Menu (
    CourseID int  NOT NULL identity,
    CourseName varchar(50)  NOT NULL,
    CONSTRAINT Menu_ak_1 UNIQUE (CourseName),
    CONSTRAINT Menu_pk PRIMARY KEY  (CourseID)
);

-- Table: OrderDetails
CREATE TABLE OrderDetails (
    OrderID int  NOT NULL,
    CourseID int  NOT NULL,
    Quantity int  NOT NULL CHECK (Quantity > 0),
    UnitPrice money  NOT NULL CHECK (UnitPrice > 0),
    CONSTRAINT CourseID UNIQUE (CourseID),
    CONSTRAINT OrderDetails_pk PRIMARY KEY (OrderID, CourseID)
);

-- Table: Orders
CREATE TABLE Orders (
    OrderID int  NOT NULL identity,
    CustomerID int  NOT NULL,
    EmployeeID int  NOT NULL,
    OrderName varchar(50)  NOT NULL,
    PlacementDate datetime  NOT NULL CHECK (PlacementDate >= getdate()),
    ConfirmationDate datetime,
    ReceiveDate datetime,
    Type bit  NOT NULL,
    Payment bit  NOT NULL,
    DiscountValue float  NOT NULL DEFAULT 0.0 CHECK (DiscountValue BETWEEN 0.0 AND 1.0),
    Price money not null default 0 check (Price >= 0),
    CONSTRAINT ReceiveDateCheck CHECK (ReceiveDate >= ConfirmationDate),
    CONSTRAINT ConfirmationDateCheck CHECK (ConfirmationDate >= PlacementDate),
    CONSTRAINT Orders_pk PRIMARY KEY  (OrderID)
);

-- Table: Reservations
CREATE TABLE Reservations (
    ReservationID int  NOT NULL identity,
    CustomerID int  NOT NULL,
    CustomerCategoryID bit  NOT NULL,
    ReservationDate datetime  NOT NULL,
    PlacementDate datetime  NOT NULL,
    ConfirmationDate datetime  NOT NULL,
    CONSTRAINT ReservationID UNIQUE (ReservationID),
    CONSTRAINT ConfirmationDateCheck CHECK (ConfirmationDate >= PlacementDate),
    CONSTRAINT PlacementDateCheck CHECK (PlacementDate > getdate() and PlacementDate > dateadd(hour, -24, ReservationDate)),
    CONSTRAINT Reservations_pk PRIMARY KEY  (ReservationID)
);

-- Table: ReservedTables
CREATE TABLE ReservedTables (
    ReservationID int  NOT NULL identity,
    ReservationDate datetime  NOT NULL,
    TableID varchar(4)  NOT NULL,
    CustomerID int  NOT NULL,
    SittingPeople varchar(100)  NULL,
    OccupiedSeats int  NOT NULL CHECK (OccupiedSeats > 0 and OccupiedSeats <= GetSeats(TableID)),
    CONSTRAINT ReservedTables_pk PRIMARY KEY  (ReservationID)
);

-- Table: Tables
CREATE TABLE Tables (
    TableID varchar(4)  NOT NULL identity,
    Seats int  NOT NULL CHECK (Seats > 0),
    CONSTRAINT Tables_pk PRIMARY KEY  (TableID)
);

-- views
-- View: CurrentMenu
CREATE VIEW CurrentMenu
AS
SELECT M.CourseName, CC.CourseCategoryName, C.UnitPrice 
FROM Menu M
INNER JOIN Courses C ON M.CourseName = C.CourseName
INNER JOIN CourseCategory CC ON C.CourseCategoryID = CC.CourseCategoryID

-- View: AvailableCourses
CREATE VIEW AvailableCourses
AS
SELECT CourseName, UnitsInStock 
FROM Courses
WHERE UnitsInStock > 0;

-- View: Courses
CREATE VIEW Courses
AS
SELECT C.CourseName, CC.CourseCategoryName, CC.Description
FROM Courses C
INNER JOIN CourseCategories CC ON C.CourseCategoryID = CC.CourseCategoryID;

-- View: Currencies
CREATE VIEW Currencies
AS
SELECT Name, PLNValue
FROM Currencies
WHERE GETDATE() BETWEEN StartDate AND EndDate;

-- View: MenuMonthReport
CREATE VIEW MenuMonthReport
AS
SELECT C.CourseName, SUM(OD.Quantity) AS OrderedUnits
FROM Courses C
INNER JOIN OrderDetails OD ON C.CourseID = OD.CourseID
INNER JOIN Orders O ON OD.OrderID = O.OrderID
WHERE DATEDIFF(month, O.PlacementDate, GETDATE()) = 1
GROUP BY C.CourseName



-- DATEDIFF(month, wartość do odejmowania, wartość, od której się odejmuje);

-- View: MenuWeekReport
CREATE VIEW MenuWeekReport
AS
SELECT C.CourseName, SUM(OD.Quantity) AS OrderedUnits
FROM Courses C
INNER JOIN OrderDetails OD ON C.CourseID = OD.CourseID
INNER JOIN Orders O ON OD.OrderID = O.OrderID
WHERE DATEDIFF(week, O.PlacementDate, GETDATE()) = 1
GROUP BY C.CourseName



-- DATEDIFF(week, wartość do odejmowania, wartość, od której się odejmuje);

-- View: ReservationsMonthReport
CREATE VIEW ReservationsMonthReport
AS
SELECT R.ReservationID, R.ReservationDate, C.CustomerName
FROM Reservations R
INNER JOIN Customers C ON C.CustomerID = R.CustomerID
WHERE DATEDIFF(month, R.ReservationDate, GETDATE()) = 1;

-- View: ReservationsWeekReport
CREATE VIEW ReservationsWeekReport
AS
SELECT R.ReservationID, R.ReservationDate, C.CustomerName
FROM Reservations R
INNER JOIN Customers C ON C.CustomerID = R.CustomerID
WHERE DATEDIFF(week, R.ReservationDate, GETDATE()) = 1;

-- View: NotPaidOrdersToBeFulfilled
CREATE VIEW NotPaidOrdersToBeFulfilled
AS
SELECT O.OrderID, SUM(OD.UnitPrice*OD.Quantity) AS TotalOrderPrice
FROM Orders O
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
WHERE O.Payment = 0 AND GETDATE() < O.ReceiveDate
GROUP BY O.OrderID;

-- View: Discounts
CREATE VIEW Discounts
AS
SELECT D.CustomerID, C.CustomerName, DT.DiscountName
FROM Discounts D
INNER JOIN DiscountsTypes DT ON D.DiscountType = DT.DiscountType 
INNER JOIN Customers C ON C.CustomerID = D.CustomerID;

-- View: PaidOrdersToBeFulfilled
CREATE VIEW PaidOrdersToBeFulfilled
AS
SELECT O.OrderID, SUM(OD.UnitPrice*OD.Quantity) AS TotalOrderPrice
FROM Orders O
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
WHERE O.Payment = 1 AND GETDATE() < O.ReceiveDate
GROUP BY O.OrderID;

-- View: CustomersSummary
CREATE VIEW CustomersSummary
AS
SELECT C.CustomerID, 
  COUNT(OD.OrderID) AS TotalOrderCount, 
        SUM(OD.UnitPrice*OD.Quantity) AS TotalOrderPrice, 
        COUNT(R.ReservationID) AS TotalReservationCount
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = O.OrderID
INNER JOIN Reservations R ON C.CustomerID = R.CustomerID
GROUP BY C.CustomerID;

-- foreign keys
-- Reference: CourseCategories_Courses (table: Courses)
ALTER TABLE Courses ADD CONSTRAINT CourseCategories_Courses
    FOREIGN KEY (CourseCategoryID)
    REFERENCES CourseCategories (CourseCategoryID);

-- Reference: Customer_Discounts (table: Discounts)
ALTER TABLE Discounts ADD CONSTRAINT Customer_Discounts
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: Customer_InvoiceData (table: InvoiceData)
ALTER TABLE InvoiceData ADD CONSTRAINT Customer_InvoiceData
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: Customer_Reservations (table: Reservations)
ALTER TABLE Reservations ADD CONSTRAINT Customer_Reservations
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: Discounts_DiscountsTypes (table: Discounts)
ALTER TABLE Discounts ADD CONSTRAINT Discounts_DiscountsTypes
    FOREIGN KEY (DiscountType)
    REFERENCES DiscountsTypes (DiscountType);

-- Reference: Menu_Courses (table: Courses)
ALTER TABLE Courses ADD CONSTRAINT Menu_Courses
    FOREIGN KEY (CourseID)
    REFERENCES Menu (CourseID);

-- Reference: OrderDetails_Courses (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT OrderDetails_Courses
    FOREIGN KEY (CourseID)
    REFERENCES Courses (CourseID);

-- Reference: Orders_Customer (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Orders_Customer
    FOREIGN KEY (CustomerID)
    REFERENCES Customers (CustomerID);

-- Reference: Orders_Employees (table: Orders)
ALTER TABLE Orders ADD CONSTRAINT Orders_Employees
    FOREIGN KEY (EmployeeID)
    REFERENCES Employees (EmployeeID);

-- Reference: Orders_OrderDetails (table: OrderDetails)
ALTER TABLE OrderDetails ADD CONSTRAINT Orders_OrderDetails
    FOREIGN KEY (OrderID)
    REFERENCES Orders (OrderID);

-- Reference: ReservedTables_Reservations (table: ReservedTables)
ALTER TABLE ReservedTables ADD CONSTRAINT ReservedTables_Reservations
    FOREIGN KEY (ReservationID)
    REFERENCES Reservations (ReservationID);

-- Reference: ReservedTables_Tables (table: ReservedTables)
ALTER TABLE ReservedTables ADD CONSTRAINT ReservedTables_Tables
    FOREIGN KEY (TableID)
    REFERENCES Tables (TableID);

-- End of file.

