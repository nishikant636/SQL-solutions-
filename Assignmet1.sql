/*#1. List of all customers   Solution: */
SELECT 
    p.FirstName,
    p.LastName
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID;

/*2. List of all customers where company name ends in 'N'   Solution: */
SELECT 
    p.FirstName,
    p.LastName,
    s.Name AS CompanyName
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE 
    s.Name LIKE '%N';

/* 3. List of all customers who live in Berlin or London   Solution:*/
SELECT 
    p.FirstName,
    p.LastName,
    a.AddressLine1,
    a.AddressLine2,
    a.City,
    sp.Name AS StateProvince
   
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE 
    a.City IN ('Berlin', 'London');

/*4. List of all customers who live in the UK and USA       Solution:*/
SELECT 
    p.FirstName,
    p.LastName,
    a.AddressLine1,
    a.AddressLine2,
    a.City,
    sp.Name AS StateProvince,
    a.PostalCode,
    cr.Name AS Country
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN 
    Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE 
    cr.Name IN ('United Kingdom', 'United States');

/* 5. List of all products sorted by product name     Solution:  */
SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber,
    Color,
    ListPrice
FROM 
    Production.Product
ORDER BY 
    ProductName;

/* 6. List of all products where name starts with 'A'         Solution:  */
SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber,
    Color,
    ListPrice
FROM 
    Production.Product
WHERE 
    Name LIKE 'A%';
/* 7. List of all products that have ever been ordered   Solution:*/
SELECT DISTINCT
    p.ProductID,
    p.Name AS ProductName,
    p.ProductNumber,
    p.Color,
    p.ListPrice
FROM 
    Production.Product p
JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID;
	
/*8. List of customers who live in London and have bought Chai  Solution:   */
SELECT DISTINCT
    p.FirstName,
    p.LastName
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product pr ON sod.ProductID = pr.ProductID
WHERE 
    a.City = 'London'
    AND pr.Name = 'Chai';

/* 9. List of customers who never placed an order    Solution:*/
SELECT 
    p.FirstName,
    p.LastName
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE 
    soh.CustomerID IS NULL;

/* 10. List of customers who ordered Tofu    Solution:*/
SELECT DISTINCT
    p.FirstName,
    p.LastName
FROM 
    Sales.Customer c
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product pr ON sod.ProductID = pr.ProductID
WHERE 
    pr.Name = 'Tofu';

/*11. Details of the first order of the system    Solution:*/
SELECT TOP 1
    soh.SalesOrderID,
    soh.OrderDate,
    c.CustomerID,
    c.AccountNumber AS CustomerAccountNumber,
    p.FirstName AS CustomerFirstName,
    p.LastName AS CustomerLastName,
    a.AddressLine1 AS CustomerAddressLine1,
    a.AddressLine2 AS CustomerAddressLine2,
    a.City AS CustomerCity,
    sp.Name AS CustomerStateProvince,
    a.PostalCode AS CustomerPostalCode
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
ORDER BY 
    soh.OrderDate;

/*12. Find the details of the most expensive order date    Solution: */

WITH MostExpensiveOrders AS (
    SELECT 
        OrderDate,
        SUM(TotalDue) AS TotalAmount
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        OrderDate
    ORDER BY 
        TotalAmount DESC
    OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY
)

SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    c.CustomerID,
    c.AccountNumber AS CustomerAccountNumber,
    p.FirstName AS CustomerFirstName,
    p.LastName AS CustomerLastName,
    a.AddressLine1 AS CustomerAddressLine1,
    a.AddressLine2 AS CustomerAddressLine2,
    a.City AS CustomerCity,
    sp.Name AS CustomerStateProvince,
    a.PostalCode AS CustomerPostalCode,
    soh.TotalDue AS TotalAmount
FROM 
    MostExpensiveOrders meo
JOIN 
    Sales.SalesOrderHeader soh ON meo.OrderDate = soh.OrderDate
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN 
    Person.Address a ON bea.AddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID;

/* 13. For each order, get the OrderID and average quantity of items in that order   Solution:*/
SELECT 
    SalesOrderID AS OrderID,
    AVG(OrderQty) AS AverageQuantity
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    SalesOrderID;

/* 14. For each order, get the OrderID, minimum quantity, and maximum quantity for that order  */
SELECT 
    SalesOrderID AS OrderID,
    MIN(OrderQty) AS MinimumQuantity,
    MAX(OrderQty) AS MaximumQuantity
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    SalesOrderID;

	/*15. Get a list of all managers and the total number of employees who report to them  */

	SELECT 
    m.EmployeeID AS ManagerID,
    m.FirstName AS ManagerFirstName,
    m.LastName AS ManagerLastName,
    COUNT(e.EmployeeID) AS TotalEmployees
