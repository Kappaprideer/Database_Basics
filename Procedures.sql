-- Procedures

create procedure AddCourse @CourseName: varchar(50), @CourseCategory: varchar(50), @UnitPrice: money as
    insert into Courses(
        CourseName,
        CourseCategoryID,
        UnitPrice,
        UnitsInStock
    )
    values (
        @CourseName,
        (select distinct CourseCategoryID from CourseCategories where CourseCategoryName like @CourseCategory),
        @UnitPrice,
        0
    )
go


create procedure RemoveCourse @CourseID: Int as
    delete from Courses
    where CourseID = @CourseID
go


create procedure AddCategory @CategoryName: varchar(50), @Description: text as
    insert into CourseCategories(
        CourseCategoryName,
        Description
    )
    values (
        @CategoryName,
        @Description
    )
go


create procedure RemoveCategory @CategoryID: Int as
    delete from CourseCategories
    where CourseCategoryID = @CategoryID
go


create procedure AddEmployee @FirstName: varchar(50), @LastName: varchar(50) as
    insert into Employees (
        LastName,
        FirstName
    )
    values (
        @LastName,
        @FirstName
    )
go


create procedure RemoveEmployee @EmployeeID: Int as
    delete from Employees
    where EmployeeID = @EmployeeID
go


create procedure GrantReportPermission @EmployeeID: Int as
    update Employees
    set ReportPermission = 1
    where EmployeeID = @EmployeeID
go


create procedure GrantOrderPermission @EmployeeID: Int as
    update Employees
    set OrderPermission = 1
    where EmployeeID = @EmployeeID
go


create procedure GrantInvoicePermission @EmployeeID: Int as
    update Employees
    set InvoicePermission = 1
    where EmployeeID = @EmployeeID
go


create procedure DenyReportPermission @EmployeeID: Int as
    update Employees
    set ReportPermission = 0
    where EmployeeID = @EmployeeID
go


create procedure DenyOrderPermission @EmployeeID: Int as
    update Employees
    set OrderPermission = 0
    where EmployeeID = @EmployeeID
go


create procedure DenyInvoicePermission @EmployeeID: Int as
    update Employees
    set InvoicePermission = 0
    where EmployeeID = @EmployeeID
go


create procedure AddTable @TableID: varchar(4), @Seats: Int as
    insert into Tables(
        TableID,
        Seats
    )
    values (
        @TableID,
        @Seats
    )
go


create procedure RemoveTable @TableID: varchar(50) as
    delete from Tables
    where TableID like @TableID
go


create procedure ChangeCourseUnitPrice @CourseID: int, @NewPrice: money as
    update Courses
    set UnitPrice = @NewPrice
    where CourseID = @CourseID
go


create procedure CreateInvoiceProfile
    @CustomerID: Int,
    @CustomerName: varchar(50),
    @Address: varchar(50) = null,
    @PostalCode: varchar(6) = null,
    @City: varchar(50) = null,
    @Country: varchar(50) = null,
    @NIP: varchar(10) = null
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

create procedure CreateDiscountProfile @CustomerID: Int, @DiscountType: bit as
    insert into Discounts (
        CustomerID,
        DiscountType
    )
    values (
        @CustomerID,
        @DiscountType
    )
go


create procedure AddCustomer
    @CustomerName: varchar(50),
    @CustomerCategoryID: bit,
    @Address: varchar(50) = null,
    @PostalCode: varchar(6) = null,
    @City: varchar(50) = null,
    @Country: varchar(50) = null,
    @NIP: varchar(10) = null,
    @DiscountType: bit = 0
    as

    insert into Customers (
        CustomerName,
        CustomerCategoryID
    )
    values (
        @CustomerName,
        @CustomerCategoryID
    );

    declare @CustomerID: Int = (select top 1 CustomerID from Customers where CustomerName like @CustomerName);

    CreateInvoiceProfile
        @CustomerID,
        @CustomerName,
        @Address,
        @PostalCode,
        @City,
        @Country,
        @NIP;

    CreateDiscountProfile
        @CustomerID,
        @DiscountType;
