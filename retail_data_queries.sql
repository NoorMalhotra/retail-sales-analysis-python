mysql> CREATE DATABASE RetailAnalyticsDB;
Query OK, 1 row affected (0.03 sec)

mysql> USE RetailAnalyticsDB;
Database changed
mysql> CREATE TABLE Customers (
    ->     CustomerID VARCHAR(10) PRIMARY KEY,
    ->     CustomerName VARCHAR(50),
    ->     Gender VARCHAR(10),
    ->     City VARCHAR(50),
    ->     JoinDate DATE
    -> );
Query OK, 0 rows affected (0.08 sec)

mysql> CREATE TABLE Products (
    ->     ProductID VARCHAR(10) PRIMARY KEY,
    ->     ProductName VARCHAR(50),
    ->     Category VARCHAR(50),
    ->     Price DECIMAL(10,2)
    -> );
Query OK, 0 rows affected (0.05 sec)

mysql> CREATE TABLE Sales (
    ->     SaleID VARCHAR(10) PRIMARY KEY,
    ->     SaleDate DATE,
    ->     CustomerID VARCHAR(10),
    ->     ProductID VARCHAR(10),
    ->     Quantity INT,
    ->     Region VARCHAR(20),
    ->
    ->     FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    ->     FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
    -> );
Query OK, 0 rows affected (0.10 sec)

mysql> INSERT INTO Customers VALUES
    -> ('C001','Rahul Sharma','Male','Mumbai','2022-01-15'),
    -> ('C002','Neha Verma','Female','Delhi','2021-11-20'),
    -> ('C003','Arjun Mehta','Male','Pune','2022-06-05'),
    -> ('C004','Kavita Rao','Female','Bangalore','2023-02-10'),
    -> ('C005','Aman Gupta','Male','Mumbai','2021-09-18'),
    -> ('C006','Pooja Nair','Female','Kochi','2022-03-12');
Query OK, 6 rows affected (0.04 sec)
Records: 6  Duplicates: 0  Warnings: 0

mysql> INSERT INTO Products VALUES
    -> ('P001','Laptop','Electronics',55000),
    -> ('P002','Headphones','Electronics',3000),
    -> ('P003','Office Chair','Furniture',12000),
    -> ('P004','Desk Lamp','Furniture',2500),
    -> ('P005','Smartphone','Electronics',32000),
    -> ('P006','Bookshelf','Furniture',18000);
Query OK, 6 rows affected (0.03 sec)
Records: 6  Duplicates: 0  Warnings: 0

mysql> INSERT INTO Sales VALUES
    -> ('S001','2023-01-10','C001','P001',1,'West'),
    -> ('S002','2023-01-12','C002','P003',2,'North'),
    -> ('S003','2023-02-05','C001','P002',3,'West'),
    -> ('S004','2023-02-20','C004','P004',2,'South'),
    -> ('S005','2023-03-02','C005','P005',1,'West'),
    -> ('S006','2023-03-15','C006','P006',1,'South');
Query OK, 6 rows affected (0.01 sec)
Records: 6  Duplicates: 0  Warnings: 0

mysql> SELECT SUM(s.Quantity * p.Price) AS Total_Revenue
    -> FROM Sales s
    -> JOIN Products p ON s.ProductID = p.ProductID;
+---------------+
| Total_Revenue |
+---------------+
|     143000.00 |
+---------------+
1 row in set (0.01 sec)

mysql> SELECT Region,
    -> SUM(s.Quantity * p.Price) AS Revenue
    -> FROM Sales s
    -> JOIN Products p ON s.ProductID = p.ProductID
    -> GROUP BY Region;
+--------+----------+
| Region | Revenue  |
+--------+----------+
| West   | 96000.00 |
| North  | 24000.00 |
| South  | 23000.00 |
+--------+----------+
3 rows in set (0.02 sec)

mysql> SELECT p.Category,
    -> SUM(s.Quantity * p.Price) AS Revenue
    -> FROM Sales s
    -> JOIN Products p ON s.ProductID = p.ProductID
    -> GROUP BY p.Category;
