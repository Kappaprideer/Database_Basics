USE Northwind
-- 1.
SELECT OrderID, UnitPrice,Quantity, Quantity*UnitPrice AS 'Value:', UnitPrice*1.15 AS '15% More',
       UnitPrice*[Order Details].Discount AS Discount1,[Order Details].UnitPrice*1.15*Discount AS 'Discount2'
FROM [Order Details]

-- 2.
SELECT 'Pan/Pani ' + FirstName + ' ' + LastName + ' ur. '  + CAST(BirthDate as VARCHAR) + ' zatrudniony w dniu: ' + CAST(HireDate as VARCHAR) + ', adres: ' + Employees.Address + City + PostalCode + Country
FROM Employees
Order BY BirthDate

-- 3.
SELECT TOP 3 'Pan/Pani ' + Employees.FirstName + ' ' + LastName + ', zatrudniony: ' + CAST(HireDate AS varchar)
FROM Employees
ORDER BY HireDate DESC

-- 4.
SELECT COUNT(EmployeeID)
FROM Employees
WHERE Region is NOT NULL

-- 5.
SELECT AVG(UnitPrice) AS 'Średnia Cena:'
FROM Products

-- 6.
SELECT AVG(UnitPrice) AS AveragePirce
FROM Products
WHERE UnitsInStock> 30

-- 7.
SELECT AVG(UnitPrice) AS AveragePrice
FROM Products
WHERE UnitsInStock>(SELECT AVG(UnitsInStock) FROM Products)

-- 8.
SELECT SUM(Quantity)
FROM [Order Details]
WHERE UnitPrice>30

-- 9.
SELECT MAX(UnitPrice) AS Maximum, MIN(UnitPrice) AS Minimum, AVG(UnitPrice) AS Avereage
FROM Products
WHERE QuantityPerUnit LIKE '%bottle%'

-- 10.
SELECT *
FROM Products
WHERE UnitPrice >( SELECT AVG(UnitPrice) FROM Products)
