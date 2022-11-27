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
