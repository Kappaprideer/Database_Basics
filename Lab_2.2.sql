USE Northwind

-- Wybór kolumn/wierszy

-- 1.
SELECT CompanyName, Address
FROM Customers
WHERE City LIKE 'London'

-- 2.
SELECT CompanyName, Address
FROM Customers
WHERE (Country LIKE 'France') OR (Country LIKE 'Spain')

-- 3.
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice BETWEEN 20.00 AND 30.00
ORDER BY UnitPrice

-- 4.
SELECT ProductName, UnitPrice, CategoryName
FROM Products, Categories
WHERE (CategoryName LIKE '%meat%') AND Products.CategoryID=Categories.CategoryID
ORDER BY 1

-- 5.
SELECT ProductName,UnitsInStock,ReorderLevel
FROM Products,Suppliers
WHERE (Suppliers.CompanyName LIKE 'Tokyo Traders') AND Products.SupplierID=Suppliers.SupplierID

-- 6.
SELECT ProductName
FROM Products
WHERE UnitsInStock =0

-- Porównywanie napisów

-- 1.
SELECT *
FROM Products
WHERE QuantityPerUnit LIKE '%bottle%'

-- 2.
SELECT Title, LastName
FROM Employees
WHERE LastName LIKE '[B-L]%'

-- 3.
SELECT Title, LastName
FROM Employees
WHERE LastName LIKE '[BL]%'

-- 4.
SELECT CategoryName, Description
FROM Categories
WHERE Categories.Description LIKE '%,%'

-- 5.
SELECT CompanyName
FROM Customers
WHERE CompanyName LIKE '%store%'

-- Zakres wartości

-- 1.
SELECT *
FROM Products
WHERE UnitPrice<10 OR UnitPrice>20
ORDER BY UnitPrice

-- 2.
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice BETWEEN 20.00 AND 30.00
ORDER BY UnitPrice

-- Warunki logiczne

-- 1.
SELECT OrderID, OrderDate, Orders.CustomerID, Customers.Country, Orders.ShippedDate
FROM Orders, Customers
WHERE (Customers.Country LIKE 'Argentina') AND (Orders.CustomerID=Customers.CustomerID) AND  Orders.ShippedDate is null

-- Order by

-- 1.
