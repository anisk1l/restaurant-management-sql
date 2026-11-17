/**********************************************************************
  RESTAURANT MANAGEMENT SYSTEM  --  Database Project
  Platform : Microsoft SQL Server (SQL Server Management Studio)
  Contents : 7 tables | 5-16 records per table | 6 views | demo queries

  HOW TO RUN:
  1. Open SSMS -> connect to your local server instance.
  2. File -> Open -> this .sql file.
  3. Press F5 (Execute) once. The whole database is built from scratch.
  4. Refresh Object Explorer to see RestaurantDB.
**********************************************************************/

/*====================================================================
  SECTION 0 : CREATE THE DATABASE
====================================================================*/
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'RestaurantDB')
BEGIN
    ALTER DATABASE RestaurantDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RestaurantDB;
END
GO

CREATE DATABASE RestaurantDB;
GO

USE RestaurantDB;
GO


/*====================================================================
  SECTION 1 : CREATE TABLES
  ------------------------------------------------------------------
  Primary keys uniquely identify each row (Lec03).
  Foreign keys connect the relations to each other (Lec03).
====================================================================*/

-- ---------- TABLE 1 : CATEGORIES -----------------------------------
CREATE TABLE Categories (
    CategoryID   INT           IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50)  NOT NULL,
    Description  NVARCHAR(150) NULL,
    CONSTRAINT UQ_Categories_Name UNIQUE (CategoryName)   -- UNIQUE constraint (Lec13)
);
GO

-- ---------- TABLE 2 : MENUITEMS ------------------------------------
-- FK -> Categories
CREATE TABLE MenuItems (
    MenuItemID      INT           IDENTITY(1,1) PRIMARY KEY,
    ItemName        NVARCHAR(80)  NOT NULL,
    CategoryID      INT           NOT NULL,
    Price           DECIMAL(8,2)  NOT NULL,
    PreparationTime INT           NULL,       -- in minutes
    Calories        INT           NULL,
    IsAvailable     BIT           NOT NULL
        CONSTRAINT DF_MenuItems_Available DEFAULT 1,      -- DEFAULT constraint (Lec13)
    CONSTRAINT FK_MenuItems_Categories
        FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- ---------- TABLE 3 : CUSTOMERS ------------------------------------
CREATE TABLE Customers (
    CustomerID  INT           IDENTITY(1,1) PRIMARY KEY,
    FirstName   NVARCHAR(50)  NOT NULL,
    LastName    NVARCHAR(50)  NOT NULL,
    Email       NVARCHAR(100) NULL,
    Phone       NVARCHAR(25)  NULL,       -- may be NULL (Lec03: NULL values)
    City        NVARCHAR(50)  NULL,
    JoinDate    DATE          NOT NULL
        CONSTRAINT DF_Customers_JoinDate DEFAULT GETDATE(),   -- DEFAULT (Lec13)
    IsVIP       BIT           NOT NULL
        CONSTRAINT DF_Customers_IsVIP DEFAULT 0,
    CONSTRAINT UQ_Customers_Email UNIQUE (Email)              -- UNIQUE (Lec13)
);
GO

-- ---------- TABLE 4 : STAFF ----------------------------------------
CREATE TABLE Staff (
    StaffID     INT           IDENTITY(1,1) PRIMARY KEY,
    FirstName   NVARCHAR(50)  NOT NULL,
    LastName    NVARCHAR(50)  NOT NULL,
    Position    NVARCHAR(40)  NOT NULL,   -- Waiter / Chef / Manager ...
    HireDate    DATE          NOT NULL,
    Salary      DECIMAL(10,2) NOT NULL,
    Phone       NVARCHAR(25)  NULL
);
GO

-- ---------- TABLE 5 : RESTAURANTTABLES -----------------------------
CREATE TABLE RestaurantTables (
    TableID     INT           IDENTITY(1,1) PRIMARY KEY,
    TableNumber INT           NOT NULL,
    Capacity    INT           NOT NULL,
    Location    NVARCHAR(30)  NOT NULL,   -- Indoor / Terrace / VIP Room
    CONSTRAINT UQ_Tables_Number UNIQUE (TableNumber)      -- UNIQUE (Lec13)
);
GO

-- ---------- TABLE 6 : ORDERS ---------------------------------------
-- THREE foreign keys: which customer, which waiter, which table
CREATE TABLE Orders (
    OrderID       INT           IDENTITY(1,1) PRIMARY KEY,
    CustomerID    INT           NOT NULL,
    StaffID       INT           NOT NULL,
    TableID       INT           NOT NULL,
    OrderDate     DATE          NOT NULL,
    OrderTime     TIME          NULL,
    OrderStatus   NVARCHAR(20)  NOT NULL
        CONSTRAINT DF_Orders_Status DEFAULT 'Preparing',  -- DEFAULT (Lec13)
    PaymentMethod NVARCHAR(20)  NULL,      -- NULL = not paid yet
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Orders_Staff
        FOREIGN KEY (StaffID)    REFERENCES Staff(StaffID),
    CONSTRAINT FK_Orders_Tables
        FOREIGN KEY (TableID)    REFERENCES RestaurantTables(TableID)
);
GO

-- ---------- TABLE 7 : ORDERDETAILS ---------------------------------
-- Resolves the MANY-TO-MANY relationship between Orders and MenuItems
CREATE TABLE OrderDetails (
    OrderDetailID INT           IDENTITY(1,1) PRIMARY KEY,
    OrderID       INT           NOT NULL,
    MenuItemID    INT           NOT NULL,
    Quantity      INT           NOT NULL
        CONSTRAINT DF_OrderDetails_Qty DEFAULT 1,         -- DEFAULT (Lec13)
    UnitPrice     DECIMAL(8,2)  NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID)    REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_MenuItems
        FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);
