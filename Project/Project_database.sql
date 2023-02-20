create type OrderIDList as table
(
    CustomerID int,
    OrderID    int
)
go

create type OrderList as table
(
    CourseID int not null,
    Quantity int,
    check ([Quantity] > 0)
)
go

create type TableList as table
(
    TableID            varchar(4),
    SittingPeopleCount int not null,
    SittingPeople      varchar(100),
    check ([SittingPeopleCount] > 0)
)
go

create table CourseCategories
(
    CourseCategoryID   int identity
        constraint CourseCategories_pk
            primary key,
    CourseCategoryName varchar(50) not null
        constraint CourseCategories_ak_1
            unique
)
go

create table Courses
(
    CourseID         int identity
        constraint Courses_pk
            primary key,
    CourseName       varchar(50) not null
        constraint Courses_ak_1
            unique,
    CourseCategoryID int         not null
        constraint Copy_of_CourseCategories_Courses
            references CourseCategories,
    UnitsInStock     int         not null
        check ([UnitsInStock] >= 0)
)
go

create table Currencies
(
    CurrenciesID int identity
        constraint Currencies_pk
            primary key,
    Name         varchar(50) not null,
    PLNValue     money       not null
        check ([PLNValue] > 0),
    StartDate    datetime    not null,
    EndDate      datetime    not null,
    constraint CurrenciesDates
        check ([StartDate] < [EndDate])
)
go

create table DiscountsTypes
(
    DiscountType         int         not null
        constraint DiscountsTypes_pk
            primary key,
    DiscountName         varchar(50) not null,
    Discount             float       not null
        constraint DiscountRange
            check ([Discount] > 0 AND [Discount] < 1),
    MinimalOutcome       money
        constraint MinimalOutcomePositive
            check ([MinimalOutcome] > 0),
    MinimalOrderCount    int
        constraint MinimalOrderCountPositive
            check ([MinimalOrderCount] > 0),
    MinimalSinglePayment money
        constraint MinimalSinglePaymentPositive
            check ([MinimalSinglePayment] > 0)
)
go

create table Customers
(
    CustomerID   int identity
        constraint Customers_pk
            primary key,
    IsCompany    bit not null,
    DiscountType int
        constraint Customers_DiscountTypes_ForeignKey
            references DiscountsTypes,
    CustomerName varchar(50)
)
go

create table Discounts
(
    DiscountID      int identity
        constraint Discounts_pk
            primary key,
    CustomerID      int             not null
        constraint Copy_of_Customer_Discounts
            references Customers,
    DiscountType    int   default 0 not null
        constraint Copy_of_Discounts_DiscountsTypes
            references DiscountsTypes,
    ValidOrderCount int   default 0 not null
        check ([ValidOrderCount] >= 0),
    TotalOutcome    money default 0 not null
        check ([TotalOutcome] >= 0),
    StartDate       datetime,
    EndDate         datetime,
    constraint DiscountDates
        check ([StartDate] <= [EndDate])
)
go

create trigger CheckForDiscount on Discounts
after update
as begin
    declare @CustomerID Int = (select top 1 CustomerID from Inserted)
    declare @DiscountType Int = (select top 1 DiscountType from Customers where Customers.CustomerID = @CustomerID)

    if (select top 1 IsCompany from Customers where Customers.CustomerID = @CustomerID) = 0 begin

        if (@DiscountType = 1) begin
           if (select top 1 ValidOrderCount from Discounts
            where CustomerID = @CustomerID) >= (select top 1 MinimalOrderCount from DiscountsTypes where DiscountsTypes.DiscountType = 1) begin
                update Discounts
                set StartDate = getdate()
                where CustomerID = @CustomerID
           end
        end

        if (@DiscountType = 2) begin
            if (select top 1 TotalOutcome from Discounts
            where CustomerID = @CustomerID) >= (select top 1 MinimalOutcome from DiscountsTypes where DiscountsTypes.DiscountType = 2) begin
                update Discounts
                set StartDate = getdate(), EndDate = dateadd(day, 30, getdate())
                where CustomerID = @CustomerID
            end
        end

    end
end
go

create table Employees
(
    EmployeeID            int identity
        constraint Employees_pk
            primary key,
    LastName              varchar(50)   not null,
    FirstName             varchar(50)   not null,
    ReportPermission      bit default 0 not null,
    ReservationPermission bit default 0 not null,
    OrderPermission       bit default 1 not null,
    InvoicePermission     bit default 0 not null
)
go

create table ExpiredDiscounts
(
    CustomerID        int not null
        constraint ExpiredDiscounts_CustomerID_ForeignKey
            references Customers,
    DiscountType      int not null,
    StartDate         datetime,
    EndDate           datetime,
    ExpiredDiscountID int identity
        constraint ExpiredDiscounts_pk
            primary key,
    constraint ArchivalDates_check
        check ([StartDate] <= [EndDate])
)
go

