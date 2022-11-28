USE Northwind2

-- Ćwiczenia 1.

-- Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki dostarczała firma United Package.
SELECT DISTINCT C.CompanyName, C.Phone
FROM Customers AS C
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
    INNER JOIN Shippers S on O.ShipVia = S.ShipperID
WHERE S.CompanyName = 'United Package' AND YEAR(O.OrderDate) = 1997
ORDER BY 1

-- Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii Confections..
SELECT DISTINCT C.CompanyName, C.Phone
FROM Customers AS C
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
    INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
    INNER JOIN Products P on P.ProductID = [O D].ProductID
    INNER JOIN Categories C2 on C2.CategoryID = P.CategoryID
WHERE CategoryName LIKE 'Confections'

-- Wybierz nazwy i numery telefonów klientów, którzy nie kupowali produktów z kategorii Confections..
SELECT C.CompanyName, C.Phone
FROM Customers AS C
WHERE C.CustomerID NOT IN(SELECT O.CustomerID
                          FROM ORDERS AS O
                            INNER JOIN [Order Details] [O D] on O.OrderID = [O D].OrderID
                            INNER JOIN Products P on P.ProductID = [O D].ProductID
                            INNER JOIN Categories C3 on C3.CategoryID = P.CategoryID
                          WHERE C3.CategoryName = 'Confections')

-- Ćwiczenia 2.

-- Dla każdego produktu podaj maksymalną liczbę zamówionych jednostek
SELECT P.ProductName, MAX([O D].Quantity)
FROM Products AS P
    INNER JOIN [Order Details] [O D] on P.ProductID = [O D].ProductID
GROUP BY P.ProductName

-- Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu
SELECT P.ProductName, P.ProductID, P.UnitPrice
FROM Products AS P
    WHERE P.UnitPrice < (SELECT  AVG(Products.UnitPrice)
                         FROM Products)

-- Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu danej kategorii
SELECT P.ProductName, P.ProductID, P.UnitPrice
FROM Products AS P
WHERE P.UnitPrice < (SELECT AVG(P2.UnitPrice)
                     FROM Products AS P2
                     WHERE P.CategoryID=P2.CategoryID)

-- Ćwiczenia 3
-- Dla każdego produktu podaj jego nazwę, cenę, średnią cenę wszystkich produktów oraz różnicę między ceną produktu a średnią ceną wszystkich produktów
SELECT P.ProductName,
       (SELECT AVG(P2.UnitPrice)
        FROM Products AS P2) AS 'Avg_price',
        P.UnitPrice - (SELECT  AVG(P3.UnitPrice)
                       FROM Products AS P3) AS 'Difference'
FROM Products AS P

-- Dla każdego produktu podaj jego nazwę kategorii, nazwę produktu, cenę, średnią cenę wszystkich produktów danej kategorii oraz różnicę między
-- ceną produktu a średnią ceną wszystkich produktów danej kategorii
SELECT C.CategoryName,
       P.ProductName,
       P.UnitPrice,
       (SELECT AVG(P2.UnitPrice)
        FROM Products AS P2
        WHERE C.CategoryID=P2.CategoryID) AS 'Avg category price',
        P.UnitPrice - (SELECT AVG(P3.UnitPrice)
                        FROM Products AS P3
                    WHERE C.CategoryID=P3.CategoryID) AS 'Price diff'
FROM Products AS P
    INNER JOIN Categories C on C.CategoryID = P.CategoryID


-- Ćwiczenia 4.
-- Podaj łączną wartość zamówienia o numerze 10250 (uwzględnij cenę za przesyłkę)