GO


/*====================================================================
  SECTION 2 : INSERT RECORDS
====================================================================*/

-- ---------- CATEGORIES ----------------------------------------------
INSERT INTO Categories (CategoryName, Description) VALUES
('Starters',   'Small dishes served before the main course'),
('Soups',      'Hot soups of the day'),
('Main Dishes','Meat, fish and pasta main courses'),
('Pizza',      'Stone oven pizzas'),
('Desserts',   'Sweet dishes and cakes'),
('Drinks',     'Cold and hot beverages');
GO

-- ---------- MENUITEMS -----------------------------------------------
INSERT INTO MenuItems (ItemName, CategoryID, Price, PreparationTime, Calories, IsAvailable) VALUES
('Bruschetta',            1, 18.00, 10,  220, 1),
('Garlic Bread',          1, 14.00,  8,  310, 1),
('Mozzarella Sticks',     1, 22.00, 12,  450, 0),
('Tomato Soup',           2, 16.00, 15,  180, 1),
('Zurek',                 2, 19.00, 20,  260, 1),
('Grilled Salmon',        3, 68.00, 25,  410, 1),
('Beef Steak',            3, 89.00, 30,  620, 1),
('Chicken Curry',         3, 52.00, 22,  540, 1),
('Spaghetti Carbonara',   3, 45.00, 18,  680, 1),
('Vegetarian Lasagna',    3, 42.00, 25,  520, 0),
('Margherita Pizza',      4, 38.00, 15,  700, 1),
('Pepperoni Pizza',       4, 44.00, 15,  850, 1),
('Four Cheese Pizza',     4, 46.00, 16,  900, 1),
('Tiramisu',              5, 24.00,  5,  380, 1),
('Cheesecake',            5, 22.00,  5,  420, 1),
('Chocolate Lava Cake',   5, 26.00, 12,  510, 0),
('Espresso',              6,  9.00,  3,    5, 1),
('Fresh Orange Juice',    6, 15.00,  4,  110, 1),
('Coca Cola',             6, 10.00,  1,  140, 1),
('Still Water',           6,  7.00,  1,    0, 1);
GO

-- ---------- CUSTOMERS -----------------------------------------------
INSERT INTO Customers (FirstName, LastName, Email, Phone, City, JoinDate, IsVIP) VALUES
('Anna',   'Kowalska',   'anna.kowalska@mail.com', '+48 601 234 567', 'Warsaw', '2024-10-05', 1),
('Piotr',  'Nowak',      'piotr.nowak@mail.com',   '+48 602 345 678', 'Warsaw', '2024-11-12', 0),
('Maria',  'Wisniewska', 'maria.w@mail.com',       NULL,              'Krakow', '2025-01-20', 0),
('Ahmed',  'Hassan',     'ahmed.hassan@mail.com',  '+48 603 456 789', 'Warsaw', '2025-02-14', 1),
('Julia',  'Lewandowska','julia.l@mail.com',       '+48 604 567 890', 'Gdansk', '2025-03-30', 0),
('Tomasz', 'Zielinski',  'tomasz.z@mail.com',      NULL,              'Warsaw', '2025-06-11', 0),
('Sofia',  'Rossi',      'sofia.rossi@mail.com',   '+48 605 678 901', 'Poznan', '2025-09-02', 1),
('Karol',  'Mazur',      'karol.mazur@mail.com',   '+48 606 789 012', 'Warsaw', '2026-01-15', 0);
GO

-- ---------- STAFF ---------------------------------------------------
INSERT INTO Staff (FirstName, LastName, Position, HireDate, Salary, Phone) VALUES
('Ewa',     'Dabrowska', 'Manager',      '2018-09-01', 11000.00, '+48 701 111 222'),
('Marek',   'Krawczyk',  'Head Chef',    '2019-03-15',  9500.00, '+48 701 222 333'),
('Alicja',  'Pawlak',    'Waiter',       '2021-07-01',  5200.00, '+48 701 333 444'),
('Piotr',   'Sikora',    'Waiter',       '2023-02-20',  4800.00, NULL),
('Natalia', 'Baran',     'Waiter',       '2024-05-10',  4800.00, '+48 701 555 666'),
('Jakub',   'Wojcik',    'Chef',         '2022-11-01',  7000.00, '+48 701 666 777'),
('Zofia',   'Kaczmarek', 'Bartender',    '2023-08-18',  5000.00, '+48 701 777 888');
GO

-- ---------- RESTAURANTTABLES ----------------------------------------
INSERT INTO RestaurantTables (TableNumber, Capacity, Location) VALUES
(1,  2, 'Indoor'),
(2,  4, 'Indoor'),
(3,  4, 'Indoor'),
(4,  6, 'Terrace'),
(5,  2, 'Terrace'),
(6,  8, 'VIP Room'),
(7,  4, 'Terrace'),
(8, 10, 'VIP Room');
GO

-- ---------- ORDERS --------------------------------------------------
-- PaymentMethod NULL => the bill has not been paid yet
INSERT INTO Orders (CustomerID, StaffID, TableID, OrderDate, OrderTime, OrderStatus, PaymentMethod) VALUES
(1, 3, 2, '2026-07-10', '19:30', 'Served',    'Card'),
(2, 4, 1, '2026-07-10', '20:15', 'Served',    'Cash'),
(3, 3, 4, '2026-07-12', '13:45', 'Served',    'Card'),
(4, 5, 6, '2026-07-15', '18:00', 'Served',    'Card'),
(1, 5, 3, '2026-07-18', '12:30', 'Served',    'BLIK'),
(5, 4, 5, '2026-07-19', '21:00', 'Cancelled', NULL),
(7, 3, 8, '2026-07-20', '19:45', 'Served',    'Card'),
(6, 5, 7, '2026-07-22', '14:10', 'Served',    'Cash'),
(4, 4, 2, '2026-07-23', '20:30', 'Served',    'Card'),
(2, 3, 1, '2026-07-24', '13:00', 'Preparing', NULL);
GO

-- ---------- ORDERDETAILS --------------------------------------------
INSERT INTO OrderDetails (OrderID, MenuItemID, Quantity, UnitPrice) VALUES
(1,  1, 2, 18.00),
(1,  7, 2, 89.00),
(1, 14, 2, 24.00),
(1, 17, 2,  9.00),
(2, 11, 1, 38.00),
(2, 19, 2, 10.00),
(3,  4, 1, 16.00),
(3,  9, 2, 45.00),
(3, 18, 2, 15.00),
(4,  6, 3, 68.00),
(4, 12, 1, 44.00),
(4, 15, 3, 22.00),
(4, 20, 4,  7.00),
(5,  8, 1, 52.00),
(5, 17, 1,  9.00),
(6, 13, 1, 46.00),
(7,  7, 4, 89.00),
(7,  6, 2, 68.00),
(7, 14, 4, 24.00),
(7, 18, 4, 15.00),
(8,  5, 2, 19.00),
(8,  9, 1, 45.00),
(8, 19, 1, 10.00),
(9, 12, 2, 44.00),
(9,  2, 1, 14.00),
(9, 15, 2, 22.00),
(10, 11, 1, 38.00),
(10, 20, 2,  7.00);
GO


/*====================================================================
  SECTION 3 : VIEWS
  ------------------------------------------------------------------
  A view is a stored SELECT statement that behaves like a table.
====================================================================*/

-- ---------- VIEW 1 : THE FULL MENU ---------------------------------
-- Joins MenuItems + Categories (Lec07 INNER JOIN)
CREATE VIEW vw_FullMenu AS
SELECT  m.MenuItemID,
        m.ItemName        AS Dish,
        c.CategoryName    AS Category,
        m.Price,
        m.PreparationTime AS MinutesToCook,
        m.Calories,
        m.IsAvailable
FROM    MenuItems m
INNER JOIN Categories c ON m.CategoryID = c.CategoryID;
GO

-- ---------- VIEW 2 : WHAT WE CAN SERVE TODAY -----------------------
-- Uses WHERE (Lec04)
CREATE VIEW vw_AvailableMenu AS
SELECT  m.ItemName     AS Dish,
        c.CategoryName AS Category,
        m.Price
FROM    MenuItems m
INNER JOIN Categories c ON m.CategoryID = c.CategoryID
WHERE   m.IsAvailable = 1;
GO

-- ---------- VIEW 3 : ORDER SUMMARY WITH THE BILL -------------------
-- Joins 5 tables and calculates the total price of every order
CREATE VIEW vw_OrderSummary AS
SELECT  o.OrderID,
        o.OrderDate,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        s.FirstName + ' ' + s.LastName AS WaiterName,
        t.TableNumber,
        t.Location                     AS TableLocation,
        o.OrderStatus,
        o.PaymentMethod,
        SUM(d.Quantity * d.UnitPrice)  AS TotalAmount
FROM    Orders o
INNER JOIN Customers        c ON o.CustomerID = c.CustomerID
INNER JOIN Staff            s ON o.StaffID    = s.StaffID
INNER JOIN RestaurantTables t ON o.TableID    = t.TableID
INNER JOIN OrderDetails     d ON o.OrderID    = d.OrderID
GROUP BY o.OrderID, o.OrderDate, c.FirstName, c.LastName,
         s.FirstName, s.LastName, t.TableNumber, t.Location,
         o.OrderStatus, o.PaymentMethod;
GO

-- ---------- VIEW 4 : EVERY LINE OF EVERY BILL ----------------------
CREATE VIEW vw_OrderLines AS
SELECT  o.OrderID,
        o.OrderDate,
        m.ItemName                  AS Dish,
        cat.CategoryName            AS Category,
        d.Quantity,
        d.UnitPrice,
        d.Quantity * d.UnitPrice    AS LineTotal
FROM    OrderDetails d
INNER JOIN Orders     o   ON d.OrderID    = o.OrderID
INNER JOIN MenuItems  m   ON d.MenuItemID = m.MenuItemID
INNER JOIN Categories cat ON m.CategoryID = cat.CategoryID;
GO

-- ---------- VIEW 5 : BEST SELLING DISHES ---------------------------
-- LEFT JOIN so that dishes nobody ordered still appear with 0
CREATE VIEW vw_PopularDishes AS
SELECT  m.ItemName                       AS Dish,
        c.CategoryName                   AS Category,
        ISNULL(SUM(d.Quantity), 0)       AS TotalSold,
        ISNULL(SUM(d.Quantity * d.UnitPrice), 0) AS Revenue
FROM    MenuItems m
INNER JOIN Categories   c ON m.CategoryID = c.CategoryID
LEFT  JOIN OrderDetails d ON m.MenuItemID = d.MenuItemID
GROUP BY m.ItemName, c.CategoryName;
GO

-- ---------- VIEW 6 : UNPAID / OPEN BILLS ---------------------------
-- Uses IS NULL and NOT (Lec03 NULL, Lec05 NOT)
CREATE VIEW vw_UnpaidOrders AS
SELECT  o.OrderID,
        o.OrderDate,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        t.TableNumber,
        o.OrderStatus
FROM    Orders o
INNER JOIN Customers        c ON o.CustomerID = c.CustomerID
INNER JOIN RestaurantTables t ON o.TableID    = t.TableID
WHERE   o.PaymentMethod IS NULL
  AND   NOT o.OrderStatus = 'Cancelled';
GO


/*====================================================================
  SECTION 4 : DEMONSTRATION QUERIES
  Run these one by one during the presentation.
====================================================================*/

-- 4.1  Show every table
SELECT * FROM Categories;
SELECT * FROM MenuItems;
SELECT * FROM Customers;
SELECT * FROM Staff;
SELECT * FROM RestaurantTables;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;
GO

-- 4.2  Show every view
SELECT * FROM vw_FullMenu;
SELECT * FROM vw_AvailableMenu;
SELECT * FROM vw_OrderSummary;
SELECT * FROM vw_OrderLines;
SELECT * FROM vw_PopularDishes;
SELECT * FROM vw_UnpaidOrders;
GO

-- 4.3  "How many dishes are available on the menu?"  (classic question)
SELECT COUNT(*) AS DishesAvailable FROM MenuItems WHERE IsAvailable = 1;
GO

-- 4.4  Total money earned by the restaurant
SELECT SUM(Quantity * UnitPrice) AS TotalRevenue FROM OrderDetails;
GO

-- 4.5  How much did order number 1 cost?
SELECT SUM(d.Quantity * d.UnitPrice) AS BillTotal
FROM   OrderDetails d
WHERE  d.OrderID = 1;
GO

-- 4.6  WHERE + AND + OR + NOT  (Lec05)
SELECT ItemName, Price
FROM   MenuItems
WHERE  (CategoryID = 3 OR CategoryID = 4)
  AND  Price > 40
  AND  NOT IsAvailable = 0
ORDER BY Price DESC;
GO

-- 4.7  Aliases with AS, two tables in FROM (Lec05 / Lec06 style)
SELECT m.ItemName AS Dish, c.CategoryName AS Category
FROM   MenuItems m, Categories c
WHERE  m.CategoryID = c.CategoryID
ORDER BY c.CategoryName ASC, m.ItemName ASC;
GO

-- 4.8  INNER JOIN: which customer was served by which waiter
SELECT c.FirstName, c.LastName, s.LastName AS Waiter, o.OrderDate
FROM   Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN Staff     s ON o.StaffID    = s.StaffID
ORDER BY o.OrderDate DESC;
GO

-- 4.9  LEFT JOIN: every customer, even those who never ordered
SELECT c.FirstName, c.LastName, o.OrderID
FROM   Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
ORDER BY c.LastName;
GO

-- 4.10 RIGHT JOIN: every dish, even the ones nobody ordered
SELECT d.OrderID, m.ItemName
FROM   OrderDetails d
RIGHT JOIN MenuItems m ON d.MenuItemID = m.MenuItemID
ORDER BY m.ItemName;
GO

-- 4.11 Most expensive dish
SELECT TOP 1 ItemName, Price FROM MenuItems ORDER BY Price DESC;
GO

-- 4.12 All pizzas under 45
SELECT m.ItemName, m.Price
FROM   MenuItems m
INNER JOIN Categories c ON m.CategoryID = c.CategoryID
WHERE  c.CategoryName = 'Pizza' AND m.Price < 45;
GO

-- 4.13 VIP customers from Warsaw
SELECT FirstName, LastName, City
FROM   Customers
WHERE  IsVIP = 1 AND City = 'Warsaw';
GO

-- 4.14 Customers who did not give a phone number (NULL - Lec03)
SELECT FirstName, LastName, Email
FROM   Customers
WHERE  Phone IS NULL;
GO

-- 4.15 How many dishes in each category
SELECT c.CategoryName, COUNT(*) AS NumberOfDishes
FROM   MenuItems m
INNER JOIN Categories c ON m.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY NumberOfDishes DESC;
GO

-- 4.16 Which waiter brought the most money
SELECT s.FirstName + ' ' + s.LastName AS Waiter,
       SUM(d.Quantity * d.UnitPrice)  AS TotalSales
FROM   Orders o
INNER JOIN Staff        s ON o.StaffID = s.StaffID
INNER JOIN OrderDetails d ON o.OrderID = d.OrderID
GROUP BY s.FirstName, s.LastName
ORDER BY TotalSales DESC;
GO

-- 4.17 Orders taken on the terrace
SELECT o.OrderID, t.TableNumber, t.Location, o.OrderDate
FROM   Orders o
INNER JOIN RestaurantTables t ON o.TableID = t.TableID
WHERE  t.Location = 'Terrace';
GO


/*====================================================================
  SECTION 5 : FULL SYLLABUS COVERAGE  (Lec08 - Lec13)
  Every topic from the remaining lectures, applied to this project.
  Run any of these live if he asks for them.
====================================================================*/