create table InvoiceData
(
    InvoiceDataID int identity
        constraint InvoiceData_pk
            primary key,
    CustomerID    int         not null
        constraint Copy_of_Customer_InvoiceData
            references Customers,
    CompanyName   varchar(50) not null,
    Address       varchar(50) not null,
    PostalCode    char(6)     not null
        constraint PostalCode_check
            check ([PostalCode] like '[0-9][0-9][-][0-9][0-9][0-9]'),
    City          varchar(50) not null,
    Country       varchar(50) not null,
    NIP           varchar(10) not null
        constraint NIPUnique
            unique
        constraint NIP_check
            check ([NIP] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
)
go

create table Menu
(
    MenuID    int identity
        constraint Menu_pk
            primary key,
    CourseID  int
        constraint Copy_of_Menu_Courses
            references Courses
        constraint SeafoodFreeMenuCategoryCheck
            check (NOT [dbo].[CheckSeafoodMenuCourseCategory]([CourseID]) like 'owoce morza'),
    StartDate datetime not null,
    EndDate   datetime not null,
    UnitPrice money,
    constraint check_start_and_end_date
        check ([StartDate] < [EndDate])
)
go

create trigger MenuPositionDailyAdvance on Menu after insert as
begin
    delete
    from Menu
    where datediff(hour, StartDate, getdate()) < 24
    and exists(
        select * from inserted
        where inserted.MenuID = Menu.MenuID
    )
end
go

create table OrderCategories
(
    OrderCategoryID   int                   not null
        constraint OrderCategories_pk
            primary key,
    OrderCategoryName varchar(50) default 1 not null
)
go

create table Orders
(
    OrderID          int identity
        constraint Orders_pk
            primary key,
    CustomerID       int               not null
        constraint Copy_of_Orders_Customer
            references Customers,
    EmployeeID       int
        constraint Copy_of_Orders_Employees
            references Employees,
    PlacementDate    datetime          not null,
    ConfirmationDate datetime,
    ReceiveDate      datetime,
    OrderCategoryID  int               not null
        constraint Orders_OrderCategories
            references OrderCategories,
    IsPaid           bit               not null,
    DiscountValue    float default 0.0 not null
        check ([DiscountValue] >= 0.0 AND [DiscountValue] < 1.0),
    Price            money default 0   not null
        check ([Price] >= 0),
    constraint ConfirmationDateCheck
        check ([ConfirmationDate] >= [PlacementDate]),
    constraint ReceiveDateCheck
        check ([ReceiveDate] >= [ConfirmationDate])
)
go

create table OrderDetails
(
    OrderDetailsID int identity
        constraint OrderDetails_pk
            primary key,
    OrderID        int not null
        constraint Copy_of_Orders_OrderDetails
            references Orders,
    CourseID       int not null
        constraint Copy_of_OrderDetails_Courses
            references Courses,
    Quantity       int not null
        constraint OrderDetailsQuantity_positive_check
            check ([Quantity] > 0)
)
go

create table Reservations
(
    ReservationID    int identity
        constraint Reservations_pk
            primary key,
    CustomerID       int      not null
        constraint Copy_of_Customer_Reservations
            references Customers,
    ReservationDate  datetime not null,
    PlacementDate    datetime not null,
    ConfirmationDate datetime,
    constraint ConfirmationDateCheck1
        check ([ConfirmationDate] >= [PlacementDate])
)
go

create table ReservationOrders
(
    ReservationOrderID int identity
        constraint ReservationOrders_pk
            primary key,
    OrderID            int
        constraint ReservationOrders_Orders_Foreign_Key
            references Orders,
    ReservationID      int
        constraint ReservationOrders_Reservations_Foreign_Key
            references Reservations
)
go

create table SeafoodMenu
(
    CourseID      int
        constraint SeafoodMenu_Courses_Foreign_key
            references Courses
        constraint SeafoodMenuCategoryCheck
            check ([dbo].[CheckSeafoodMenuCourseCategory]([CourseID]) like 'owoce morza'),
    StartDate     datetime not null,
    UnitPrice     money    not null,
    EndDate       datetime not null,
    SeafoodMenuID int identity
        constraint SeafoodMenu_pk
            primary key,
    constraint SeafoodMenu_Dates_check
        check ([StartDate] < [EndDate])
)
go

create table Tables
(
    TableID varchar(4) not null
        constraint Tables_pk
            primary key
        constraint IDFormatCheck
            check ([TableID] like '[a-z][0-9][0-9][0-9]'),
    Seats   int        not null
        check ([Seats] > 0)
)
go

create table ReservedTables
(
    ReservedTableID int identity
        constraint ReservedTables_pk
            primary key,
    TableID         varchar(4) not null
        constraint Copy_of_ReservedTables_Tables
            references Tables,
    ReservationID   int        not null
        constraint Copy_of_ReservedTables_Reservations
            references Reservations,
    SittingPeople   varchar(100),
    OccupiedSeats   int        not null
        check ([OccupiedSeats] > 0),
    constraint OccupiedSeatsNotGreaterThanAvailable
        check ([OccupiedSeats] <= [dbo].[GetSeats]([TableID]))
)
go

CREATE VIEW ActiveDiscounts
AS
SELECT CustomerID, DiscountType, StartDate, EndDate
FROM Discounts
WHERE StartDate IS NOT NULL
go

grant select on ActiveDiscounts to Employee
go

grant select on ActiveDiscounts to Manager
go

CREATE VIEW AvailableCourses
AS
SELECT CourseID, CourseName, UnitsInStock
FROM Courses
WHERE UnitsInStock > 0
go

grant select on AvailableCourses to Employee
go

grant select on AvailableCourses to Manager
go

CREATE VIEW CourseOrderedUnitsLastYearMonthReport
AS
SELECT  YEAR(PlacementDate) AS Year,
        MONTH(PlacementDate) AS Month,
       OD.CourseID, SUM(Quantity) AS NumberOfOrderedUntis
FROM OrderDetails OD
INNER JOIN Orders O on O.OrderID = OD.OrderID
INNER JOIN Courses C on C.CourseID = OD.CourseID
WHERE YEAR(PlacementDate) = YEAR(GETDATE()) - 1
GROUP BY YEAR(PlacementDate), MONTH(PlacementDate), OD.CourseID
go

grant select on CourseOrderedUnitsLastYearMonthReport to Manager
go

CREATE VIEW CourseOrderedUnitsLastYearWeekReport
AS
SELECT  YEAR(PlacementDate) AS Year,
        MONTH(PlacementDate) AS Month,
       DATEDIFF(week, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0), PlacementDate) AS WeekOfTheYear,
       OD.CourseID, SUM(Quantity) AS NumberOfOrderedUntis
