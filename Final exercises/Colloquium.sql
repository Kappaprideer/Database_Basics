USE Northwind2

-- 1.
SELECT COUNT(EmployeeID) AS 'Number_of_employees'
FROM Employees AS E
WHERE ((YEAR(BirthDate) BETWEEN 1954 AND 1953) OR (YEAR(BirthDate) BETWEEN  1955 AND 1957) OR (YEAR(BirthDate) BETWEEN 1959 AND 1962)) AND (City not like 'London' AND City not like 'Seattle')

-- 2.
SELECT P.ProductName, P.UnitPrice, S.Address
FROM Products AS P
    INNER JOIN Suppliers S on S.SupplierID = P.SupplierID
    INNER JOIN Categories C on C.CategoryID = P.CategoryID
WHERE (C.CategoryName like 'Meat/Poultry') AND (P.UnitPrice BETWEEN 20 AND 30)

-- 3.
SELECT O.OrderID, C.CompanyName, S.CompanyName, O.Freight
FROM Orders AS O
    INNER JOIN Shippers S on S.ShipperID = O.ShipVia
    INNER JOIN Customers C on O.CustomerID = C.CustomerID
WHERE  O.Freight < (0.7)*(SELECT AVG(O2.Freight)
                          FROM Orders AS O2
                          WHERE MONTH(O2.OrderDate) BETWEEN 1 AND 3)
ORDER BY S.CompanyName


-- 4.
SELECT P.ProductName, P.UnitPrice, S.Address
FROM Products AS P
    INNER JOIN Suppliers S on P.SupplierID = S.SupplierID
WHERE P.UnitPrice BETWEEN 20 AND 30
ORDER BY P.ProductName

-- 5.
SELECT C.CompanyName, C.Address
FROM Customers AS C
WHERE CustomerID NOT IN(SELECT C2.CustomerID
                        FROM Customers AS C2
                            INNER JOIN Orders O on C2.CustomerID = O.CustomerID
                        WHERE YEAR(O.OrderDate)=1997)

-- 6.
SELECT DISTINCT C.CompanyName, C.Phone
FROM Customers AS C
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
    INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
    INNER JOIN Products P on P.ProductID = [O D].ProductID
    INNER JOIN Categories C2 on P.CategoryID = C2.CategoryID
WHERE C2.CategoryName like 'Confections'