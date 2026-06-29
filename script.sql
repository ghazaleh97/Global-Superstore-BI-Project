USE GlobalSuperstoreDW;
GO
CREATE TABLE dbo.stg_Sales (
    Category        NVARCHAR(50),
    City            NVARCHAR(100),
    Country         NVARCHAR(100),
    [Customer ID]   NVARCHAR(50),
    [Customer Name] NVARCHAR(100),
    Discount        FLOAT,
    Market          NVARCHAR(50),
    [记录数]        INT NULL,
    [Order Date]    DATE,
    [Order ID]      NVARCHAR(50),
    [Order Priority] NVARCHAR(50),
    [Product ID]    NVARCHAR(50),
    [Product Name]  NVARCHAR(200),
    Profit          FLOAT,
    Quantity        INT,
    Region          NVARCHAR(50),
    [Row ID]        INT,
    Sales           FLOAT,
    Segment         NVARCHAR(50),
    [Ship Date]     DATE,
    [Ship Mode]     NVARCHAR(50),
    [Shipping Cost] FLOAT,
    State           NVARCHAR(100),
    [Sub-Category]  NVARCHAR(50),
    Year            INT,
    Market2         NVARCHAR(50),
    weeknum         INT
);
GO
CREATE TABLE dbo.stg_Login (
    [User ID]    NVARCHAR(50),
    Market       NVARCHAR(50),
    [market.1]   NVARCHAR(50),
    [Log in Date] DATETIME
);
GO
USE GlobalSuperstoreDW;
GO

BULK INSERT dbo.stg_Sales
FROM 'C:\Program Files\Microsoft SQL Server\Global Superstore.txt'
WITH (
    DATAFILETYPE = 'char',
    FIELDTERMINATOR = '\t',       
    ROWTERMINATOR   = '\n',
    FIRSTROW        = 2,          
    CODEPAGE        = '65001'     
);
GO
USE GlobalSuperstoreDW;
GO

BULK INSERT dbo.stg_Login
FROM 'C:\Program Files\Microsoft SQL Server\Global Superstore_login_Data.txt'
WITH (
    DATAFILETYPE = 'char',
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR   = '\n',
    FIRSTROW        = 2,
    CODEPAGE        = '65001'
);
GO
SELECT TOP 5 * FROM dbo.stg_Sales;
SELECT TOP 5 * FROM dbo.stg_Login;

USE GlobalSuperstoreDW;
GO
-- dimDate
CREATE TABLE dbo.DimDate (
    DateKey        INT         NOT NULL PRIMARY KEY,
    FullDate       DATE        NOT NULL,
    [Year]         INT         NOT NULL,
    [Quarter]      INT         NOT NULL,
    [Month]        INT         NOT NULL,
    MonthName      NVARCHAR(20) NOT NULL,
    [Day]          INT         NOT NULL,
    DayName        NVARCHAR(20) NOT NULL,
    IsWeekend      BIT         NOT NULL
);
GO
INSERT INTO dbo.DimDate (
    DateKey, FullDate, [Year], [Quarter], [Month],
    MonthName, [Day], DayName, IsWeekend
)
SELECT DISTINCT
    CONVERT(INT, FORMAT([Order Date], 'yyyyMMdd')) AS DateKey,
    [Order Date] AS FullDate,
    YEAR([Order Date]) AS [Year],
    DATEPART(QUARTER, [Order Date]) AS [Quarter],
    MONTH([Order Date]) AS [Month],
    DATENAME(MONTH, [Order Date]) AS MonthName,
    DAY([Order Date]) AS [Day],
    DATENAME(WEEKDAY, [Order Date]) AS DayName,
    CASE WHEN DATENAME(WEEKDAY, [Order Date]) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS IsWeekend
FROM dbo.stg_Sales
WHERE [Order Date] IS NOT NULL;
GO
SELECT TOP 10 * FROM dbo.DimDate ORDER BY FullDate;
USE GlobalSuperstoreDW;
GO
 -- dimCustomer
CREATE TABLE dbo.DimCustomer (
    CustomerKey      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Customer ID]    NVARCHAR(50) NOT NULL,
    [Customer Name]  NVARCHAR(100) NOT NULL,
    Segment          NVARCHAR(50),
    City             NVARCHAR(100),
    State            NVARCHAR(100),
    Country          NVARCHAR(100),
    Market           NVARCHAR(50)
);
GO
INSERT INTO dbo.DimCustomer (
    [Customer ID], [Customer Name], Segment, City, State, Country, Market
) 
SELECT DISTINCT
    [Customer ID],
    [Customer Name],
    Segment,
    City,
    State,
    Country,
    Market
FROM dbo.stg_Sales
WHERE [Customer ID] IS NOT NULL;
GO
SELECT TOP 5 * FROM dbo.DimCustomer;
GO
-- dimProduct
CREATE TABLE dbo.DimProduct (
    ProductKey      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Product ID]    NVARCHAR(50) NOT NULL,
    [Product Name]  NVARCHAR(200) NOT NULL,
    Category        NVARCHAR(50),
    [Sub-Category]  NVARCHAR(50)
);
GO
INSERT INTO dbo.DimProduct (
    [Product ID], [Product Name], Category, [Sub-Category]
)
SELECT DISTINCT
    [Product ID],
    [Product Name],
    Category,
    [Sub-Category]
FROM dbo.stg_Sales
WHERE [Product ID] IS NOT NULL;
GO
SELECT TOP 5 * FROM dbo.DimProduct;
GO
-- Fact sale

USE GlobalSuperstoreDW;
GO

CREATE TABLE dbo.FactSales (
    SalesKey         INT IDENTITY(1,1) PRIMARY KEY,
    DateKey          INT, -- برای اتصال به DimDate
    CustomerKey      INT, -- برای اتصال به DimCustomer
    ProductKey       INT, -- برای اتصال به DimProduct
    Sales            FLOAT,
    Quantity         INT,
    Profit           FLOAT,
    Discount         FLOAT
);
GO
INSERT INTO dbo.FactSales (DateKey, CustomerKey, ProductKey, Sales, Quantity, Profit, Discount)
SELECT 
    d.DateKey,
    c.CustomerKey,
    p.ProductKey,
    s.Sales,
    s.Quantity,
    s.Profit,
    s.Discount
FROM dbo.stg_Sales s
JOIN dbo.DimDate d ON CAST(s.[Order Date] AS DATE) = d.FullDate
JOIN dbo.DimCustomer c ON s.[Customer ID] = c.[Customer ID]
JOIN dbo.DimProduct p ON s.[Product ID] = p.[Product ID];
GO
SELECT TOP 10 * FROM dbo.FactSales;
GO
