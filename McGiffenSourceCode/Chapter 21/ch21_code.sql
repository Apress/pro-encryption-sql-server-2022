--Create test database and DMK
CREATE DATABASE TestColumnEncryption;
GO

USE TestColumnEncryption;
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'SomeLongAndComplicatedPassword!';
GO

--Create certificate
CREATE CERTIFICATE MyColumnEncryptionCert
WITH SUBJECT = 'Certificate used for column encryption in the TestColumnEncryption database';
GO

--Create symmetric key
CREATE SYMMETRIC KEY MySymmetricKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE MyColumnEncryptionCert;
GO

--Create symmetric key, specifying KEY_SOURCE and IDENTITY_VALUE
CREATE SYMMETRIC KEY MySymmetricKey2
WITH ALGORITHM = AES_256,
   KEY_SOURCE = 'Pass phrase to generate the key',
   IDENTITY_VALUE = 'Pass phrase to generate the key GUID'
ENCRYPTION BY CERTIFICATE MyColumnEncryptionCert;
GO

--Open symmetric key
OPEN SYMMETRIC KEY MySymmetricKey
DECRYPTION BY CERTIFICATE MyColumnEncryptionCert;
GO

--Close symmetric key
CLOSE SYMMETRIC KEY MySymmetricKey;
GO

--Encrypting a value
SELECT ENCRYPTBYKEY(KEY_GUID(N'MySymmetricKey'),'SomeText');
GO

--Decrypting a value
SELECT CAST(DECRYPTBYKEY(0x00362256B65B9B4DBDF3705E081C5B4702000000F7777779B3530A9720241C13E2025BB75AF6A6E6EFFA43BFB712E03278BEB14B33E1D3602666A1E03D679B30BBE3419E) AS varchar(50));
GO

--Creating a test table and inserting some data
CREATE TABLE dbo.Salary(
	ID int IDENTITY(1,1) PRIMARY KEY,
	EmployeeName nvarchar(100),
	Salary decimal(12,2),
	EncryptedSalary varbinary(200) NULL
);
GO
INSERT INTO dbo.Salary(EmployeeName, Salary)
VALUES
('Me', 10000),
('CEO', 1000000),
('Geoff', 10000);
GO

--Encrypting values, storing them in the table, and viwing the results
OPEN SYMMETRIC KEY MySymmetricKey
DECRYPTION BY CERTIFICATE MyColumnEncryptionCert;

UPDATE dbo.Salary
SET EncryptedSalary = ENCRYPTBYKEY(KEY_GUID(N'MySymmetricKey'),CAST(Salary AS varchar(20)));

SELECT * FROM dbo.Salary;
GO

--"Hacking" my salary
UPDATE dbo.Salary
SET EncryptedSalary = 0x00362256B65B9B4DBDF3705E081C5B4702000000AA8…
WHERE EmployeeName = 'Me';

SELECT 
	ID, 
	EmployeeName,
	Salary,
	CAST(CAST(DECRYPTBYKEY(EncryptedSalary) AS varchar(20)) AS decimal(12,2)) AS DecryptedSalary
FROM dbo.Salary;
GO

--Using ENCRYPTBYKEY with an authenticator
UPDATE dbo.Salary
SET EncryptedSalary = 
	ENCRYPTBYKEY(
		KEY_GUID(N'MySymmetricKey'),
		CAST(Salary AS varchar(20)),
		1,
CAST(ID AS varchar(20))
		);
GO

--Viewing the results decrypted again
SELECT 
	ID, 
	EmployeeName,
	Salary,
	CAST(CAST(DECRYPTBYKEY(EncryptedSalary,1,CAST(ID AS varchar(20))) AS varchar(20)) AS decimal(12,2)) AS DecryptedSalary
FROM dbo.Salary;
GO

--Create DMK
USE TestColumnEncryption;
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'SomeLongAndComplicatedPassword!';
GO

--Remove protection by the SMK from the DMK
ALTER MASTER KEY
DROP ENCRYPTION BY SERVICE MASTER KEY;
GO

--Opening the symmetric key
OPEN SYMMETRIC KEY MySymmetricKey
DECRYPTION BY CERTIFICATE MyColumnEncryptionCert;
GO

