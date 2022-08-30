--Configure SQL Server to use enclaves
EXEC sys.sp_configure 'column encryption enclave type', 1;
RECONFIGURE;
GO

--Check SQL Server is configured to use enclaves
SELECT [name], [value], [value_in_use] FROM sys.configurations
WHERE [name] = 'column encryption enclave type';
GO