+-------------+----------+
| Category    | Revenue  |
+-------------+----------+
| Electronics | 96000.00 |
| Furniture   | 47000.00 |
+-------------+----------+
2 rows in set (0.00 sec)

mysql> SELECT MONTH(SaleDate) AS Month,
    -> SUM(s.Quantity * p.Price) AS Revenue
    -> FROM Sales s
    -> JOIN Products p ON s.ProductID = p.ProductID
    -> GROUP BY MONTH(SaleDate);
+-------+----------+
| Month | Revenue  |
+-------+----------+
|     1 | 79000.00 |
|     2 | 14000.00 |
|     3 | 50000.00 |
+-------+----------+
3 rows in set (0.02 sec)

mysql> SELECT c.CustomerName,
    -> SUM(s.Quantity * p.Price) AS Revenue
    -> FROM Sales s
    -> JOIN Customers c ON s.CustomerID = c.CustomerID
    -> JOIN Products p ON s.ProductID = p.ProductID
    -> GROUP BY c.CustomerName
    -> ORDER BY Revenue DESC
    -> LIMIT 3;
+--------------+----------+
| CustomerName | Revenue  |
+--------------+----------+
| Rahul Sharma | 64000.00 |
| Aman Gupta   | 32000.00 |
| Neha Verma   | 24000.00 |
+--------------+----------+
3 rows in set (0.02 sec)

mysql> SELECT ProductID,
    -> SUM(Quantity) AS Total_Quantity
    -> FROM Sales
    -> GROUP BY ProductID;
+-----------+----------------+
| ProductID | Total_Quantity |
+-----------+----------------+
| P001      |              1 |
| P002      |              3 |
| P003      |              2 |
| P004      |              2 |
| P005      |              1 |
| P006      |              1 |
+-----------+----------------+
6 rows in set (0.02 sec)

mysql> SELECT AVG(s.Quantity * p.Price) AS Avg_Order_Value
    -> FROM Sales s
    -> JOIN Products p ON s.ProductID = p.ProductID;
+-----------------+
| Avg_Order_Value |
+-----------------+
|    23833.333333 |
+-----------------+
1 row in set (0.02 sec)

mysql> SELECT CustomerID,
    -> COUNT(*) AS Orders_Count
    -> FROM Sales
    -> GROUP BY CustomerID
    -> HAVING COUNT(*) > 1;
+------------+--------------+
| CustomerID | Orders_Count |
+------------+--------------+
| C001       |            2 |
+------------+--------------+
1 row in set (0.02 sec)

mysql> SELECT c.City,
    -> SUM(s.Quantity * p.Price) AS Revenue
    -> FROM Sales s
    -> JOIN Customers c ON s.CustomerID = c.CustomerID
    -> JOIN Products p ON s.ProductID = p.ProductID
    -> GROUP BY c.City
    -> ORDER BY Revenue DESC;
+-----------+----------+
| City      | Revenue  |
+-----------+----------+
| Mumbai    | 96000.00 |
| Delhi     | 24000.00 |
| Kochi     | 18000.00 |
| Bangalore |  5000.00 |
+-----------+----------+
4 rows in set (0.00 sec)

mysql> SELECT Category, ProductName, Revenue
    -> FROM (
    -> SELECT p.Category,
    -> p.ProductName,
    -> SUM(s.Quantity * p.Price) AS Revenue,
    -> RANK() OVER(PARTITION BY p.Category ORDER BY SUM(s.Quantity*p.Price) DESC) rnk
    -> FROM Sales s
    -> JOIN Products p ON s.ProductID = p.ProductID
    -> GROUP BY p.Category, p.ProductName
    -> ) x
    -> WHERE rnk = 1;
+-------------+--------------+----------+
| Category    | ProductName  | Revenue  |
+-------------+--------------+----------+
| Electronics | Laptop       | 55000.00 |
| Furniture   | Office Chair | 24000.00 |
+-------------+--------------+----------+
2 rows in set (0.02 sec)
