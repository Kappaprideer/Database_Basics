-- Część 1:

-- 1.
SELECT COUNT(ProductID) AS Minimum
FROM Products
WHERE UnitPrice>10 OR UnitPrice<30

-- 2.
SELECT MAX(UnitPrice) AS Maximum
FROM Products
WHERE UnitPrice < 20

-- 3.
SELECT MAX(UnitPrice) AS Maximum, MIN(UnitPrice) AS Minimum, AVG(UnitPrice) AS Average
FROM Products
WHERE QuantityPerUnit Like '%bottle%'

-- 4.
SELECT *
FROM Products
WHERE UnitPrice > (SELECT  AVG(UnitPrice) FROM Products)

--5.
SELECT (Quantity*UnitPrice)-(UnitPrice*Discount) AS 'Wartość zamówienia'
FROM [Order Details]
WHERE OrderID=10250

-- Część 2.

-- 1.
SELECT OrderID, MAX(UnitPrice) AS MAximumPrice
FROM [Order Details]
GROUP BY OrderID

-- 2.
SELECT OrderID, MAX(UnitPrice) AS MAximumPrice
FROM [Order Details]
GROUP BY OrderID
ORDER BY 2

-- 3.
SELECT OrderID, MAX(UnitPrice) AS MaximumPrice, MIN(UnitPrice) AS MinimumPrice
FROM [Order Details]
GROUP BY OrderID

-- 4.
SELECT Shippers.CompanyName, COUNT(OrderID)
FROM Shippers, Orders
WHERE ShipperID = Orders.ShipVia
GROUP BY Shippers.CompanyName

-- 5.
SELECT TOP 1 Shippers.CompanyName, COUNT(OrderID)
FROM Shippers, Orders
WHERE ShipperID = Orders.ShipVia AND YEAR(OrderDate)=1997
GROUP BY Shippers.CompanyName
ORDER BY 2 DESC

-- Część 3.

-- 1.
SELECT Orders.OrderID, COUNT([Order Details].OrderID)
FROM Orders, [Order Details]
WHERE Orders.OrderID=[Order Details].OrderID
GROUP BY Orders.OrderID HAVING COUNT([Order Details].OrderID)>5
ORDER BY 2 DESC

-- 2.
SELECT Customers.CompanyName, COUNT([Order Details].OrderID) AS 'Number of orders', SUM(Quantity*UnitPrice*(1-Discount)) AS 'Price sum'
FROM Customers, Orders, [Order Details]
WHERE Customers.CustomerID=Orders.CustomerID AND YEAR(OrderDate)=1998 AND [Order Details].OrderID=Orders.OrderID AND Orders.ShippedDate is not null
GROUP BY CompanyName HAVING COUNT([Order Details].OrderID)>8
ORDER BY 3 DESC
