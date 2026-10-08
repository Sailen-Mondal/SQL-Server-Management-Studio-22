USE [ADOPractice];
GO

-- Idempotent: drop if exists, then create
IF OBJECT_ID('dbo.Vehicles', 'U') IS NOT NULL
    DROP TABLE dbo.Vehicles;
GO

CREATE TABLE dbo.Vehicles
(
    Id              INT             IDENTITY(1,1)   PRIMARY KEY,
    VIN             VARCHAR(17)     NOT NULL        UNIQUE,
    Make            NVARCHAR(50)    NOT NULL,
    Model           NVARCHAR(50)    NOT NULL,
    Year            INT             NOT NULL,
    OdometerReading DECIMAL(12,2)   NOT NULL        DEFAULT 0.00,
    IsActive        BIT             NOT NULL        DEFAULT 1,
    CreatedAt       DATETIME2       NOT NULL        DEFAULT SYSDATETIME(),
    UpdatedAt       DATETIME2       NULL
);
GO

-- Seed Data: 10 vehicles for testing
INSERT INTO dbo.Vehicles (VIN, Make, Model, Year, OdometerReading, IsActive)
VALUES
    ('1HGBH41JXMN109186', 'Honda',       'Civic',           2021, 34500.75,  1),
    ('5YJSA1DG9DFP14705', 'Tesla',       'Model S',         2023, 12000.00,  1),
    ('WBA3A5C51CF256789', 'BMW',         '328i',            2020, 67890.50,  1),
    ('1FTFW1ET5EKE31234', 'Ford',        'F-150',           2024, 8750.30,   1),
    ('3C6UR5CL2JG123456', 'RAM',         '2500 Heavy Duty', 2022, 102340.00, 1),
    ('1GC4YVEY0MF234567', 'Chevrolet',   'Silverado 3500',  2019, 189200.45, 1),
    ('WVWZZZ3CZWE345678', 'Volkswagen',  'Passat',          2017, 245000.00, 0),
    ('JN1TBNT30Z0456789', 'Nissan',      'Altima',          2018, 178500.25, 0),
    ('JTDKN3DU5A0567890', 'Toyota',      'Prius',           2025, 0.00,      1),
    ('4T1BF1FK7HU678901', 'Toyota',      'Camry',           2016, 320450.80, 1);
GO

-- Simulate a previously updated record
UPDATE dbo.Vehicles
SET OdometerReading = 105000.00,
    UpdatedAt       = SYSDATETIME()
WHERE VIN = '3C6UR5CL2JG123456';
GO