FROM 
    HumanResources.Employee m
LEFT JOIN 
    HumanResources.Employee e ON m.EmployeeID = e.ManagerID
GROUP BY 
    m.EmployeeID, m.FirstName, m.LastName;


/* 16. Get the OrderID and the total quantity for each order that has a total quantity of greater than 300
Solution:*/
SELECT 
    SalesOrderID AS OrderID,
    SUM(OrderQty) AS TotalQuantity
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    SalesOrderID
HAVING 
    SUM(OrderQty) > 300;

/* 17. List of all orders placed on or after 1996-12-31
Solution:*/
SELECT 
    SalesOrderID,
    OrderDate
FROM 
    Sales.SalesOrderHeader
WHERE 
    OrderDate >= '1996-12-31';

/* 18. List of all orders shipped to Canada
Solution:*/
   
	SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    a.AddressLine1 AS ShippingAddress,
    a.City AS ShippingCity,
    sp.Name AS ShippingStateProvince,
    a.PostalCode AS ShippingPostalCode
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE 
    sp.CountryRegionCode = 'CA';

	/*19. List of all orders with an order total > 200
Solution:*/
SELECT 
    soh.SalesOrderID,
    SUM(sod.OrderQty * sod.UnitPrice) AS TotalOrderAmount
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY 
    soh.SalesOrderID
HAVING 
    SUM(sod.OrderQty * sod.UnitPrice) > 200;

	/*20. List of countries and sales made in each country
Solution: */

SELECT 
    sp.CountryRegionCode AS CountryCode,
    sp.CountryRegionName AS CountryName,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN 
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
GROUP BY 
    sp.CountryRegionCode, sp.CountryRegionName;


/*21. List of Customers' ContactName and number of orders they place
Solution:  */
SELECT 
    c.ContactName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM 
    Sales.Customer c
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY 
    c.ContactName;



/* 22. List of customers' ContactNames who have placed more than 3 orders
Solution:*/
SELECT 
    c.CustomerName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM 
    Sales.Customer c
JOIN 
    Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY 
    c.CustomerName
HAVING 
    COUNT(soh.SalesOrderID) > 3;


/* 23. List of discontinued products which were ordered between 1997-01-01 and 1998-01-01*/
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    sod.OrderDate
FROM 
    Production.Product p
JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE 
    p.DiscontinuedDate IS NOT NULL
    AND sod.OrderDate >= '1997-01-01'
    AND sod.OrderDate < '1998-01-01';


/*24. List of employee first name, last name, supervisor first name, last name
Solution:*/
SELECT 
    e.FirstName AS EmployeeFirstName,
    e.LastName AS EmployeeLastName,
    s.FirstName AS SupervisorFirstName,
    s.LastName AS SupervisorLastName
FROM 
    HumanResources.Employee e
LEFT JOIN 
    HumanResources.Employee s ON e.ManagerID = s.EmployeeID;


/*
26. List of employee ID and total sales conducted by employee
Solution*/
SELECT 
    e.EmployeeID,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    HumanResources.Employee e
JOIN 
    Sales.SalesOrderHeader soh ON e.EmployeeID = soh.SalesPersonID
GROUP BY 
    e.EmployeeID;

/*27. List of managers who have more than four people reporting to them
Solution*/
SELECT 
    mgr.EmployeeID AS ManagerID,
    mgr.FirstName AS ManagerFirstName,
    mgr.LastName AS ManagerLastName,
    COUNT(emp.EmployeeID) AS NumberOfSubordinates
FROM 
    HumanResources.Employee mgr
JOIN 
    HumanResources.Employee emp ON mgr.EmployeeID = emp.ManagerID
GROUP BY 
    mgr.EmployeeID, mgr.FirstName, mgr.LastName
HAVING 
    COUNT(emp.EmployeeID) > 4;

/*28. List of orders and product names
Solution:*/
SELECT 
    sod.SalesOrderID,
    p.Name AS ProductName
FROM 
    Sales.SalesOrderDetail sod
JOIN 
    Production.Product p ON sod.ProductID = p.ProductID;

/*29. List of orders placed by the best customer
Solution:*/
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE 
    c.CustomerID = (
        SELECT TOP 1 
            CustomerID
        FROM 
            Sales.SalesOrderHeader
        GROUP BY 
            CustomerID
        ORDER BY 
            SUM(TotalDue) DESC
    );

/*30. List of orders placed by customers who do not have a fax number
Solution:*/
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    c.CustomerID
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE 
    c.Fax IS NULL OR c.Fax = '';

	Sales.Customer c