FROM OrderDetails OD
INNER JOIN Orders O on O.OrderID = OD.OrderID
INNER JOIN Courses C on C.CourseID = OD.CourseID
WHERE YEAR(PlacementDate) = YEAR(GETDATE()) - 1
GROUP BY YEAR(PlacementDate), MONTH(PlacementDate), DATEDIFF(week, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0), PlacementDate), OD.CourseID
go

grant select on CourseOrderedUnitsLastYearWeekReport to Manager
go

CREATE VIEW CourseOrderedUnitsThisMonthReport1
AS
SELECT OD.CourseID, SUM(Quantity) AS NumberOfCourseOrders
FROM Orders O
INNER JOIN OrderDetails OD on O.OrderID = OD.OrderID
WHERE MONTH(PlacementDate) = MONTH(GETDATE())
GROUP BY OD.CourseID
go

grant select on CourseOrderedUnitsThisMonthReport to Manager
go

CREATE VIEW CurrentCurrencies
AS
SELECT Name, PLNValue
FROM Currencies
WHERE GETDATE() BETWEEN StartDate AND EndDate
go

grant select on CurrentCurrencies to Employee
go

grant select on CurrentCurrencies to Manager
go

CREATE VIEW CurrentMenu
AS
SELECT M.CourseID, C.CourseName, UnitPrice
FROM Courses C
INNER JOIN Menu M on C.CourseID = M.CourseID
WHERE GETDATE() BETWEEN StartDate AND EndDate
go

grant select on CurrentMenu to Employee
go

grant select on CurrentMenu to Manager
go

CREATE VIEW CurrentSeafoodMenu
AS
SELECT SM.CourseID, C.CourseName, UnitPrice
FROM Courses C
INNER JOIN SeafoodMenu SM on C.CourseID = SM.CourseID
WHERE GETDATE() BETWEEN StartDate AND EndDate
go

grant select on CurrentSeafoodMenu to Employee
go

grant select on CurrentSeafoodMenu to Manager
go

CREATE VIEW CustomerDiscountChoice
AS
SELECT C.CustomerID, DiscountName
FROM Customers C
INNER JOIN Discounts D on C.CustomerID = D.CustomerID
INNER JOIN DiscountsTypes DT on DT.DiscountType = D.DiscountType
go

grant select on CustomerDiscountChoice to Employee
go

grant select on CustomerDiscountChoice to Manager
go

CREATE VIEW CustomersOrdersStatistics
AS
SELECT C1.CustomerID,
       COUNT(OrderID) AS TotalOrdersNumber,
       ISNULL(SUM(Price),0) AS TotalOrdersPriceSum
FROM Customers C1
LEFT OUTER JOIN Orders O1 on C1.CustomerID = O1.CustomerID
GROUP BY C1.CustomerID
go

grant select on CustomersOrdersStatistics to Manager
go

CREATE VIEW CustomersReservationsAndReservedTablesStatistics
AS
SELECT C.CustomerID, COUNT(R.ReservationID) AS NumberOfReservations,
                    (SELECT ISNULL(COUNT(TableID), 0)
                    FROM Customers C1
                    INNER JOIN Reservations R2 on C1.CustomerID = R2.CustomerID
                    INNER JOIN ReservedTables RT on R2.ReservationID = RT.ReservationID
                    WHERE C1.CustomerID = C.CustomerID) AS NumberOfReservedTables
FROM Customers C
LEFT JOIN Reservations R on C.CustomerID = R.CustomerID
GROUP BY C.CustomerID
go

grant select on CustomersReservationsStatistics to Manager
go

CREATE VIEW NotConfirmedReservations
AS
SELECT ReservationID, PlacementDate, ReservationDate
FROM Reservations
WHERE ConfirmationDate IS NULL
    AND DATEDIFF(hour, GETDATE(), ReservationDate) >= 24
go

grant select on NotConfirmedReservations to Employee
go

grant select on NotConfirmedReservations to Manager
go

CREATE VIEW OrdersLastYearMonthReport
AS
SELECT YEAR(PlacementDate) AS Year,
       MONTH(PlacementDate) AS Month,
       COUNT(OrderID) AS NumberOfOrders,
       SUM(Price) AS TotalPriceOfOrders
FROM Orders
WHERE YEAR(PlacementDate) = YEAR(GETDATE()) - 1
GROUP BY YEAR(PlacementDate), MONTH(PlacementDate)
go

grant select on OrdersLastYearMonthReport to Manager
go

CREATE VIEW OrdersLastYearWeekReport
AS
SELECT YEAR(PlacementDate) AS Year,
       MONTH(PlacementDate) AS Month,
       DATEDIFF(week, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0), PlacementDate) AS WeekOfTheYear,
       COUNT(OrderID) AS NumberOfOrders,
       SUM(Price) AS TotalPriceOfOrders
FROM Orders
WHERE YEAR(PlacementDate) = YEAR(GETDATE()) - 1
GROUP BY YEAR(PlacementDate), MONTH(PlacementDate), DATEDIFF(week, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0), PlacementDate)
go

grant select on OrdersLastYearWeekReport to Manager
go

CREATE VIEW ReservationsAndReservedTablesLastYearMonthReport
AS
SELECT YEAR(PlacementDate) AS Year,
       MONTH(PlacementDate) AS Month,
       COUNT(DISTINCT R.ReservationID) as TotalNumberOfReservations,
       COUNT(ReservedTableID) as TotalNumberOfReservedTables
FROM Reservations R
INNER JOIN ReservedTables RT on R.ReservationID = RT.ReservationID
WHERE YEAR(PlacementDate) = YEAR(GETDATE()) - 1
GROUP BY YEAR(PlacementDate), MONTH(PlacementDate)
go

