--Create table and populate with test data
USE TestAlwaysEncrypted;

CREATE TABLE dbo.EncryptingExistingData (
Id INT IDENTITY(1,1) CONSTRAINT PK_EncryptingExistingData PRIMARY KEY CLUSTERED,
NumericData INT,
TextData nvarchar(128)
);

INSERT INTO dbo.EncryptingExistingData (NumericData,TextData)
SELECT object_id, name
FROM sys.objects;
GO

--Table definition after performing the encryption
CREATE TABLE [dbo].[EncryptingExistingData](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NumericData] [int] ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Deterministic, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NULL,
	[TextData] [nvarchar](128) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NULL,
 CONSTRAINT [PK_EncryptingExistingData] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

--Viewing our encrypted data
USE TestAlwaysEncrypted;

SELECT *
FROM dbo.EncryptingExistingData;
GO

--Drop and re-create our test table
USE TestAlwaysEncrypted;
DROP TABLE dbo.EncryptingExistingData;
GO

CREATE TABLE dbo.EncryptingExistingData (
Id INT IDENTITY(1,1) CONSTRAINT PK_EncryptingExistingData PRIMARY KEY CLUSTERED,
NumericData INT,
TextData nvarchar(128)
);

INSERT INTO dbo.EncryptingExistingData (NumericData,TextData)
SELECT object_id, name
FROM sys.objects;
GO

--Create an empty copy of the table with encryption enabled
CREATE TABLE dbo.EncryptingExistingData_Encrypted(
	Id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_EncryptingExistingData_Encrypted PRIMARY KEY CLUSTERED,
	NumericData int ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = TestCEK, ENCRYPTION_TYPE = Deterministic, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NULL,
	TextData nvarchar(128) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = TestCEK, ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NULL
);
GO

--Viewing encrypted data in our new table
USE TestAlwaysEncrypted;

SELECT *
FROM dbo.EncryptingExistingData_Encrypted; 
GO





