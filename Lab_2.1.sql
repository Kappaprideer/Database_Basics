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
SELECT *
FROM Orders
WHERE YEAR(OrderDate)=1997