grant select on ReservationsAndReservedTablesLastYearMonthReport to Manager
go

CREATE VIEW ReservationsAndReservedTablesLastYearWeekReport
AS
SELECT YEAR(PlacementDate) AS Year,
       MONTH(PlacementDate) AS Month,
       DATEDIFF(week, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0), PlacementDate) AS WeekOfTheYear,
       COUNT(DISTINCT R.ReservationID) as TotalNumberOfReservations,
       COUNT(ReservedTableID) as TotalNumberOfReservedTables
FROM Reservations R
INNER JOIN ReservedTables RT on R.ReservationID = RT.ReservationID
WHERE YEAR(PlacementDate) = YEAR(GETDATE()) - 1
GROUP BY YEAR(PlacementDate), MONTH(PlacementDate), DATEDIFF(week, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0), PlacementDate)
go

grant select on ReservationsAndReservedTablesLastYearWeekReport to Manager
go

CREATE VIEW ReservationsThisMonthReport
AS
SELECT ReservationID, PlacementDate, ReservationDate
FROM Reservations
WHERE MONTH(PlacementDate) = MONTH(GETDATE())
go

grant select on ReservationsThisMonthReport to Manager
go

CREATE VIEW ReservedTablesThisMonthReport1
AS
SELECT TableID, COUNT(ReservedTableID) AS NumberOfTableReservations
FROM ReservedTables
INNER JOIN Reservations R2 on R2.ReservationID = ReservedTables.ReservationID
WHERE MONTH(PlacementDate) = MONTH(GETDATE())
GROUP BY TableID
go

grant select on ReservedTablesThisMonthReport to Manager
go

CREATE VIEW TablesReservationsYearMonthReport
AS
SELECT YEAR(PlacementDate) AS Year,
       MONTH(PlacementDate) AS Month,
       TableID,
       COUNT(R.ReservationID) as TotalNumberOfTableReservations
FROM Reservations R
INNER JOIN ReservedTables RT on R.ReservationID = RT.ReservationID
WHERE YEAR(PlacementDate) = YEAR(GETDATE()) - 1
GROUP BY TableID, YEAR(PlacementDate), MONTH(PlacementDate)
go

grant select on TablesReservationsYearMonthReport to Manager
go

CREATE VIEW TablesReservationsYearWeekReport
AS
SELECT YEAR(PlacementDate) AS Year,
       MONTH(PlacementDate) AS Month,
       DATEDIFF(week, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0), PlacementDate) AS WeekOfTheYear,
       TableID,
       COUNT(R.ReservationID) as TotalNumberOfTableReservations
FROM Reservations R
INNER JOIN ReservedTables RT on R.ReservationID = RT.ReservationID
WHERE YEAR(PlacementDate) = YEAR(GETDATE()) - 1
GROUP BY YEAR(PlacementDate), MONTH(PlacementDate), DATEDIFF(week, DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) - 1, 0), PlacementDate), TableID
go

grant select on TablesReservationsYearWeekReport to Manager
go

CREATE VIEW TakeawayOrdersToBeFulfilled
AS
SELECT OrderID, ReceiveDate
FROM Orders
WHERE OrderCategoryID = 2 AND ReceiveDate > GETDATE()
go

grant select on TakeawayOrdersToBeFulfilled to Employee
go

grant select on TakeawayOrdersToBeFulfilled to Manager
go

CREATE procedure AcceptDelivery @Items OrderList readonly as

    declare @CourseID Int
    declare @Quantity Int

    declare CurrentCourse Cursor
        local static read_only forward_only
    for
        select CourseID
        from @Items

    declare CurrentQuantity Cursor
        local static forward_only read_only
    for
        select Quantity
        from @Items

    open CurrentQuantity
    fetch next from CurrentQuantity into @Quantity

    open CurrentCourse
    fetch next from CurrentCourse into @CourseID

    while @@fetch_status = 0 begin
        exec AddToStock @CourseID, @Quantity
        fetch next from CurrentCourse into @CourseID
        fetch next from CurrentQuantity into @Quantity
    end

    close CurrentCourse
    close CurrentQuantity

    deallocate CurrentCourse
    deallocate CurrentQuantity
go

grant execute on AcceptDelivery to Employee
go

grant execute on AcceptDelivery to Manager
go

create procedure AddCompanyCustomer
    @CompanyName varchar(50),
    @Address varchar(50),
    @PostalCode varchar(50),
    @City varchar(50),
    @Country varchar(50),
    @NIP varchar(10) as

    exec AddCustomer
        @CompanyName,
        1,
        @Address,
        @PostalCode,
        @City,
        @Country,
        @NIP,
        null
go

grant execute on AddCompanyCustomer to Employee
go

grant execute on AddCompanyCustomer to Manager
go

CREATE procedure AddCourse @CourseName varchar(50), @CourseCategoryName varchar(50) as
    if (select top 1 CourseID from Courses where CourseName like @CourseName) is not null begin
        declare @Exception_1 varchar(50) = 'Course ' + cast(@CourseName as varchar) + ' already exists';
        throw 2137, @Exception_1, 2137
    end

    if (select top 1 CourseCategoryID from CourseCategories where CourseCategoryName like @CourseCategoryName) is null begin
        declare @Exception_2 varchar(50) = 'Cannot add course to a non-existing category ' + cast(@CourseCategoryName as varchar);
        throw 2137, @Exception_2, 2137
    end

    insert into Courses(
        CourseName,
        CourseCategoryID,
        UnitsInStock
    )
    values (
        @CourseName,
        (select distinct CourseCategoryID from CourseCategories where CourseCategoryName like @CourseCategoryName),
        0
    )
go