/* -------------------------------------------------------------
   5.1  FUNCTIONS  (Lec09)
   AVG, COUNT, MAX, MIN, SUM + string / date / math functions
------------------------------------------------------------- */

-- Average price of a dish
SELECT AVG(Price) AS AveragePrice FROM MenuItems;
GO

-- Cheapest and most expensive dish price
SELECT MIN(Price) AS Cheapest, MAX(Price) AS MostExpensive FROM MenuItems;
GO

-- How many dishes / how many different categories are used
SELECT COUNT(*)                  AS TotalDishes,
       COUNT(DISTINCT CategoryID) AS CategoriesUsed
FROM   MenuItems;
GO

-- Total money earned
SELECT SUM(Quantity * UnitPrice) AS TotalRevenue FROM OrderDetails;
GO

-- String functions: UPPER, LOWER, LEN, SUBSTRING, CONCAT
SELECT  UPPER(ItemName)              AS UpperName,
        LOWER(ItemName)              AS LowerName,
        LEN(ItemName)                AS NameLength,
        SUBSTRING(ItemName, 1, 5)    AS First5Letters,
        CONCAT(ItemName, ' - ', Price, ' PLN') AS MenuLabel
FROM    MenuItems;
GO

-- Math functions: ABS, SQRT, SQUARE
SELECT  ItemName,
        Price,
        SQUARE(Price)          AS PriceSquared,
        SQRT(Price)            AS PriceSquareRoot,
        ABS(Price - 50)        AS DistanceFrom50
FROM    MenuItems;
GO

-- Date function: GETDATE() - how many days ago was the order
SELECT  OrderID,
        OrderDate,
        GETDATE()                            AS Today,
        DATEDIFF(DAY, OrderDate, GETDATE())  AS DaysAgo
FROM    Orders;
GO

/* -------------------------------------------------------------
   5.2  GROUP BY and HAVING  (Lec09)
------------------------------------------------------------- */

-- How many dishes in each category
SELECT  c.CategoryName, COUNT(*) AS NumberOfDishes
FROM    MenuItems m
INNER JOIN Categories c ON m.CategoryID = c.CategoryID
GROUP BY c.CategoryName;
GO

-- Total spent by every customer
SELECT  c.FirstName + ' ' + c.LastName AS Customer,
        SUM(d.Quantity * d.UnitPrice)  AS TotalSpent
FROM    Customers c
INNER JOIN Orders       o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails d ON o.OrderID    = d.OrderID
GROUP BY c.FirstName, c.LastName
ORDER BY TotalSpent DESC;
GO

-- HAVING : only the customers who spent more than 300
SELECT  c.FirstName + ' ' + c.LastName AS Customer,
        SUM(d.Quantity * d.UnitPrice)  AS TotalSpent
FROM    Customers c
INNER JOIN Orders       o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails d ON o.OrderID    = d.OrderID
GROUP BY c.FirstName, c.LastName
HAVING  SUM(d.Quantity * d.UnitPrice) > 300;
GO

-- HAVING : categories that contain more than 3 dishes
SELECT  c.CategoryName, COUNT(*) AS NumberOfDishes
FROM    MenuItems m
INNER JOIN Categories c ON m.CategoryID = c.CategoryID
GROUP BY c.CategoryName
HAVING  COUNT(*) > 3;
GO

/* -------------------------------------------------------------
   5.3  SUBQUERY  (Lec08)
------------------------------------------------------------- */

-- Customers who have actually placed an order
SELECT FirstName, LastName
FROM   Customers
WHERE  CustomerID IN (SELECT CustomerID FROM Orders);
GO

-- Customers who have NEVER placed an order
SELECT FirstName, LastName
FROM   Customers
WHERE  CustomerID NOT IN (SELECT CustomerID FROM Orders);
GO

-- Dishes that were never ordered
SELECT ItemName, Price
FROM   MenuItems
WHERE  MenuItemID NOT IN (SELECT MenuItemID FROM OrderDetails);
GO

-- Dishes that cost more than the average dish
SELECT ItemName, Price
FROM   MenuItems
WHERE  Price > (SELECT AVG(Price) FROM MenuItems);
GO

/* -------------------------------------------------------------
   5.4  UNION / UNION ALL / INTERSECT / EXCEPT  (Lec08)
------------------------------------------------------------- */