/* 31. List of postal codes where the product tofu was shipped
Solution:*/
SELECT DISTINCT 
    a.PostalCode
FROM 
    Production.Product p
JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN 
    Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN 
    Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE 
    p.Name = 'Tofu';


	/*32. List of product names that were shipped to France
Solution*/
SELECT DISTINCT 
    p.Name AS ProductName
FROM 
    Production.Product p
JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN 
    Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN 
    Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE 
    a.CountryRegionCode = 'FR';

/*33. List of product names and categories for the supplier 'Specialty Biscuits, Ltd.'
Solution: */
SELECT 
    p.Name AS ProductName,
    pc.Name AS CategoryName
FROM 
    Production.Product p
JOIN 
    Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN 
    Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
JOIN 
    Production.ProductSubcategory pc ON p.ProductSubcategoryID = pc.ProductSubcategoryID
WHERE 
    v.Name = 'Specialty Biscuits, Ltd.';


/* 34. List of products that were never ordered
Solution:*/
SELECT 
    p.ProductID,
    p.Name AS ProductName
FROM 
    Production.Product p
LEFT JOIN 
    Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE 
    sod.ProductID IS NULL;

/* 35. List of products where units in stock are less than 10 and units on order are 0
Solution:*/
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.Quantity AS UnitsInStock,
    p.ReorderPoint,
    p.SafetyStockLevel,
    p.StandardCost,
    p.ListPrice
FROM 
    Production.Product AS p
JOIN 
    Production.ProductInventory AS inv ON p.ProductID = inv.ProductID
WHERE 
    inv.Quantity < 10
    AND p.ReorderPoint = 0
    AND p.ProductID IN (
        SELECT pv.ProductID
        FROM Purchasing.ProductVendor AS pv
        WHERE pv.OnOrderQty = 0
    );

/*36. List of top 10 countries by sales
Solution */


--36.List of top ten countries by sales
SELECT TOP 10
    cr.Name AS CountryRegionName,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader AS soh
    JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
    JOIN Sales.Store AS s ON c.StoreID = s.BusinessEntityID
    JOIN Person.BusinessEntityAddress AS bea ON s.BusinessEntityID = bea.BusinessEntityID
    JOIN Person.Address AS a ON bea.AddressID = a.AddressID
    JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
    JOIN Person.CountryRegion AS cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY 
    cr.Name
ORDER BY 
    TotalSales DESC;

--37.Number of orders each employee has taken for customers with CustomerIDs between A and AO
SELECT 
    e.BusinessEntityID AS EmployeeID,
    CONCAT(p.FirstName, ' ', p.LastName) AS EmployeeName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM 
    Sales.SalesOrderHeader AS soh
    JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
    JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
    JOIN Sales.SalesPerson AS sp ON soh.SalesPersonID = sp.BusinessEntityID
    JOIN HumanResources.Employee AS e ON sp.BusinessEntityID = e.BusinessEntityID
WHERE 
    c.CustomerID BETWEEN 'A' AND 'AO'
GROUP BY 
    e.BusinessEntityID, p.FirstName, p.LastName
ORDER BY 
    NumberOfOrders DESC;

--38.Order date of most expensive order
SELECT TOP 1
    soh.OrderDate AS MostExpensiveOrderDate
FROM 
    Sales.SalesOrderHeader AS soh
ORDER BY 
    soh.TotalDue DESC;

--39.Product name and total revenue from that product
SELECT 
    p.Name AS ProductName,
    SUM(soh.TotalDue) AS TotalRevenue
FROM 
    Production.Product AS p
    JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY 
    p.Name
ORDER BY 
    TotalRevenue DESC;

--40.Supplierid and number of products offered
SELECT 
    s.BusinessEntityID AS SupplierID,
    s.Name AS SupplierName,
    COUNT(*) AS NumberOfProductsOffered
FROM 
    Purchasing.ProductVendor AS pv
    JOIN Purchasing.Vendor AS s ON pv.BusinessEntityID = s.BusinessEntityID
GROUP BY 
    s.BusinessEntityID, s.Name
ORDER BY 
    NumberOfProductsOffered DESC;

--41.Top ten customers based on their business
SELECT TOP 10
    c.CustomerID,
    CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
    SUM(soh.TotalDue) AS TotalOrderAmount
FROM 
    Sales.Customer AS c
    JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
    JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
GROUP BY 
    c.CustomerID, p.FirstName, p.LastName
ORDER BY 
    TotalOrderAmount DESC;

--42.What is the total revenue of the company
SELECT 
    SUM(soh.TotalDue) AS TotalRevenue
FROM 
    Sales.SalesOrderHeader soh;