grant execute on AddCourse to Manager
go

create procedure AddCourseCategory @CategoryName varchar(50) as
    insert into CourseCategories(
        CourseCategoryName
    )
    values (
        @CategoryName
    )
go

grant execute on AddCourseCategory to Manager
go

create procedure AddCurrencyPosition @CurrencyName varchar(50), @PLNValue money, @StartDate datetime, @EndDate datetime as

    insert into Currencies(
        Name,
        PLNValue,
        StartDate,
        EndDate
    )
    values (
        @CurrencyName,
        @PLNValue,
        @StartDate,
        @EndDate
    )
go

grant execute on AddCurrencyPosition to Manager
go

CREATE procedure AddCustomer
    @CustomerName varchar(50),
    @IsCompany bit,
    @Address varchar(50),
    @PostalCode varchar(6),
    @City varchar(50),
    @Country varchar(50),
    @NIP varchar(10),
    @DiscountType Int
    as

    insert into Customers (
        IsCompany,
        DiscountType
    )
    values (
        @IsCompany,
        @DiscountType
    );

    declare @CustomerID Int = (select top 1 scope_identity());

    if @IsCompany = 1
        exec CreateInvoiceProfile
            @CustomerID,
            @CustomerName,
            @Address,
            @PostalCode,
            @City,
            @Country,
            @NIP;
    else
        exec CreateDiscountProfile
            @CustomerID,
            @DiscountType
go

create procedure AddEmployee @FirstName varchar(50), @LastName varchar(50) as
    insert into Employees (
        LastName,
        FirstName
    )
    values (
        @LastName,
        @FirstName
    )
go

grant execute on AddEmployee to Manager
go

create procedure AddIndividualCustomer @CustomerName varchar(50), @DiscountType Int as
    exec AddCustomer
        @CustomerName,
        0,
        null,
        null,
        null,
        null,
        null,
        @DiscountType
go

grant execute on AddIndividualCustomer to Employee
go

grant execute on AddIndividualCustomer to Manager
go

create procedure AddTable @TableID varchar(4), @Seats Int as
    insert into Tables(
        TableID,
        Seats
    )
    values (
        @TableID,
        @Seats
    )
go

grant execute on AddTable to Manager
go

CREATE procedure AddToDiscount @CustomerID Int, @TotalPrice money as
    if (
        (select top 1 DiscountType from Customers where CustomerID = @CustomerID) = 1
            and @TotalPrice > (select top 1 MinimalSinglePayment from DiscountsTypes where DiscountType = 1))
        update Discounts set ValidOrderCount = ValidOrderCount + 1 where CustomerID = @CustomerID
    else
        update Discounts set TotalOutcome = TotalOutcome + @TotalPrice where CustomerID = @CustomerID
go

CREATE procedure AddToMenu @CourseID Int, @StartDate datetime, @EndDate datetime, @UnitPrice money as
    if @StartDate < getdate()
        throw 2137420, 'Cannot insert backwards', 69

    if ((select CourseID from Menu where CourseID = @CourseID and datediff(day, EndDate, @StartDate) < 14) is not null ) begin
        declare @Exception varchar(100) = 'Cannot reinsert course ' + cast(@CourseID as varchar) + ' to menu within 14 days after previous EndDate';
        throw 2137420, @Exception, 150
    end

    insert into Menu(
        CourseID, StartDate, EndDate, UnitPrice
    )
    values(
        @CourseID, @StartDate, @EndDate, @UnitPrice
    )
go

grant execute on AddToMenu to Manager
go

create procedure AddToOrderDetails @OrderID Int, @CourseID Int, @Quantity Int as
    insert into OrderDetails(
        OrderID,
        CourseID,
        Quantity
    )
    values (
        @OrderID,
        @CourseID,
        @Quantity
    )
go

CREATE procedure AddToOrders @CustomerID Int, @OrderType Int, @Discount Float, @ReceiveDate datetime as
    insert into Orders(
        CustomerID,
        PlacementDate,
        OrderCategoryID,
        IsPaid,
        DiscountValue,
        ReceiveDate
    )
    values (
        @CustomerID,
        getdate(),
        @OrderType,
        0,
        @Discount,
        @ReceiveDate
    )
go

CREATE procedure AddToReservationOrders @ReservationID Int, @OrderIDs OrderIDList readonly as

    declare @OrderID Int

    declare CurrentOrderID cursor
        local static forward_only read_only
    for
        select OrderID
        from @OrderIDs

    open CurrentOrderID
    fetch next from CurrentOrderID into @OrderID

    while @@fetch_status = 0 begin

        insert into ReservationOrders(
        ReservationID, OrderID
        )
        values (
            @ReservationID,
            @OrderID
        )

        fetch next from CurrentOrderID into @OrderID

    end

    close CurrentOrderID
    deallocate CurrentOrderID
go

-- TODO Add
create procedure AddToReservations @CustomerID Int, @ReservationDate datetime as
    insert into Reservations(
        CustomerID,
        ReservationDate,
        PlacementDate
    )
    values (
        @CustomerID,
        @ReservationDate,
        getdate()
    )
go

