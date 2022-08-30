--Create test database and insert some data
CREATE DATABASE TestTDE; 
GO     
USE TestTDE;
GO 
CREATE TABLE dbo.SomeData
(Id INT IDENTITY(1,1), SomeText VARCHAR(255)); 
GO
INSERT INTO dbo.SomeData (SomeText) VALUES('This is my data');
GO

--Detaching a database
USE master;
GO
EXEC master.dbo.sp_detach_db @dbname = N'TestTDE';

--Example of backing up a certificate
USE master;
GO
BACKUP CERTIFICATE MyTDECert   
   TO FILE = 'C:\Test\MyTDECert.cer'   
WITH PRIVATE KEY(       
   FILE = 'C:\Test\MyTDECert_PrivateKeyFile.pvk',       		
   ENCRYPTION BY PASSWORD = 'C0rrecth0rserbatterystab1e'   
);


--Example of restoring a certificate
USE master;
GO
CREATE CERTIFICATE MyTDECert   
FROM FILE = 'C:\Test\MyTDECert.cer'   
WITH PRIVATE KEY(       
   FILE = 'C:\Test\MyTDECert_PrivateKeyFile.pvk',       		
   DECRYPTION BY PASSWORD = 'C0rrecth0rserbatterystab1e'
);
