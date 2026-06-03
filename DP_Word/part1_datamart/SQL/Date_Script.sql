
DECLARE @StartDate DATE = '2025-01-01';
DECLARE @EndDate   DATE = '2026-06-30';

WITH DateSeries AS (
    SELECT @StartDate AS FullDate
    UNION ALL
    SELECT DATEADD(DAY, 1, FullDate)
    FROM DateSeries
    WHERE FullDate < @EndDate
)
INSERT INTO Mart.dim_date (
    DateKey, FullDate, DateName, DayNumber, DayName, 
    MonthNumber, MonthName, QuarterNumber, QuarterName, 
    Year, FiscalYear, FiscalQuarter, FiscalMonth, 
    FiscalMonthName, IsWeekend, IsHoliday
)
SELECT 
    CONVERT(INT, FORMAT(FullDate, 'yyyyMMdd')) AS DateKey,
    FullDate,
    FORMAT(FullDate, 'dd MMM yyyy') AS DateName,
    DAY(FullDate) AS DayNumber,
    FORMAT(FullDate, 'dddd') AS DayName,
    MONTH(FullDate) AS MonthNumber,
    FORMAT(FullDate, 'MMMM') AS MonthName,
    DATEPART(QUARTER, FullDate) AS QuarterNumber,
    'Q' + CAST(DATEPART(QUARTER, FullDate) AS VARCHAR) AS QuarterName,
    YEAR(FullDate) AS Year,
    
    -- Fiscal Year starts 1 April
    CASE WHEN MONTH(FullDate) >= 4 THEN YEAR(FullDate) ELSE YEAR(FullDate)-1 END AS FiscalYear,
    CASE WHEN MONTH(FullDate) >= 4 
         THEN ((MONTH(FullDate)-4)/3)+1 
         ELSE ((MONTH(FullDate)+8)/3)+1 END AS FiscalQuarter,
    CASE WHEN MONTH(FullDate) >= 4 THEN MONTH(FullDate)-3 ELSE MONTH(FullDate)+9 END AS FiscalMonth,
    FORMAT(DATEADD(MONTH, 
         CASE WHEN MONTH(FullDate) >= 4 THEN MONTH(FullDate)-4 
              ELSE MONTH(FullDate)+8 END, '1900-01-01'), 'MMMM') AS FiscalMonthName,
    
    CASE WHEN DATEPART(WEEKDAY, FullDate) IN (1,7) THEN 1 ELSE 0 END AS IsWeekend,
    
    -- Egyptian Holidays 2025-2026
    CASE WHEN FullDate IN (
        -- 2025
        '2025-01-01', '2025-01-07', '2025-04-18', '2025-05-01', 
        '2025-06-06','2025-06-07','2025-06-08', -- Eid Al-Fitr
        '2025-07-23', 
        '2025-09-05','2025-09-06','2025-09-07', -- Eid Al-Adha
        '2025-10-06', 
        '2025-10-23', -- Moulid El Nabi (approx)
        -- 2026
        '2026-01-01', '2026-01-07', '2026-04-18', '2026-05-01',
        '2026-06-06','2026-06-07','2026-06-08'
    ) THEN 1 ELSE 0 END AS IsHoliday

FROM DateSeries
OPTION (MAXRECURSION 0);
GO
SELECT 
    FiscalYear, 
    COUNT(*) AS TotalDays,
    SUM(CAST(IsHoliday AS INT)) AS HolidayCount,
    SUM(CAST(IsWeekend AS INT)) AS WeekendCount,
    COUNT(*) - SUM(CAST(IsHoliday AS INT)) - SUM(CAST(IsWeekend AS INT)) AS WorkingDays
FROM Mart.dim_date 
GROUP BY FiscalYear
ORDER BY FiscalYear;