CREATE procedure AddToReservedTables @ReservationID Int, @Tables TableList readonly as

    declare @TableID varchar(4)
    declare @SittingPeopleCount Int
    declare @SittingPeople varchar(100)

    declare CurrentTableID cursor
        static local forward_only read_only
    for
        select TableID from @Tables

    declare CurrentPeopleCount cursor
        static local forward_only read_only
    for
        select SittingPeopleCount from @Tables

    declare CurrentSittingPeople cursor
        static local forward_only read_only
    for
        select SittingPeople from @Tables

    open CurrentTableID
    open CurrentPeopleCount
    open CurrentSittingPeople

    fetch next from CurrentTableID into @TableID
    fetch next from CurrentPeopleCount into @SittingPeopleCount
    fetch next from CurrentSittingPeople into @SittingPeople

    while @@fetch_status = 0 begin

        exec ReserveTable
            @TableID,
            @ReservationID,
            @SittingPeopleCount,
            @SittingPeople

        fetch next from CurrentTableID into @TableID
        fetch next from CurrentPeopleCount into @SittingPeopleCount
        fetch next from CurrentSittingPeople into @SittingPeople

    end

    close CurrentTableID
    close CurrentPeopleCount
    close CurrentSittingPeople

    deallocate CurrentTableID
    deallocate CurrentPeopleCount
    deallocate CurrentSittingPeople
go

create procedure AddToSeafoodMenu @CourseID Int, @StartDate datetime, @EndDate datetime, @UnitPrice money as
    insert into SeafoodMenu(CourseID, StartDate, EndDate, UnitPrice)
    values(
        @CourseID,
        @StartDate,
        @EndDate,
        @UnitPrice
    )
go

grant execute on AddToSeafoodMenu to Manager
go

create procedure AddToStock @CourseID Int, @Quantity Int as
    update Courses
    set UnitsInStock = UnitsInStock + @QUantity
    where CourseID = @CourseID
go

grant execute on AddToStock to Employee
go

grant execute on AddToStock to Manager
go

CREATE procedure ChangeCourseUnitPrice @CourseID Int, @NewPrice money as
    update Menu
    set UnitPrice = @NewPrice
    where CourseID = @CourseID
    and getdate() between StartDate and EndDate

    update SeafoodMenu
    set UnitPrice = @NewPrice
    where CourseID = @CourseID
    and getdate() between StartDate and EndDate
go

grant execute on ChangeCourseUnitPrice to Manager
go

CREATE function CheckOrderDateCondition(@OrderCategoryID Int, @ReceiveDate datetime)
returns bit
    begin
        return iif(
            @OrderCategoryID = 1 or datediff(hour, @ReceiveDate, getdate()) >= 24,
            1,
            0
        )
    end
go

create function CheckReservationDateCondition(@ReservationDate datetime)
returns bit
    begin
        return iif(
            datediff(hour, @ReservationDate, getdate()) >= 24,
            1,
            0
        )
    end
go

create function CheckSeafoodMenuCourseCategory(@CourseID Int)
returns varchar(50)
begin
    return (
        select top 1 CourseCategoryName
        from Courses
        inner join CourseCategories CC on CC.CourseCategoryID = Courses.CourseCategoryID
        where CourseID = @CourseID
    )
end
go

create procedure ConfirmOrder @OrderID Int, @EmployeeID Int as
    update Orders
    set ConfirmationDate = getdate(), EmployeeID = @EmployeeID
    where OrderID = @OrderID
go

grant execute on ConfirmOrder to Employee
go

grant execute on ConfirmOrder to Manager
go

create procedure ConfirmPayment @OrderID Int as
    update Orders
    set IsPaid = 1
    where OrderID = @OrderID
go

grant execute on ConfirmPayment to Employee
go

grant execute on ConfirmPayment to Manager
go

create procedure ConfirmReservation @ReservationID Int as
    update Reservations
    set ReservationDate = getdate()
    where ReservationID = @ReservationID
go

grant execute on ConfirmReservation to Employee
go

grant execute on ConfirmReservation to Manager
go

CREATE function ConvertToPLN(@Value money, @Currency varchar(50))
returns money
    begin
        return @Value * (
        select top 1 PLNValue
        from Currencies
        where Name like @Currency
        and getdate() between StartDate and EndDate)
    end
go

grant execute on ConvertToPLN to Employee
go

grant execute on ConvertToPLN to Manager
go

CREATE function CourseInMenu(@CourseID Int)
returns bit
    begin
        return iif(
            (select top 1 CourseID
             from Menu
             where CourseID = @CourseID
             and getdate() between StartDate and EndDate
            ) is not null,
            1,
            0
        )
    end
go

grant execute on CourseInMenu to Employee
go

grant execute on CourseInMenu to Manager
go

create function CourseInStock(@CourseID Int)
returns bit
    begin
        declare @Result Int = (
            select top 1 UnitsInStock
            from Courses
            where CourseID = @CourseID
        );

        return iif(
            @Result is not null and @Result > 0,
            1,
            0
        )
    end
go

grant execute on CourseInStock to Employee
go

grant execute on CourseInStock to Manager
go

CREATE procedure CreateDiscountProfile @CustomerID Int, @DiscountType Int as
    insert into Discounts (
        CustomerID,
        DiscountType
    )
    values (
        @CustomerID,
        @DiscountType
    )
go

CREATE procedure CreateInvoiceProfile
    @CustomerID Int,
    @CustomerName varchar(50),
    @Address varchar(50),
    @PostalCode varchar(6),
    @City varchar(50),
    @Country varchar(50),
    @NIP varchar(10)
    as

    insert into InvoiceData (
        CustomerID,
        CompanyName,
        Address,
        PostalCode,
        City,
        Country,
        NIP
    )
    values (
        @CustomerID,
        @CustomerName,
        @Address,
        @PostalCode,
        @City,
        @Country,
        @NIP
    )
go

create procedure DenyInvoicePermission @EmployeeID Int as
    update Employees
    set InvoicePermission = 0
    where EmployeeID = @EmployeeID
go

grant execute on DenyInvoicePermission to Manager
go

create procedure DenyOrderPermission @EmployeeID Int as
    update Employees
    set OrderPermission = 0
    where EmployeeID = @EmployeeID
go

grant execute on DenyOrderPermission to Manager
go

create procedure DenyReportPermission @EmployeeID Int as
    update Employees
    set ReportPermission = 0
    where EmployeeID = @EmployeeID
