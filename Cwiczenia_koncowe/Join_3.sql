USE Northwind2

-- Część 1.
-- 1. Dla każdego zamówienia podaj łączną liczbę zamówionych jednostek towaru oraz nazwę klienta.

select OD.OrderID, SUM(OD.Quantity) , C.CompanyName
      FROM [Order Details] AS OD
               Inner JOIN Orders O on OD.OrderID = O.OrderID
               Inner JOIN Customers C on O.CustomerID = C.CustomerID
GROUP BY OD.OrderID, C.CompanyName

-- Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których łączna liczbę zamówionych jednostek jest większa niż 250
select OD.OrderID, SUM(OD.Quantity) AS Quantity_Sum , C.CompanyName
      FROM [Order Details] AS OD
               Inner JOIN Orders O on OD.OrderID = O.OrderID
               Inner JOIN Customers C on O.CustomerID = C.CustomerID
GROUP BY OD.OrderID, C.CompanyName HAVING SUM(OD.Quantity)>250

-- Dla każdego zamówienia podaj łączną wartość tego zamówienia oraz nazwę klienta.
SELECT O.OrderID, SUM(Quantity*[OD].UnitPrice*(1-OD.Discount)), C.CompanyName
    FROM [Order Details] AS OD
        INNER JOIN Orders O on O.OrderID = OD.OrderID
        INNER JOIN Customers C on O.CustomerID = C.CustomerID
GROUP BY O.OrderID, CompanyName

-- Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których łączna liczba jednostek jest większa niż 250.
SELECT O.OrderID, SUM(Quantity*[OD].UnitPrice*(1-OD.Discount)), C.CompanyName
    FROM [Order Details] AS OD
        INNER JOIN Orders O on O.OrderID = OD.OrderID
        INNER JOIN Customers C on O.CustomerID = C.CustomerID
GROUP BY O.OrderID, CompanyName
HAVING SUM(OD.Quantity)>250

-- Zmodyfikuj poprzedni przykład tak żeby dodać jeszcze imię i nazwisko pracownika obsługującego zamówienie
SELECT O.OrderID, SUM(Quantity*[OD].UnitPrice*(1-OD.Discount)), C.CompanyName, E.FirstName, E.LastName
    FROM [Order Details] AS OD
        INNER JOIN Orders O on O.OrderID = OD.OrderID
        INNER JOIN Customers C on O.CustomerID = C.CustomerID
        INNER JOIN Employees E on O.EmployeeID = E.EmployeeID
GROUP BY O.OrderID, CompanyName, E.FIrstName, E.LastName
HAVING SUM(OD.Quantity)>250


-- Ćwiczenie 2.
-- Dla każdej kategorii produktu (nazwa), podaj łączną liczbę zamówionych przez klientów jednostek towarów.
SELECT C.CategoryName, SUM(Quantity)
FROM Categories AS C
    INNER JOIN Products P on C.CategoryID = P.CategoryID
    INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
GROUP BY C.CategoryName

-- Dla każdej kategorii produktu (nazwa), podaj łączną wartość zamówień
SELECT C.CategoryName, SUM(Quantity*[O D].UnitPrice*(1-[O D].Discount)) AS Price
FROM Categories AS C
    INNER JOIN Products P on C.CategoryID = P.CategoryID
    INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
GROUP BY C.CategoryName

-- Posortuj wyniki w zapytaniu z punktu 2 wg:
-- a) łącznej wartości zamówień
SELECT C.CategoryName, SUM(Quantity*[O D].UnitPrice*(1-[O D].Discount)) AS Price
FROM Categories AS C
    INNER JOIN Products P on C.CategoryID = P.CategoryID
    INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
GROUP BY C.CategoryName
ORDER BY 2

-- b) łącznej liczby zamówionych przez klientów jednostek towarów.
SELECT C.CategoryName, SUM(Quantity*[O D].UnitPrice*(1-[O D].Discount)) AS Price
FROM Categories AS C
    INNER JOIN Products P on C.CategoryID = P.CategoryID
    INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
GROUP BY C.CategoryName
ORDER BY SUM([O D].Quantity)

-- Ćwiczenie 3
-- Dla każdego przewoźnika (nazwa) podaj liczbę zamówień które przewieźli w 1997r
SELECT S.CompanyName,COUNT(*)
FROM Suppliers AS S
    INNER JOIN Orders AS O ON O.ShipVia=S.SupplierID
WHERE YEAR(ShippedDate)=1997
GROUP BY S.CompanyName

-- Który z przewoźników był najaktywniejszy (przewiózł największą liczbę zamówień) w 1997r, podaj nazwę tego przewoźnika
SELECT TOP 1 S.CompanyName,COUNT(*)
FROM Suppliers AS S
    INNER JOIN Orders AS O ON O.ShipVia=S.SupplierID
WHERE YEAR(ShippedDate)=1997
GROUP BY S.CompanyName
ORDER BY 2 DESC

-- Który z pracowników obsłużył największą liczbę zamówień w 1997r, podaj imię i nazwisko takiego pracownika
SELECT TOP 1 FirstName, LastName, COUNT(*)
FROM Employees AS E
    INNER JOIN Orders O on E.EmployeeID = O.EmployeeID
WHERE YEAR(OrderDate)=1997
GROUP BY FirstName, LastName
ORDER BY 3 DESC

-- Ćwiczenie 4
-- Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień obsłużonych przez tego pracownika
SELECT FirstName, LastName, ROUND(SUM(Quantity*UnitPrice*(1-Discount)),2) AS total_value
FROM Employees AS E
    INNER JOIN Orders O on E.EmployeeID = O.EmployeeID
    INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
GROUP BY FirstName, LastName, E.EmployeeID

-- Który z pracowników był najaktywniejszy (obsłużył zamówienia o największej wartości) w 1997r, podaj imię i nazwisko takiego pracownika
SELECT TOP 1 FirstName, LastName, ROUND(SUM(Quantity*UnitPrice*(1-Discount)),2) AS total_value
FROM Employees AS E
    INNER JOIN Orders O on E.EmployeeID = O.EmployeeID
    INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
WHERE YEAR(OrderDate)=1997
GROUP BY FirstName, LastName, E.EmployeeID
ORDER BY 3 DESC

-- Ogranicz wynik z pkt 1 tylko do pracowników:
-- a) którzy mają podwładnych
SELECT E.FirstName, E.LastName,
       ROUND(SUM(Quantity*UnitPrice*(1-Discount)),2) AS total_value
FROM Employees AS E
    INNER JOIN Employees AS E2 ON E.EmployeeID=E2.ReportsTo
    INNER JOIN Orders O on E.EmployeeID = O.EmployeeID
    INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
GROUP BY E.FirstName, E.LastName, E.EmployeeID

-- b) którzy nie mają podwładnych
SELECT E.FirstName, E.LastName,
       ROUND(SUM(Quantity*UnitPrice*(1-Discount)),2) AS total_value
FROM Employees AS E
    LEFT JOIN Employees AS E2 ON E.EmployeeID=E2.ReportsTo
    INNER JOIN Orders O on E.EmployeeID = O.EmployeeID
    INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
WHERE E2.ReportsTo is NULL
GROUP BY E.FirstName, E.LastName, E.EmployeeID

