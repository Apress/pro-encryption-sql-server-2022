--Backing up the certificate and private key
BACKUP CERTIFICATE MyTDECert   
TO FILE = 'C:\Test\MyTDECert.cer'  
WITH PRIVATE KEY   
(  
    FILE = 'C:\Test\MyTDECert_PrivateKeyFile.pvk',  
    ENCRYPTION BY PASSWORD = 'UseAStrongPasswordHereToo!£$7'  
);  
GO

--Ceating the DMK
USE master;
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'UseAStrongPasswordHere!£$7';
GO

--Restoring the certificate and private key
USE master;
CREATE CERTIFICATE MyTDECert
FROM FILE = 'C:\Test\MyTDECert.cer'
WITH PRIVATE KEY 
( 
   FILE = 'C:\Test\MyTDECert_PrivateKeyFile.pvk',
   DECRYPTION BY PASSWORD = 'UseAStrongPasswordHereToo!£$7' 
);
GO

--Restoring a TDE protected database
RESTORE DATABASE TestTDE FROM DISK = 'C:\Test\TestTDE.bak';
GO

--Viewing the expiry date for a certificate
USE master;
SELECT name, subject, expiry_date
FROM sys.certificates
WHERE name = 'MyTDECert';
GO

--Creating a new certificate and specifying the expiry date
USE master;
CREATE CERTIFICATE MyTDECert_with_longevity
WITH SUBJECT = 'Certificate used for TDE in the TestTDE database for years to come',
EXPIRY_DATE = '20251231';
GO

--Rotating the certificate
USE TestTDE;
ALTER DATABASE ENCRYPTION KEY
ENCRYPTION BY SERVER CERTIFICATE MyTDECert_with_longevity;
GO

--Performance test query
DBCC DROPCLEANBUFFERS;
SET STATISTICS IO, TIME ON;
SELECT *
FROM dbo.SomeData 
WHERE Id = 100000000;

SELECT *
FROM dbo.SomeData 
WHERE Id = 100000000;
GO

--Backup database with compression
BACKUP DATABASE TestTDE TO DISK = 'C:\Test\TestTDE_Compressed.bak' WITH COMPRESSION;
GO

--Backup database with compression while specifying MAXTRANSFERSIZE
BACKUP DATABASE TestTDE TO DISK = 'C:\Test\TestTDE_Compressed.bak' 
WITH COMPRESSION, MAXTRANSFERSIZE = 131072;
GO