go

grant execute on DenyReportPermission to Manager
go

create procedure DenyReservationPermission @EmployeeID Int as
    update Employees
    set ReservationPermission = 0
    where EmployeeID = @EmployeeID
go

grant execute on DenyReservationPermission to Manager
go

create procedure DropDiscount @DiscountID Int as

    declare @CustomerID Int = (select top 1 CustomerID from Discounts where DiscountID = @DiscountID);
    declare @DiscountType Int = (select top 1 DiscountType from Discounts where DiscountID = @DiscountID);

    insert into ExpiredDiscounts(
        CustomerID, DiscountType, StartDate, EndDate
    )
    values(
        @CustomerID,
        @DiscountType,
        (select top 1 Discounts.StartDate
        from Discounts
        where DiscountID = @DiscountID),
        (select top 1 Discounts.EndDate
        from Discounts
        where DiscountID = @DiscountID)
    );

    delete from Discounts
    where DiscountID = @DiscountID;

    exec CreateDiscountProfile @CustomerID, @DiscountType
go

grant execute on DropDiscount to Employee
go

grant execute on DropDiscount to Manager
go

CREATE function GetDiscount(@CustomerID Int)
returns float
    begin
        declare @DiscountType Int = (
            select top 1 DiscountType
            from Customers
            where CustomerID = @CustomerID
        )

        declare @Discount Float = 0.0

        if(@DiscountType is not null) begin
            set @Discount = (
                select top 1 Discount
                from DiscountsTypes
                where DiscountType = @DiscountType
                and exists(
                    select DiscountID
                    from Discounts
                    where CustomerID = @CustomerID
                    and StartDate is not null
                )
            )

            if @Discount is null begin set @Discount = 0 end
        end

        return @Discount
    end
go

grant execute on GetDiscount to Employee
go

grant execute on GetDiscount to Manager
go

CREATE FUNCTION GetMenuFrom(@Date datetime)
RETURNS TABLE
AS
RETURN
    SELECT Menu.CourseID, CourseName, UnitPrice
    FROM Menu
    INNER JOIN Courses ON Courses.CourseID = Menu.CourseID
    WHERE @Date BETWEEN StartDate AND EndDate
go

grant select on GetMenuFrom to Employee
go

grant select on GetMenuFrom to Manager
go

CREATE FUNCTION GetSeafoodMenuFrom(@date datetime)
RETURNS TABLE
AS
RETURN
    SELECT SeafoodMenu.CourseID, CourseName, UnitPrice
    FROM SeafoodMenu
    INNER JOIN Courses C on C.CourseID = SeafoodMenu.CourseID
    WHERE @date BETWEEN StartDate AND EndDate
go

grant select on GetSeafoodMenuFrom to Employee
go

grant select on GetSeafoodMenuFrom to Manager
go

create function GetSeats(@TableID varchar(4))
returns Int
    begin
        return (select top 1 Seats from Tables where TableID like @TableID)
    end
go

grant execute on GetSeats to Employee
go

grant execute on GetSeats to Manager
go

create function getUnitPrice(@CourseID Int)
returns money
    begin
        return (
            select top 1 UnitPrice
            from Menu
            where CourseID = @CourseID
        )
    end
go

grant execute on GetUnitPrice to Employee
go

grant execute on GetUnitPrice to Manager
go

create procedure GrantInvoicePermission @EmployeeID Int as
    update Employees
    set InvoicePermission = 1
    where EmployeeID = @EmployeeID
go

grant execute on GrantInvoicePermission to Manager
go

create procedure GrantOrderPermission @EmployeeID Int as
    update Employees
    set OrderPermission = 1
    where EmployeeID = @EmployeeID
go

grant execute on GrantOrderPermission to Manager
go

create procedure GrantReportPermission @EmployeeID Int as
    update Employees
    set ReportPermission = 1
    where EmployeeID = @EmployeeID
go

grant execute on GrantReportPermission to Manager
go

create procedure GrantReservationPermission @EmployeeID Int as
    update Employees
    set ReservationPermission = 1
    where EmployeeID = @EmployeeID
go

grant execute on GrantReservationPermission to Manager
go

CREATE function IsTableFree(@TableID varchar(4), @Date datetime)
returns bit
    begin
        return iif(
            (
            select top 1 TableID
            from ReservedTables
            where TableID = @TableID
                and exists(
                select ReservationID
                from Reservations
                where Reservations.ReservationID = ReservedTables.ReservationID
                    and datediff(hour, ReservationDate, @Date) between 0 and 1.5
            )
        ) is null,
            1,
            0
        )
    end
go

grant execute on IsTableFree to Employee
go

grant execute on IsTableFree to Manager
go

CREATE procedure MakeReservation
    @CustomerID Int,
    @PlacedOrders OrderIDList readonly,
    @ReservationDate datetime,
    @TablesToReserve TableList readonly
    as
    
    if dbo.CheckReservationDateCondition(@ReservationDate) = 0
        throw 2137420, 'Reservations must be made in advancement of minimum 24 hours', 69

    if (select top 1 IsCompany from Customers where CustomerID = @CustomerID) = 0 and exists(select * from @PlacedOrders) begin
        throw 2137420, 'Individual customer cannot make reservation without placing any order', 150
    end

    if ((select top 1 IsCompany from Customers where CustomerID = @CustomerID) = 0 and (select min(SittingPeopleCount) from @TablesToReserve) <= 2)
        throw 2137420, 'Individual customer cannot reserve table for less than 3 people', 69

    exec AddToReservations @CustomerID, @ReservationDate

    declare @ReservationID Int = (
        select top 1 ReservationID
        from Reservations
        where CustomerID = @CustomerID
        and datediff(second, PlacementDate, getdate()) <= 5
    )

    exec AddToReservationOrders @ReservationID, @PlacedOrders

    exec AddToReservedTables @ReservationID, @TablesToReserve
