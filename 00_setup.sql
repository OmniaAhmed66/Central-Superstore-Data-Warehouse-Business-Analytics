IF DB_ID('central_superstore') IS NULL
BEGIN
    CREATE DATABASE central_superstore;
END;
GO

USE central_superstore;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'staging')
    EXEC('CREATE SCHEMA staging');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO
