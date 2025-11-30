# Database Course Project

This repository contains my database course project implemented in Microsoft SQL Server.

## Project overview

The project models a small **Xiaomi online store**.  
The database includes the following main tables:

- `Customers`
- `Orders`
- `Products`
- `Suppliers`
- `Categories`
- `OrderItems` (junction table for many-to-many relationship between Orders and Products)
- `Payments`

## Implemented requirements

- Primary and foreign keys, many-to-many relationship via `OrderItems`
- Several **indexes** (unique and non-unique)
- **Data manipulation** examples: `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`
- **SELECT** queries with `COUNT`, `SUM`, `AVG`, `GROUP BY`, `ORDER BY`, pagination with `OFFSET ... FETCH`
- **JOIN** examples: `INNER JOIN`, `LEFT JOIN`, multi-table JOIN
- One **view**: `VIEW_CustomerOrderSummary`
- One **stored procedure**: `GetOrdersByCustomer`
- One **scalar function**: `GetTotalSpent`
- One **trigger**: `trg_UpdateStock` (updates product stock after insert into `OrderItems`)
- One **transaction** example with `BEGIN TRANSACTION` / `COMMIT`

## How to run

1. Open the script `CourseProject.sql` in SQL Server Management Studio.
2. Execute the whole script from the beginning.
3. The script creates the database, tables, inserts sample data and demonstrates queries, view, procedure, function and trigger.

## Files

- `CourseProject.sql` – main SQL script with all objects and sample queries.
- `Database_Project_Hlib_Donets.pptx` – presentation for the project defence.
- `ERD_XiaomiStore.png` – ERD diagram of the database.
