Global Superstore End-to-End BI Project

This repository contains an end-to-end Business Intelligence project. The goal is to design a standard Data Warehouse (DWH) from transactional sales data and build an interactive executive dashboard for decision-making.

---

 Tech Stack & Tools
*   **Database Engine:** SQL Server (T-SQL)
*   **Data Modeling:** Star Schema (Fact & Dimension Tables)
*   **Visualization & Analytics:** Power BI Desktop
*   **Data Connection Mode:** Import Mode
*   **Calculations:** DAX (Data Analysis Expressions)

---

 1. Data Warehouse Architecture (SQL Server)
The source data (`Global Superstore`) was processed and modeled into a clean **Star Schema** using SQL Server.

Schema Design
The project features 1 Fact Table and 3 Dimension Tables:
*   **`FactSales`**: Contains transaction metrics (Sales, Profit, Quantity, Discount) and surrogate keys.
*   **`DimDate`**: Time intelligence details (Year, Quarter, Month, Day, Weekday).
*   **`DimCustomer`**: Customer demographics (ID, Name, Segment, Country, City).
*   **`DimProduct`**: Product details (ID, Name, Category, Sub-Category).

**All SQL Scripts** (including Database Creation, Schema Design, Data Insertion, and Joins) are fully documented in [`script.sql`](./script.sql) in this repository.
 2. Power BI Dashboard & Analysis
An interactive dashboard was built to analyze sales performance and key business KPIs.

### 🔑 Key Measures & DAX
To analyze profitability, a custom **Profit Margin** measure was created using DAX:

$$\text{Profit Margin} = \frac{\text{Total Profit}}{\text{Total Sales}}$$
```dax
Profit Margin = DIVIDE(SUM(FactSales[Profit]), SUM(FactSales[Sales]), 0)
