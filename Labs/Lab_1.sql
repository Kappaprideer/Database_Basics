
-- 1.
SELECT CompanyName, Address
FROM Customers
WHERE City='London'

-- 2.
SELECT CompanyName, Address
from Customers
WHERE City='London' OR City='Madrid'

-- 3.
SELECT ProductName
FROM Products
WHERE UnitPrice>40

-- 4.
SELECT ProductName
FROM Products
WHERE UnitPrice>40
ORDER BY UnitPrice

-- 5.
SELECT DISTINCT COUNT(ProductID)
FROM Products
WHERE UnitPrice>40

-- 6.
SELECT DISTINCT COUNT(ProductName)
FROM Products
WHERE UnitPrice>40 AND UnitsInStock>100

-- 7.
SELECT DISTINCT COUNT(ProductName)
FROM Products
WHERE UnitPrice>40 AND UnitsInStock>100 AND CategoryID BETWEEN 2 and 3

-- 8.
SELECT ProductName,UnitPrice
from Products,Categories
WHERE CategoryName LIKE 'Seafood'

-- 9.
SELECT COUNT(EmployeeID)
from Employees
WHERE YEAR(BirthDate)<1960 AND City='London'

-- 10.
SELECT TOP 5 FirstName, LastName
from Employees
order by YEAR(BirthDate)

-- 11.
SELECT DISTINCT COUNT(EmployeeID)
from Employees
WHERE (YEAR(BirthDate) BETWEEN 1950 AND 1955) OR (YEAR(BirthDate) BETWEEN 1958 and 1960)

-- 12.
SELECT ProductName
from Products
WHERE Discontinued='false'

-- 13.
SELECT OrderID, CustomerID, OrderDate
FROM Orders
WHERE OrderDate<'09-01-1996'

-- 14.
SELECT *
FROM Customers
WHERE CompanyName LIKE '%the%'

-- 15.
SELECT *
FROM Customers
WHERE CompanyName LIKE 'B%' OR CompanyName LIKE 'W%'

-- 16.
SELECT *
FROM Products
WHERE (ProductName='C%') OR (ProductID<40 AND UnitPrice>20)
ORDER BY ProductId DESC

-- 17.
-- 18.
-- 19.

-- 20.
SELECT CompanyName,Country,Fax,HomePage
FROM Suppliers
WHERE Fax=0 AND HomePage IS NULL AND (Country='USA' OR Country='Germany')

-- 21.
SELECT COUNT(ProductID)
FROM Products
WHERE QuantityPerUnit LIKE '%jar%' OR QuantityPerUnit LIKE '%glass%'

-- 22.
SELECT CategoryName, Count(ProductName) AS 'NumberOfProducts'
FROM Categories, Products
WHERE Products.CategoryID=Categories.CategoryID
GROUP BY CategoryName
ORDER BY 2 DESC

-- 23.
SELECT CategoryName, SUM(UnitsInStock) AS 'SumOfUnitsInStock'
FROM Categories, Products
WHERE Categories.CategoryID=Products.CategoryID
GROUP BY CategoryName
ORDER BY 2
