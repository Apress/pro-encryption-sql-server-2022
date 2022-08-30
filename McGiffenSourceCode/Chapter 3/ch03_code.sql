--Creating the Database Master Key (DMK
USE master;
GO
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'UseAStrongPasswordHere!£$7';
GO

--Backing up the DMK
BACKUP MASTER KEY TO FILE = 'C:\Test\MyDMK'   
ENCRYPTION BY PASSWORD = 'UseAnotherStrongPasswordHere!£$7';
GO

--Creating the Certificate
USE master;     
GO
CREATE CERTIFICATE MyTDECert 
WITH SUBJECT = 'Certificate used for TDE in the TestTDE database';
GO

--Backing up the Certificate
USE master;     
GO
BACKUP CERTIFICATE MyTDECert   
TO FILE = 'C:\Test\MyTDECert.cer'  
WITH PRIVATE KEY   
(  
    FILE = 'C:\Test\MyTDECert_PrivateKeyFile.pvk',  
    ENCRYPTION BY PASSWORD = 'UseAStrongPasswordHereToo!£$7'  
);
GO

--Create Test Database
CREATE DATABASE TestTDE;
GO

--Create DEK
USE TestTDE;     
GO
CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE MyTDECert;
GO

--Turn on encryption for database
ALTER DATABASE TestTDE SET ENCRYPTION ON;
GO

--Viewing list of encrypted databases
SELECT name
FROM sys.databases
WHERE is_encrypted = 1;
GO

--Viewing more details about TDE configuarion
SELECT
   d.name,
   k.encryption_state,
   k.encryptor_type,
   k.key_algorithm,
   k.key_length,
   k.percent_complete
FROM sys.dm_database_encryption_keys k
INNER JOIN sys.databases d
   ON k.database_id = d.database_id;
GO

--Turning encryption off again
ALTER DATABASE TestTDE SET ENCRYPTION OFF;
GO

--Bulk loading our TestTDE database
USE TestTDE;
CREATE TABLE dbo.SomeData(Id INT IDENTITY(1,1), SomeText VARCHAR(255));
GO

INSERT INTO dbo.SomeData (SomeText) 
SELECT TOP 1000000 
('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
FROM sys.objects a
CROSS JOIN sys.objects b
CROSS JOIN sys.objects c
CROSS JOIN sys.objects d;
GO 100

--Turning encryption back on agaian
ALTER DATABASE TestTDE SET ENCRYPTION ON;
GO

--Polling to monitor the progress of encryption
DECLARE @state tinyint;
DECLARE @encyrption_progress 
    TABLE(sample_time DATETIME, percent_complete DECIMAL(5,2))

SELECT @state = k.encryption_state
FROM sys.dm_database_encryption_keys k
INNER JOIN sys.databases d
   ON k.database_id = d.database_id
WHERE d.name = 'TestTDE';

WHILE @state != 3
BEGIN
   INSERT INTO @encyrption_progress(sample_time, percent_complete)
   SELECT GETDATE(), percent_complete
   FROM sys.dm_database_encryption_keys k
   INNER JOIN sys.databases d
      ON k.database_id = d.database_id
   WHERE d.name = 'TestTDE';


   WAITFOR delay '00:00:05';

   SELECT @state = k.encryption_state
   FROM sys.dm_database_encryption_keys k
   INNER JOIN sys.databases d
      ON k.database_id = d.database_id
   WHERE d.name = 'TestTDE'; 
END

SELECT * FROM @encyrption_progress;
GO

--Checking for blocking caused by encryption
SELECT *
FROM sys.dm_tran_locks
WHERE resource_type = 'ENCRYPTION_SCAN';
GO

--Pausing the encryption scan for all databases using the trace flag
DBCC TRACEON(5004);
GO

--Suspending the encryption scan for a database using ALTER DATABASE 
ALTER DATABASE TestTDE SET ENCRYPTION SUSPEND;
GO

--Resuming the encryption scan for a database using ALTER DATABASE 
ALTER DATABASE TestTDE SET ENCRYPTION RESUME;
GO
