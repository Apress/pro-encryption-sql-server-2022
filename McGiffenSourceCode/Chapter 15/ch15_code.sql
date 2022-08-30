--Create test database
CREATE DATABASE TestAlwaysEncryptedEnclaves;
GO

--Definition for my key (example only)
CREATE COLUMN MASTER KEY [TestCMK]
WITH
(
	KEY_STORE_PROVIDER_NAME = N'MSSQL_CERTIFICATE_STORE',
	KEY_PATH = N'CurrentUser/My/656D77A58A13424E2F84C0300968A7E9095FA544',
	ENCLAVE_COMPUTATIONS (SIGNATURE = 0x1D9CDD485F3FCA67E99D5AF2E18ACDB6...
)
GO

--Create table and a row of test data
USE TestAlwaysEncryptedEnclaves;
CREATE TABLE dbo.SomeData(Id INT IDENTITY(1,1), SomeText VARCHAR(255));

INSERT INTO dbo.SomeData (SomeText) 
VALUES ('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
GO

--Perform in-place encryption against the table
USE TestAlwaysEncryptedEnclaves;

ALTER TABLE dbo.SomeData
ALTER COLUMN SomeText varchar(255) COLLATE Latin1_General_BIN2
ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
WITH
(ONLINE = ON);
GO

--Viewing my new table definition
CREATE TABLE [dbo].[SomeData](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SomeText] [varchar](255) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
) ON [PRIMARY]
GO

--Showing that data is now encrypted
USE TestAlwaysEncryptedEnclaves;

SELECT * FROM dbo.SomeData;
GO

--Removing encryption from the column
ALTER TABLE dbo.SomeData
ALTER COLUMN SomeText varchar(255) COLLATE Latin1_General_BIN2;
GO

--Bulk loading our table to test performance
INSERT INTO dbo.SomeData (SomeText) 
SELECT TOP 1000000
('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
FROM sys.objects a
CROSS JOIN sys.objects b
CROSS JOIN sys.objects c
CROSS JOIN sys.objects d;
GO 10

--Encrypt the column again to see performance
ALTER TABLE dbo.SomeData
ALTER COLUMN SomeText varchar(255) COLLATE Latin1_General_BIN2
ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
WITH
(ONLINE = ON);
GO

--Looking at performance of decryption
ALTER TABLE dbo.SomeData
ALTER COLUMN SomeText varchar(255) COLLATE Latin1_General_BIN2;
GO

--Encrypting the data again before we look at CEK rotation
ALTER TABLE dbo.SomeData
ALTER COLUMN SomeText varchar(255) COLLATE Latin1_General_BIN2
ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
WITH
(ONLINE = ON);
GO

--Rotating to use a new CEK
ALTER TABLE dbo.SomeData
ALTER COLUMN SomeText varchar(255) COLLATE Latin1_General_BIN2
ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK2], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
WITH
(ONLINE = ON);
GO












