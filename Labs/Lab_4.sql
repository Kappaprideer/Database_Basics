USE Northwind2

-- 1.
Select ProductName,UnitPrice, S.Address
from Products AS P, Suppliers AS S
where (UnitPrice BETWEEN 20 AND 30) AND P.SupplierID=S.SupplierID

-- 2.
SELECT ProductName, UnitsInStock
FROM Products AS P, Suppliers AS S
WHERE P.SupplierID=S.SupplierID AND S.CompanyName LIKE 'Tokyo Traders'

--Błędnie zrobione
-- 3.
SELECT C.Address
FROM Customers AS C INNER JOIN Orders AS O on C.CustomerID=O.CustomerID
WHERE (
    SELECT Customers.CustomerID
    FROM Customers, Orders
    WHERE Customers.CustomerID=Orders.CustomerID AND YEAR(Orders.OrderDate)=1997

    GROUP BY Customers.CustomerID HAVING COUNT(O.OrderID)=0)=CustomerID

-- 4.
SELECT DISTINCT S.CompanyName, S.Phone
FROM Suppliers AS S INNER JOIN Products AS P ON S.SupplierID=P.SupplierID
WHERE P.Discontinued = 'false'

-- 5.
SELECT P.ProductName, P.UnitPrice, S.Address
FROM Products AS P, Suppliers AS S, Categories AS C
WHERE (P.UnitPrice BETWEEN 20 AND 30) AND C.CategoryName LIKE 'Meat/Poultry' AND C.CategoryID=P.CategoryID AND P.SupplierID=S.SupplierID

-- 6.
SELECT ProductName, UnitPrice, Suppliers.CompanyName
FROM Products, Categories, Suppliers
WHERE Categories.CategoryName LIKE 'Confections' AND Products.CategoryID=Categories.CategoryID AND Suppliers.SupplierID=Products.SupplierID

-- 7.

USE Northwind2
SELECT lastname, employeeid
FROM employees AS e
WHERE EXISTS (SELECT * FROM orders AS o
WHERE e.employeeid = o.employeeid AND o.OrderDate = '9/5/97')


USE Northwind2
SELECT DISTINCT lastname, e.employeeid
FROM orders AS o
INNER JOIN employees AS e
ON o.employeeid = e.employeeid
WHERE o.orderdate = '9/5/1997'
