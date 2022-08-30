--Code examples for setting up TDE with EKM
--Configure SQL Server to enable EKM and register provider
USE master;
GO
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'EKM provider enabled', 1;
GO
RECONFIGURE;

CREATE CRYPTOGRAPHIC PROVIDER AzureKeyVault_Provider
FROM FILE = 'C:\Program Files\SQL Server Connector for Microsoft Azure Key Vault\Microsoft.AzureKeyVaultService.EKM.dll';
GO

--Create credential
USE master;
CREATE CREDENTIAL AzureKeyVault_Credential    
WITH IDENTITY = 'ProEncryption2022',
SECRET = 'df640d85714042eaa22affc1468d809cu6r8Q~1RzghBt~9InChnPo3kXj_xxtMGuEMH.bxv'
FOR CRYPTOGRAPHIC PROVIDER AzureKeyVault_Provider;
GO

--Add credential to administrator login
ALTER LOGIN [Your Administrator Account]
ADD CREDENTIAL AzureKeyVault_Credential;
GO

--Create asymmetric key object
USE master;
CREATE ASYMMETRIC KEY AzureKeyVault_TestTDEKey
FROM PROVIDER AzureKeyVault_Provider
WITH PROVIDER_KEY_NAME = 'TestTDEKey',
CREATION_DISPOSITION = OPEN_EXISTING;
GO

--Remove credential fom administrator login
ALTER LOGIN [Your Administrator Account]
DROP CREDENTIAL AzureKeyVault_Credential;
GO

--Create a new login from the asymmetric key and add the credential
CREATE LOGIN AzureKeyVault_TestTDEKey_Login
FROM ASYMMETRIC KEY AzureKeyVault_TestTDEKey;

ALTER LOGIN AzureKeyVault_TestTDEKey_Login
ADD CREDENTIAL AzureKeyVault_Credential;
GO

--Create test database
CREATE DATABASE TestEKM;
GO

--Create DEK 
USE TestEKM;
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER ASYMMETRIC KEY [AzureKeyVault_TestTDEKey];
GO

--Turn TDE on
ALTER DATABASE TestEKM SET ENCRYPTION ON;
GO


--Code examples for setting up Always Encrypted with EKM
--Create test database if you didn't already
CREATE DATABASE TestEKM;
GO

--Create a test table 
USE TestEKM;
CREATE TABLE dbo.EncryptedTable(
Id INT IDENTITY(1,1) CONSTRAINT PK_EncryptedTable PRIMARY KEY CLUSTERED,
LastName nvarchar(50) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (
COLUMN_ENCRYPTION_KEY = TestCEK_EKM,
ENCRYPTION_TYPE = DETERMINISTIC,
ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
) NULL,
FirstName nvarchar(50) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (
COLUMN_ENCRYPTION_KEY = TestCEK_EKM,
ENCRYPTION_TYPE = RANDOMIZED,
ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NULL
);
GO

--Insert a row of Test Data
DECLARE @LastName nvarchar(50) = 'McGiffen';
DECLARE @FirstName nvarchar(50) = 'Matthew';

INSERT INTO dbo.EncryptedTable (LastName, FirstName)
VALUES (@LastName, @FirstName);
GO





with a row of test data