--Open the DMK, and then the symmetric key
OPEN MASTER KEY
DECRYPTION BY PASSWORD = 'SomeLongAndComplicatedPassword!';

OPEN SYMMETRIC KEY MySymmetricKey
DECRYPTION BY CERTIFICATE MyColumnEncryptionCert;
GO

--Create a symmetric key protected by a password
CREATE SYMMETRIC KEY MySymmetricKey_PasswordOnly
WITH ALGORITHM = AES_256,
IDENTITY_VALUE = 'Some Text',
KEY_SOURCE = 'Some More Text'
ENCRYPTION BY PASSWORD = 'OneMoreLongAndComplicatedPassword!'
GO

--Open a symmetirc key protected by a password
OPEN SYMMETRIC KEY MySymmetricKey_PasswordOnly
DECRYPTION BY PASSWORD = 'OneMoreLongAndComplicatedPassword!';
GO

--Searching encrypted columns like this will not work
DECLARE @EncryptedSalary varbinary(200)

OPEN SYMMETRIC KEY MySymmetricKey
DECRYPTION BY CERTIFICATE MyColumnEncryptionCert;

SET @EncryptedSalary = ENCRYPTBYKEY(KEY_GUID(N'MySymmetricKey'),CAST(10000 AS varchar(20)));

SELECT *
FROM dbo.Salary
WHERE EncryptedSalary = @EncryptedSalary;

CLOSE SYMMETRIC KEY MySymmetricKey;
GO

--To search encrypted columns you must use this pattern
DECLARE @EncryptedSalary decimal(12,2) = 10000

OPEN SYMMETRIC KEY MySymmetricKey
DECRYPTION BY CERTIFICATE MyColumnEncryptionCert;

SELECT *
FROM dbo.Salary
WHERE CAST(CAST(DECRYPTBYKEY(EncryptedSalary) AS varchar(20)) AS decimal(12,2)) = @EncryptedSalary;

CLOSE SYMMETRIC KEY MySymmetricKey;
GO

--Open symmetric key
USE TestColumnEncryption;

OPEN SYMMETRIC KEY MySymmetricKey
DECRYPTION BY CERTIFICATE MyColumnEncryptionCert;
GO

--Change protection of DMK in restored database to use current SMK
OPEN MASTER KEY
DECRYPTION BY PASSWORD = 'SomeLongAndComplicatedPassword!';

ALTER MASTER KEY
DROP ENCRYPTION BY SERVICE MASTER KEY;

ALTER MASTER KEY
ADD ENCRYPTION BY SERVICE MASTER KEY;

CLOSE MASTER KEY;
GO

--Create a temporary symmetric key
CREATE SYMMETRIC KEY #MySymmetricKey
WITH ALGORITHM = AES_256,
IDENTITY_VALUE = 'Some Text',
KEY_SOURCE = 'Some More Text'
ENCRYPTION BY CERTIFICATE MyColumnEncryptionCert;
GO

--Working with temporary keys
OPEN SYMMETRIC KEY #MySymmetricKey
DECRYPTION BY CERTIFICATE MyColumnEncryptionCert;

SELECT ENCRYPTBYKEY(KEY_GUID(N'#MySymmetricKey'),'SomeText');

CLOSE SYMMETRIC KEY #MySymmetricKey;
GO

--Removing a temporary key
DROP SYMMETRIC KEY #MySymmetricKey;
GO

--Encryption with a passphrase
DECLARE @EncryptedText varbinary(max);

SET @EncryptedText = ENCRYPTBYPASSPHRASE('My Pass Phrase','Some text to encrypt');
SELECT @EncryptedText AS EncryptedText;

SELECT CAST(DECRYPTBYPASSPHRASE('My Pass Phrase',@EncryptedText) AS varchar(max)) AS DecryptedText;
GO

--Open symmetric key for capturing in a trace
OPEN SYMMETRIC KEY MySymmetricKey_PasswordOnly
DECRYPTION BY PASSWORD = 'OneMoreLongAndComplicatedPassword!';
GO

--Encrypt by passphrase for capturing in a trace
DECLARE @EncryptedText varbinary(max);

SET @EncryptedText = ENCRYPTBYPASSPHRASE('My Pass Phrase','Some text to encrypt');
GO