go

grant execute on MakeReservation to Employee
go

grant execute on MakeReservation to Manager
go

CREATE procedure PlaceOrder @CustomerID Int, @Items OrderList readonly, @OrderType Int, @ReceiveDate datetime = null as
    if dbo.CheckOrderDateCondition(@OrderType, @ReceiveDate) = 0
        throw 2147420, 'Orders must be placed in advance of minimum 24 hours', 150

    exec ValidateOrderList @Items;
    exec SeafoodFilter @Items

    declare @CurrentDiscount Float = dbo.GetDiscount(@CustomerID);

    exec AddToOrders
        @CustomerID,
        @OrderType,
        @CurrentDiscount,
        @ReceiveDate;

    declare @OrderID Int = (
        select distinct OrderID
        from Orders
        where CustomerID = @CustomerID
        and datediff(second, PlacementDate, getdate()) between 0 and 5
    )

    -- Add every record of @Items to OrderDetails, reduce UnitsInStock
    declare @CourseID Int
    declare @Quantity Int

    declare CurrentCourse Cursor
        local static read_only forward_only
    for
        select CourseID
        from @Items

    declare CurrentQuantity Cursor
        local static forward_only read_only
    for
        select Quantity
        from @Items

    open CurrentQuantity
    fetch next from CurrentQuantity into @Quantity

    open CurrentCourse
    fetch next from CurrentCourse into @CourseID

    while @@fetch_status != -1 begin
        exec AddToOrderDetails @OrderID, @CourseID, @Quantity

        update Courses
        set UnitsInStock = UnitsInStock - @Quantity
        where CourseID = @CourseID

        fetch next from CurrentCourse into @CourseID
        fetch next from CurrentQuantity into @Quantity
    end

    close CurrentCourse
    close CurrentQuantity

    deallocate CurrentCourse
    deallocate CurrentQuantity

    declare @TotalPrice money = (
        select sum(dbo.getUnitPrice(CourseID) * Quantity)
        from OrderDetails
        where OrderID = @OrderID
    );

    update Orders
    set Price = @TotalPrice
    where OrderID = @OrderID;

    exec AddToDiscount @CustomerID, @TotalPrice;
go

grant execute on PlaceOrder to Employee
go

grant execute on PlaceOrder to Manager
go

CREATE procedure PlaceOrderSeafood @CustomerID Int, @CourseID Int, @ReceiveDate datetime as
    if (
        (
        select top 1 CourseCategoryName
        from CourseCategories
        where CourseCategoryID = (
            select top 1 CourseCategoryID
            from Courses
            where CourseID = @CourseID
        )
        ) not like 'owoce morza'
    )
        throw 694202137, 'Cannot order non-Seafood dish that way', 150
    
    if(0!=0)
        throw 2137420, 'Seafood dishes can be ordered in advancement of minimum 3 days, at most on Monday preceding order date', 68

    declare @CurrentDiscount float = dbo.GetDiscount(@CustomerID);

    exec AddToOrders
        @CustomerID,
        3,
        @CurrentDiscount,
        @ReceiveDate;

    declare @OrderID Int = (
        select top 1 OrderID
        from Orders
        where CustomerID = @CustomerID
        and OrderCategoryID = 0
        and datediff(second, PlacementDate, getdate()) <= 5
    );

    exec AddToOrderDetails @OrderID, @CourseID, 1
go

grant execute on PlaceOrderSeafood to Employee
go

grant execute on PlaceOrderSeafood to Manager
go

create procedure ReserveTable @TableID varchar(4), @ReservationID Int, @SittingPeopleCount Int, @SittingPeople varchar(100) as
    insert into ReservedTables(
        TableID,
        ReservationID,
        OccupiedSeats,
        SittingPeople
    )
    values(
       @TableID,
       @ReservationID,
       @SittingPeopleCount,
       @SittingPeople
    )
go

grant execute on ReserveTable to Employee
go

grant execute on ReserveTable to Manager
go

CREATE procedure SeafoodFilter @Items OrderList readonly as
    declare @CourseID Int

    declare CurrentCourse Cursor
        local static read_only forward_only
    for
        select CourseID
        from @Items

    open CurrentCourse
    fetch next from CurrentCourse into @CourseID

    while @@fetch_status = 0 begin
        if (
            select top 1 CourseCategoryID
            from Courses
            where CourseID = @CourseID
            and CourseCategoryID = (
                select top 1 CourseCategoryID
                from CourseCategories
                where CourseCategoryName like 'owoce morza'
            )
        ) is not null begin
            throw 213769, 'Cannot order seafood that way', 150
        end
        else
            fetch next from CurrentCourse into @CourseID
    end

    close CurrentCourse
    deallocate CurrentCourse
go

CREATE procedure ValidateOrderList @Items OrderList readonly as
    declare @CourseID Int

    declare CurrentCourse Cursor
        local static read_only forward_only
    for
        select CourseID
        from @Items

    open CurrentCourse
    fetch next from CurrentCourse into @CourseID

    while @@fetch_status = 0 begin
        if dbo.CourseInMenu(@CourseID) = 0 begin
            declare @Exception_1 varchar(50) = cast(@CourseID as varchar) + ' is not available in current menu';
            throw 123456, @Exception_1, 1234
        end

        if dbo.CourseInStock(@CourseID) = 0 begin
            declare @Exception_2 varchar(50) = cast(@CourseID as varchar) + ' is out of stock';
            throw 123456, @Exception_2, 1234
        end
        fetch next from CurrentCourse into @CourseID
    end

    close CurrentCourse
    deallocate CurrentCourse
go


