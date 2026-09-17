USE central_superstore;
GO


TRUNCATE TABLE staging.staging_superstore;

BULK INSERT staging.staging_superstore
FROM 'C:\Users\HP\Downloads\Central_Superstore.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ','
);
