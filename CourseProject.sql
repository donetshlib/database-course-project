IF DB_ID('HlibProject') IS NULL
BEGIN
    PRINT 'Database not found.';
    PRINT 'Database created.';
    CREATE DATABASE HlibProject;
END
ELSE
BEGIN
    PRINT 'Database already exists.';
END
GO

USE HlibProject;
GO

DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;

DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Customers;

-- Customers table
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    City VARCHAR(50),
    RegisteredAt DATETIME DEFAULT GETDATE()
);

-- Categories table
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

-- Suppliers table
CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName VARCHAR(100),
    ContactEmail VARCHAR(100)
);

-- Products table
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    SupplierID INT FOREIGN KEY REFERENCES Suppliers(SupplierID), ----- key
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL DEFAULT 0
);

-- Orders table
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2)
);

-- Junction table for many-to-many (Order ? Product)
CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID) ON DELETE CASCADE,
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID) ON DELETE CASCADE,
    Quantity INT NOT NULL,
    CONSTRAINT CK_Quantity_Positive CHECK (Quantity > 0)
);

-- Payments table
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID) ON DELETE CASCADE,
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod VARCHAR(50),
    Amount DECIMAL(10,2)
);

-- 3 INDEXES----------------------------------------------------------------------------------------------

CREATE UNIQUE INDEX INDEX_Customers_Email ON Customers(Email);
CREATE INDEX INDEX_Orders_CustomerID ON Orders(CustomerID);
CREATE INDEX INDEX_OrderItems_ProductID ON OrderItems(ProductID);


-- 4 INSERT SAMPLE DATA------------------------------------------------------------------------------------

-- Categories
INSERT INTO Categories (CategoryName)
VALUES ('Smartphones'), ('Laptops'), ('Headphones'), ('Smart Home');

-- Suppliers
INSERT INTO Suppliers (SupplierName, ContactEmail)
VALUES ('Xiaomi Global', 'contact@xiaomi.com'),
       ('Mi Distribution', 'sales@mi.com');

-- Products
INSERT INTO Products (ProductName, CategoryID, SupplierID, Price, Stock)
VALUES 
('Xiaomi 14 Pro', 1, 1, 999.99, 20),
('Redmi Note 13', 1, 2, 399.99, 40),
('Mi Notebook Air', 2, 1, 799.00, 15),
('Mi Smart Speaker', 4, 2, 99.99, 30),
('Mi Wireless Earbuds', 3, 1, 59.99, 50);

-- Customers
INSERT INTO Customers (Name, Email, Phone, City)
VALUES 
('John Doe', 'john@example.com', '+37060012345', 'Vilnius'),
('Anna Smith', 'anna@example.com', '+37060054321', 'Kaunas'),
('David Miller', 'david@example.com', '+37060111111', 'Klaipeda');

-- Orders
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES 
(1, '2025-10-01', 1059.98),
(2, '2025-10-05', 459.98),
(3, '2025-10-10', 799.00);

-- OrderItems
INSERT INTO OrderItems (OrderID, ProductID, Quantity)
VALUES 
(1, 1, 1),  -- Xiaomi 14 Pro
(1, 4, 1),  -- Mi Smart Speaker
(2, 2, 1),  -- Redmi Note 13
(2, 5, 1),  -- Earbuds
(3, 3, 1);  -- Mi Notebook Air

-- Payments
INSERT INTO Payments (OrderID, PaymentMethod, Amount)
VALUES 
(1, 'Credit Card', 1059.98),
(2, 'PayPal', 459.98),
(3, 'Credit Card', 799.00);
GO
SELECT * FROM Categories;
SELECT * FROM Suppliers;
SELECT * FROM Products;
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Payments;

-- 5 UPDATE EXAMPLES--------------------------------------------------------------------------------------------

-- Increase price of all smartphones by 5%
UPDATE Products
SET Price = Price * 1.05
WHERE CategoryID = (SELECT CategoryID FROM Categories WHERE CategoryName = 'Smartphones');
SELECT * FROM Products;

-- Update stock after restocking supplier 1
UPDATE Products
SET Stock = Stock + 10
WHERE SupplierID = 1;
GO
SELECT * FROM Products;

-- 6 DELETE EXAMPLES--------------------------------------------------------------------------------------------

-- Delete all customers from Klaipeda
SELECT * FROM Customers;
DELETE FROM Customers WHERE City = 'Klaipeda';
GO
SELECT * FROM Customers;

TRUNCATE TABLE Payments;
SELECT * FROM Payments;

-- ORDER BY examples (ascending and descending)
SELECT ProductName, Price
FROM Products
ORDER BY Price ASC;   -- ascending order

SELECT ProductName, Price
FROM Products
ORDER BY Price DESC;  -- descending order

-- 7 SELECT QUERIES WITH AGGREGATES------------------------------------------------------------------------


-- Aggregate 1: Total products by category
SELECT c.CategoryName, COUNT(p.ProductID) AS ProductCount, AVG(p.Price) AS AvgPrice
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName;

-- Aggregate 2: Total sales amount per customer
SELECT c.Name, SUM(o.TotalAmount) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.Name
ORDER BY TotalSpent DESC;

-- Pagination example
SELECT * FROM Orders
ORDER BY OrderDate DESC
OFFSET 0 ROWS FETCH NEXT 2 ROWS ONLY;
GO
    

-- 8 TABLE JOINS-------------------------------------------------------------------------------------------


-- Inner Join (2 tables)
SELECT c.Name, o.OrderDate, o.TotalAmount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;

-- LEFT JOIN: show all customers, including those without orders
SELECT c.Name, o.OrderID, o.OrderDate
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID;

-- 3-table Join
SELECT c.Name AS Customer, p.ProductName, oi.Quantity, o.OrderDate
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID;
GO



-- 9 CREATE VIEW----------------------------------------------------------
GO 

IF OBJECT_ID('VIEW_CustomerOrderSummary', 'V') IS NOT NULL
    DROP VIEW VIEW_CustomerOrderSummary;
GO

CREATE VIEW VIEW_CustomerOrderSummary AS
SELECT 
    c.Name AS CustomerName,
    o.OrderDate,
    SUM(oi.Quantity * p.Price) AS TotalPrice
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY c.Name, o.OrderDate;
GO
SELECT * FROM VIEW_CustomerOrderSummary;

-- 10 STORED PROCEDURE------------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE GetOrdersByCustomer 
    @CustomerName VARCHAR(100)
AS
BEGIN
    SELECT c.Name, o.OrderID, o.OrderDate, o.TotalAmount
    FROM Orders o
    JOIN Customers c ON o.CustomerID = c.CustomerID
    WHERE c.Name = @CustomerName;
END;
GO

EXEC GetOrdersByCustomer @CustomerName = 'John Doe';

-- 11 FUNCTION--------------------------------------------------------------------------------------
GO
CREATE OR ALTER FUNCTION GetTotalSpent(@CustomerID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);
    SELECT @Total = SUM(oi.Quantity * p.Price)
    FROM Orders o
    JOIN OrderItems oi ON o.OrderID = oi.OrderID
    JOIN Products p ON oi.ProductID = p.ProductID
    WHERE o.CustomerID = @CustomerID;
    RETURN ISNULL(@Total,0);
END;
GO

SELECT dbo.GetTotalSpent(1) AS TotalSpent;

SELECT 
    c.CustomerID,
    c.Name,
    dbo.GetTotalSpent(c.CustomerID) AS TotalSpent
FROM Customers c;

-- 12 TRIGGER---------------------------------------------------------------------------------------------------------
GO
CREATE OR ALTER TRIGGER trg_UpdateStock
ON OrderItems
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.Stock = p.Stock - i.Quantity
    FROM Products p
    JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

SELECT * FROM Products;
INSERT INTO OrderItems (OrderID, ProductID, Quantity)
VALUES (1, 2, 3);
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderItems;

-- 13 TRANSACTION EXAMPLE -------------------------------------------------------------------------------------------
SELECT * FROM Orders WHERE OrderID = 2;
SELECT * FROM OrderItems WHERE OrderID = 2;
SELECT * FROM Orders;
SELECT * FROM OrderItems;

--BEGIN TRANSACTION;
--    DELETE FROM OrderItems WHERE OrderID = 2;
--    DELETE FROM Orders WHERE OrderID = 2;
--COMMIT TRANSACTION;
--GO

SELECT * FROM Orders WHERE OrderID = 2;
SELECT * FROM OrderItems WHERE OrderID = 2;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
