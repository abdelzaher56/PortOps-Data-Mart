CREATE DATABASE PortOps_DW;
GO

USE PortOps_DW;
GO

-- Schemas
CREATE SCHEMA Staging;
CREATE SCHEMA Mart;
CREATE SCHEMA Audit;
GO
--DDL for Staging 
-- 1. Customers Staging
create table staging.Customers(
	customer_id			int,
	customer_code		VARCHAR(20),
	customer_name		NVARCHAR(100),
	country				VARCHAR(50),
	customer_tier		VARCHAR(20),
	credit_limit		DECIMAL(15,2),
	active_flag			BIT,
	onboarded_date		DATE,
	LoadDate            DATETIME DEFAULT GETDATE()
);
-- 2. CustomerHistory Staging
CREATE TABLE Staging.CustomerHistory (
    customer_id         INT,
    effective_from      DATE,
    effective_to        DATE,
    customer_tier       VARCHAR(20),
    credit_limit        DECIMAL(15,2),
    change_reason       VARCHAR(100),
    LoadDate            DATETIME DEFAULT GETDATE()
);
-- 3. Terminals Staging
CREATE TABLE Staging.Terminals (
    terminal_id         INT,
    terminal_code       VARCHAR(10),
    terminal_name       NVARCHAR(100),
    zone                VARCHAR(50),
    terminal_type       VARCHAR(50),
    LoadDate            DATETIME DEFAULT GETDATE()
);
-- 4. Equipment Staging
CREATE TABLE Staging.Equipment (
    equipment_id        INT,
    equipment_code      VARCHAR(20),
    equipment_type      VARCHAR(50),
    terminal_id         INT,
    capacity_tons       INT,
    acquired_date       DATE,
    status              VARCHAR(20),
    LoadDate            DATETIME DEFAULT GETDATE()
);
-- 5. Shifts Staging
CREATE TABLE Staging.Shifts (
    shift_id            INT,
    shift_code          VARCHAR(10),
    shift_name          NVARCHAR(50),
    start_time          TIME,
    end_time            TIME,
    LoadDate            DATETIME DEFAULT GETDATE()
);
-- 6. VesselCalls Staging
CREATE TABLE Staging.VesselCalls (
    vessel_call_id          INT,
    vessel_name             NVARCHAR(100),
    voyage_no               VARCHAR(20),
    customer_id             INT,
    terminal_id             INT,
    eta                     DATETIME,
    ata                     DATETIME,
    atd                     DATETIME,
    total_moves_planned     INT,
    total_moves_actual      INT,
    status                  VARCHAR(20),
    LoadDate                DATETIME DEFAULT GETDATE()
);
--7. ContainerMovements Staging
CREATE TABLE Staging.ContainerMovements (
    movement_id         BIGINT,
    vessel_call_id      INT,
    container_no        VARCHAR(20),
    container_size      VARCHAR(20),      
    move_type           VARCHAR(20),      
    equipment_id        INT,
    shift_id            INT,
    customer_id         INT,
    terminal_id         INT,
    move_start_time     DATETIME,
    move_end_time       DATETIME,
    is_reefer           BIT,
    weight_tons         DECIMAL(10,2),
    LoadDate            DATETIME DEFAULT GETDATE()
);
-- 8. GateTransactions Staging
CREATE TABLE Staging.GateTransactions (
    gate_txn_id             BIGINT,
    truck_plate             VARCHAR(20),
    container_no            VARCHAR(20),
    customer_id             INT,
    terminal_id             INT,
    direction               VARCHAR(10),     
    gate_in_time            DATETIME,
    gate_out_time           DATETIME,
    shift_id                INT,
    LoadDate                DATETIME DEFAULT GETDATE()
);

-- CREATE Audit Table
CREATE TABLE Audit.AuditLog (
    AuditID             INT IDENTITY(1,1) PRIMARY KEY,
    PackageName         VARCHAR(100),
    StartTime           DATETIME,
    EndTime             DATETIME,
    RowsSource          INT,
    RowsLoaded          INT,
    Status              VARCHAR(20),     
    ErrorMessage        NVARCHAR(500),
    LoadDate            DATETIME DEFAULT GETDATE()
);