go


-- Table-type for representing order as a list of Course-Quantity pairs
create type OrderList as table (
    CourseID Int not null check (CourseInMenu(OrderID) = 1),  -- TODO Fix name
    Quantity Int check (Count > 0)
)


create procedure AddToOrders @CustomerID: Int, @EmployeeID: Int, @OrderName: varchar(50), @OrderType: bit, @Discount: Float as
    insert into Orders(
       CustomerID,
       EmployeeID,
       OrderName,
       PlacementDate,
       Orders.Type,
       Payment,
       DiscountValue
    )
    values (
        @CustomerID,
        @EmployeeID,
        @OrderName,
        getdate(),
        @OrderType,
        0,
        @Discount
    )
go


create procedure AddToOrderDetails @OrderID: Int, @CourseID: Int, @Quantity: Int as
    insert into OrderDetails(
        OrderID,
        CourseID,
        Quantity,
        UnitPrice
    )
    values (
        @OrderID,
        @CourseID,
        @Quantity,
        (select top 1 UnitPrice from Courses where CourseID = @CourseID)
    )
go


create procedure AddToDiscount @CustomerID: Int, @TotalPrice: money as
    if ((select top 1 DiscountType from Discounts where CustomerID = @CustomerID) = 0)
        update Discounts set ValidOrderCount = ValidOrderCount + 1 where CustomerID = @CustomerID -- TODO check minimal price
    else
        update Discounts set TotalOutcome = TotalOutcome + @TotalPrice where CustomerID = @CustomerID
go

-- TODO: delete EmployeeID
create procedure PlaceOrder @CustomerID: Int, @EmployeeID: Int, @Items: OrderList, @OrderName: varchar(50), @OrderType: bit as
    AddToOrders
        @CustomerID,
        @EmployeeID,
        @OrderName,
        @OrderType,
        GetDiscount(@CustomerID);

    -- TODO - seafood filter

    declare @OrderID: Int = (
        select top 1 OrderID
        from Orders
        where CustomerID = @CustomerID and datediff(second, PlacementDate, getdate()) <= 5
    );

    -- Add every record of @Items to OrderDetails, reduce UnitsInStock
    declare @CourseID: Int
    declare @Quantity: Int

    declare CurrentCourse Cursor
        local static read_only forward_only
    for
        select distinct CourseID
        from @Items

    declare CurrentQuantity Cursor
        local static forward_only read_only
    for
        select distinct Quantity
        from @Items

    open CurrentQuantity
    fetch next from CurrentQuantity into @Quantity

    open CurrentCourse
    fetch next from CurrentCourse into @CourseID

    while @@fetch_status = 0 begin
        AddToOrderDetails @OrderID, @CourseID, @Quantity

        update Courses
        set UnitsInStock = UnitsInStock - @Quantity
        where CourseID = @CourseID

        fetch next from CurrentCourse into @OrderID
        fetch next from CurrentQuantity into @Quantity
    end

    close CurrentCourse
    close CurrentQuantity

    deallocate CurrentCourse
    deallocate CurrentQuantity

    declare @TotalPrice: money = (
        select sum(UnitPrice * Quantity)
        from OrderDetails
        where OrderID = @OrderID
    ) * (1 - GetDiscount(@CustomerID));

    update Orders
    set Price = @TotalPrice
    where OrderID = @OrderID;

    AddToDiscount @CustomerID, @TotalPrice;
go


create procedure ConfirmOrder @OrderID: Int as
    update Orders
    set ConfirmationDate = getdate()
    where OrderID = @OrderID
go


create procedure CompleteOrder @OrderID: Int as
    update Orders
    set RecieveDate = getdate()
    where OrderID = @OrderID
go


