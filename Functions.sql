-- Functions

create function GetSeats(@TableID: varchar(4))
returns Int
    begin
        return (select top 1 Seats from Tables where TableID like @TableID)
    end


create function CheckForDiscount(@CustomerID: Int)
returns bit
    begin
        declare @TotalOrderCount: Int = (select top 1 TotalOrderCount from Discounts where CutomerID = @CustomerID);
        declare @TotalOutcome: money = (select top 1 TotalOutcome from Discounts where CustomerID = @CustomerID);
        declare @MinimalOrderCount: Int = (select top 1 MinimalOutcome from DiscountTypes where DiscountType = 0);
        declare @MinimalOutcome: money = (select top 1 MinimalOutcome from DiscountTypes where DiscountType = 1);

        return iif(
            (select top 1 DiscountType from DiscountTypes where CustomerID = @CustomerID) = 0,
            @TotalOrderCount >= @MinimalOrderCount,
            @TotalOutcome >= @MinimalOutcome
        )
    end


create function GetDiscount(@CustomerID: Int)
returns float
    begin
        return iif(
            CheckForDiscount(@CustomerID) = 1,
            (
                select top 1 Discount
                from DiscountTypes
                where DiscountType = (
                    select top 1 DiscountType
                    from Discounts
                    where CustomerID = @CustomerID
                )
            ),
            0.0
        )
    end


create function ConvertToPLN(@Value: money, @Currency: varchar(50))
returns money
    begin
        return @Value * (select top 1 PLNValue from Currencies where Name like @Currency)
    end


create function CourseInStock(@CourseID: Int)
returns bit
    begin
        return (
            select top 1 UnitsInStock
            from Courses
            where CourseID = @CourseID
        ) > 0
    end


create function CourseInMenu(@CourseID: Int)
returns bit
    begin
        return (
            select top 1 CourseID
            from Menu
            where CourseID = @CourseID
        ) is not null
    end


create function MonthPayment(@CustomerID: Int)
returns money
    begin
        return (
            select sum(TotalPrice)
            from Orders
            where datediff(day, OrderDate, getdate()) <= 31 and datediff(month, OrderDate, getdate()) <= 1
        )
    end


create function CustomerOrderReport(@CustomerID: Int, @FromDate: DateTime)
returns Table(OrderID: Int, Price: Money, Discount: Float, PlacementDate: DateTime)
    begin
        return (
            select OrderID, Price, Discount, PlacementDate
            from Orders
            where datediff(day, PlacementDate, @FromDate) >= 0
            and CustomerID = @CustomerID
        )
    end


create function GeneralOrderReport(@FromDate: DateTime, @CustomerCategoryID: bit)
returns Table(OrderID: Int, Price: Money, Discount: Float, PlacementDate: DateTime)
    begin
        return (
            select OrderID, Price, Discount, PlacementDate
            from Orders as O
            inner join Customers C
            on C.CustomerID = O.CustomerID
            where datediff(day, PlacementDate, @FromDate) >= 0
            and C.CustomerCategoryID = @CustomerCategoryID
        )
    end