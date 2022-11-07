USE Northwind2

-- 1.
SELECT SUM((Quantity*UnitPrice)-(UnitPrice*Discount) )AS 'Wartość zamówienia 10250'
FROM [Order Details]
WHERE OrderID=10250

-- 2.
SELECT OrderID, MAX(UnitPrice) AS Max_Price
FROM [Order Details]
GROUP BY OrderID
ORDER BY 2

-- 3.
SELECT OrderID, MAX(UnitPrice) AS Max_Price, MIN(UnitPrice) AS Min_Price
FROM [Order Details]
GROUP BY OrderID

-- 4.
SELECT MAX(UnitPrice) - MIN(UnitPrice)
FROM [Order Details]
GROUP BY OrderID

SELECT ProductID, AVG( SELECT MAX(UnitPrice) - MIN(UnitPrice) FROM [Order Details] GROUP BY ProductID)
FROM [Order Details]
GROUP BY ProductID


-- 5.
SELECT Shippers.CompanyName, COUNT([Order Details].OrderID)
FROM Shippers, Orders, [Order Details]
WHERE Shippers.ShipperID=Orders.ShipVia AND [Order Details].OrderID=Orders.OrderID
GROUP BY Shippers.CompanyName

-- 6.
SELECT TOP 1 Shippers.CompanyName, COUNT([Order Details].OrderID) AS Number_of_Orders_in_1997
FROM Shippers, Orders, [Order Details]
WHERE Shippers.ShipperID=Orders.ShipVia AND [Order Details].OrderID=Orders.OrderID AND YEAR(Orders.OrderDate)=1997
GROUP BY Shippers.CompanyName
ORDER BY 2

-- 7.
SELECT OrderID, COUNT(OrderID)
FROM [Order Details]
Group BY OrderID HAVING COUNT(OrderID)>5

-- 8.
SELECT Customers.CustomerID, COUNT(Orders.OrderID)
FROM Customers, Orders, [Order Details]
WHERE YEAR(Orders.OrderDate)=1998 AND (Orders.ShippedDate is not null) AND Customers.CustomerID=Orders.CustomerID AND [Orders].OrderID=[Order Details].OrderID
GROUP BY Customers.CustomerID HAVING COUNT(Orders.OrderID)>8
ORDER BY SUM(([Order Details].UnitPrice * [Order Details].Quantity)*(1-[Order Details].Discount)) DESC