-- One phone list of everybody: customers and staff together
SELECT FirstName, LastName, 'Customer' AS PersonType FROM Customers
UNION
SELECT FirstName, LastName, 'Staff'    AS PersonType FROM Staff;
GO

-- UNION ALL keeps duplicates, UNION removes them
SELECT City FROM Customers
UNION ALL
SELECT Location FROM RestaurantTables;
GO

-- INTERSECT : first names that belong to a customer AND to a staff member
SELECT FirstName FROM Customers
INTERSECT
SELECT FirstName FROM Staff;
GO

-- EXCEPT : dishes that exist on the menu but were never sold
SELECT MenuItemID FROM MenuItems
EXCEPT
SELECT MenuItemID FROM OrderDetails;
GO

/* -------------------------------------------------------------
   5.5  SELECT INTO - creating a new table from a query  (Lec09)
------------------------------------------------------------- */

-- Build a backup table of expensive dishes
IF OBJECT_ID('ExpensiveDishes') IS NOT NULL DROP TABLE ExpensiveDishes;
SELECT ItemName, Price
INTO   ExpensiveDishes
FROM   MenuItems
WHERE  Price > 50;
GO

SELECT * FROM ExpensiveDishes;
GO

/* -------------------------------------------------------------
   5.6  INSERT / UPDATE / DELETE  (Lec10)
   Run these to show he can change the data live.
------------------------------------------------------------- */

-- INSERT a new dish (IsAvailable is left out on purpose:
-- the DEFAULT constraint fills it with 1)
INSERT INTO MenuItems (ItemName, CategoryID, Price, PreparationTime, Calories)
VALUES ('Greek Salad', 1, 28.00, 10, 240);
GO

SELECT * FROM MenuItems WHERE ItemName = 'Greek Salad';
GO

-- UPDATE : raise the price of all pizzas by 10%
UPDATE MenuItems
SET    Price = Price * 1.10
WHERE  CategoryID = 4;
GO

SELECT ItemName, Price FROM MenuItems WHERE CategoryID = 4;
GO

-- UPDATE a single row
UPDATE Customers
SET    IsVIP = 1
WHERE  LastName = 'Nowak';
GO

-- DELETE the test dish again
DELETE FROM MenuItems WHERE ItemName = 'Greek Salad';
GO

/* -------------------------------------------------------------
   5.7  ALTER TABLE - ADD / ALTER / DROP COLUMN  (Lec13)
------------------------------------------------------------- */

-- ADD a new column
ALTER TABLE MenuItems ADD IsVegetarian BIT NULL;
GO

-- Fill it with data
UPDATE MenuItems SET IsVegetarian = 1
WHERE ItemName IN ('Margherita Pizza', 'Four Cheese Pizza',
                   'Tomato Soup', 'Garlic Bread', 'Bruschetta');
GO

UPDATE MenuItems SET IsVegetarian = 0 WHERE IsVegetarian IS NULL;
GO

SELECT ItemName, IsVegetarian FROM MenuItems WHERE IsVegetarian = 1;
GO

-- ALTER a column data type
ALTER TABLE MenuItems ALTER COLUMN ItemName NVARCHAR(100) NOT NULL;
GO

-- DROP the column again
ALTER TABLE MenuItems DROP COLUMN IsVegetarian;
GO

/* -------------------------------------------------------------
   5.8  CREATE / DROP VIEW and TABLE  (Lec12, Lec13)
------------------------------------------------------------- */

-- Create a view live
IF OBJECT_ID('vw_CheapDishes') IS NOT NULL DROP VIEW vw_CheapDishes;
GO

CREATE VIEW vw_CheapDishes AS
SELECT ItemName, Price
FROM   MenuItems
WHERE  Price < 20;
GO

SELECT * FROM vw_CheapDishes;
GO

-- Drop it again
DROP VIEW vw_CheapDishes;
GO

-- Create a small table, empty it, then remove it completely
CREATE TABLE TestTable (
    TestID   INT          NOT NULL PRIMARY KEY,
    TestName NVARCHAR(50) NOT NULL
);
GO

INSERT INTO TestTable (TestID, TestName) VALUES (1, 'Sample');
GO

TRUNCATE TABLE TestTable;   -- empties the table, keeps the structure
GO

DROP TABLE TestTable;       -- removes the table completely
GO

-- Clean up the backup table made in 5.5
DROP TABLE ExpensiveDishes;
GO

/**********************************************************************
  END OF SCRIPT
**********************************************************************/
