# Restaurant Management Database (SQL Server)

A restaurant management database built in Microsoft SQL Server as a university team project.

## Features
- 7 tables: Categories, MenuItems, Customers, Staff, RestaurantTables, Orders, OrderDetails
- 6 views: full menu, available menu, order summary, order lines, popular dishes, unpaid orders
- Constraints: primary keys, foreign keys, UNIQUE, NOT NULL, DEFAULT
- Sample data and example queries (joins, GROUP BY / HAVING, subqueries, UNION / INTERSECT / EXCEPT)

## Design note
Orders and MenuItems have a many-to-many relationship, resolved with the OrderDetails bridge table. UnitPrice is stored on each order line so past bills do not change when menu prices change.

## ER diagram
See ER_Diagram_Restaurant.pdf

## Run it
1. Open RestaurantDB_Project.sql in SQL Server Management Studio.
2. Press F5. The database, tables, data and views are created automatically.

## Tech
Microsoft SQL Server, T-SQL, SSMS
