USE PortOps_DW;
GO
-- 1. CREATE dim_date
CREATE TABLE Mart.dim_date (
    DateKey             INT PRIMARY KEY,
    FullDate            DATE NOT NULL,
    DateName            VARCHAR(30),
    DayNumber           TINYINT,
    DayName             VARCHAR(15),
    MonthNumber         TINYINT,
    MonthName           VARCHAR(15),
    QuarterNumber       TINYINT,
    QuarterName         VARCHAR(10),
    Year                SMALLINT,
    FiscalYear          SMALLINT,
    FiscalQuarter       TINYINT,
    FiscalMonth         TINYINT,
    FiscalMonthName     VARCHAR(15),   
    IsWeekend           BIT,
    IsHoliday           BIT DEFAULT 0,
    LoadDate            DATETIME DEFAULT GETDATE()
);
GO
-- 2. dim_customer (SCD Type 2) 
CREATE TABLE Mart.dim_customer (
    CustomerSK          INT IDENTITY(1,1) PRIMARY KEY,
    customer_id         INT NOT NULL,                    
    -- Type 1 Attributes (Overwrite on change)
    customer_code       VARCHAR(20),
    customer_name       VARCHAR(100),
    country             NVARCHAR(100),                  
    active_flag         BIT,
    onboarded_date      DATE,  
    -- Type 2 Attributes (Track History)
    customer_tier       VARCHAR(20),
    credit_limit        DECIMAL(15,2),
    effective_from      DATE NOT NULL,
    effective_to        DATE NOT NULL DEFAULT '9999-12-31',
    is_current          BIT NOT NULL DEFAULT 1,
    LoadDate            DATETIME DEFAULT GETDATE()
);
GO
-- 3. dim_terminal (Type 1)
CREATE TABLE Mart.dim_terminal (
    TerminalSK          INT IDENTITY(1,1) PRIMARY KEY,
    terminal_id         INT NOT NULL,
    terminal_code       VARCHAR(10),
    terminal_name       NVARCHAR(100),
    zone                VARCHAR(50),
    terminal_type       VARCHAR(50),
    LoadDate            DATETIME DEFAULT GETDATE()
);
GO
-- 4. dim_equipment (Type 1)
CREATE TABLE Mart.dim_equipment (
    EquipmentSK         INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id        INT NOT NULL,
    equipment_code      VARCHAR(20),
    equipment_type      VARCHAR(50),
    terminal_id         INT,
    capacity_tons       INT,
    acquired_date       DATE,
    status              VARCHAR(20),
    LoadDate            DATETIME DEFAULT GETDATE()
);
GO
-- 5. dim_shift (Type 1 - Static)
CREATE TABLE Mart.dim_shift (
    ShiftSK             INT IDENTITY(1,1) PRIMARY KEY,
    shift_id            INT NOT NULL,
    shift_code          VARCHAR(10),
    shift_name          NVARCHAR(50),
    start_time          TIME,
    end_time            TIME,
    LoadDate            DATETIME DEFAULT GETDATE()
);
GO
-- dim_customer
SET IDENTITY_INSERT Mart.dim_customer ON;
INSERT INTO Mart.dim_customer (CustomerSK, customer_id, customer_tier, credit_limit, customer_code, customer_name, country, active_flag, effective_from, effective_to, is_current)
VALUES (-1, -1, 'Unknown', 0, 'Unknown', 'Unknown', 'Unknown', 0, '1900-01-01', '9999-12-31', 1);
SET IDENTITY_INSERT Mart.dim_customer OFF;
GO

-- dim_terminal
SET IDENTITY_INSERT Mart.dim_terminal ON;
INSERT INTO Mart.dim_terminal (TerminalSK, terminal_id, terminal_code, terminal_name, zone, terminal_type)
VALUES (-1, -1, 'Unknown', 'Unknown', 'Unknown', 'Unknown');
SET IDENTITY_INSERT Mart.dim_terminal OFF;
GO

-- dim_equipment
SET IDENTITY_INSERT Mart.dim_equipment ON;
INSERT INTO Mart.dim_equipment (EquipmentSK, equipment_id, equipment_code, equipment_type, terminal_id, capacity_tons, status)
VALUES (-1, -1, 'Unknown', 'Unknown', -1, 0, 'Unknown');
SET IDENTITY_INSERT Mart.dim_equipment OFF;
GO

-- dim_shift
SET IDENTITY_INSERT Mart.dim_shift ON;
INSERT INTO Mart.dim_shift (ShiftSK, shift_id, shift_code, shift_name, start_time, end_time)
VALUES (-1, -1, 'Unknown', 'Unknown', '00:00', '00:00');
SET IDENTITY_INSERT Mart.dim_shift OFF;
GO
---------------------------------------------------
--Facts 
--
CREATE TABLE Mart.fact_container_movement (
    MovementSK              INT IDENTITY(1,1) PRIMARY KEY,
    DateKey                 INT,                    -- гд move_start_time
    CustomerFK              INT,
    TerminalFK              INT,
    EquipmentFK             INT,
    ShiftFK                 INT,
    movement_id             BIGINT,
    container_no            VARCHAR(20),
    vessel_call_id          INT,
    move_type               VARCHAR(20),
    container_size          VARCHAR(20),
    is_reefer               BIT,
    weight_tons             DECIMAL(10,2),
    crane_cycle_seconds     INT,
    
    LoadDate                DATETIME DEFAULT GETDATE()
);
