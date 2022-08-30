--Create our test database for backup encryption
CREATE DATABASE TestBackupEncryption;
GO

USE TestBackupEncryption;
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

--Create the DMK
USE master;
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'UseAStrongPasswordHere!£$7';
GO

--Backup the DMK
BACKUP MASTER KEY TO FILE = 'C:\Test\MyDMK'   
ENCRYPTION BY PASSWORD = 'UseAnotherStrongPasswordHere!£$7';
GO

--Create the certificate
USE master;
CREATE CERTIFICATE BackupEncryptionCert 
WITH SUBJECT = 'Certificate used for backup encryption';
GO

--Backup the certificate
BACKUP CERTIFICATE BackupEncryptionCert
TO FILE = 'C:\Test\BackupEncryptionCert.cer'
WITH PRIVATE KEY   
(  
    FILE = 'C:\Test\BackupEncryptionCert_PrivateKeyFile.pvk',  
    ENCRYPTION BY PASSWORD = 'UseAStrongPasswordHereToo!£$7'  
);
GO

--Granting permission to the certificate to a backup account
USE master;
GRANT VIEW DEFINITION ON CERTIFICATE::BackupEncryptionCert 
TO [MyBackupAccount];
GO

--Taking an encrypted backup
BACKUP DATABASE TestBackupEncryption
TO DISK = 'C:\Test\TestBackupEncryption_Encrypted.bak'
WITH ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = BackupEncryptionCert);
GO

--Restoring the backup header
RESTORE HEADERONLY 
FROM DISK = 'C:\Test\TestBackupEncryption_Encrypted.bak';
GO

--Restoring the certificate backup to a diferent server
USE master;
CREATE CERTIFICATE BackupEncryptionCert
FROM FILE = 'C:\Test\BackupEncryptionCert.cer'
WITH PRIVATE KEY 
( 
   FILE = 'C:\Test\BackupEncryptionCert_PrivateKeyFile.pvk',
   DECRYPTION BY PASSWORD = 'UseAStrongPasswordHereToo!£$7' 
);
GO

--Restoring an encrypted backup
RESTORE DATABASE  TestBackupEncryption
FROM DISK = 'C:\Test\TestBackupEncryption_Encrypted.bak';
GO

--Performance testing encrypted backups
BACKUP DATABASE TestBackupEncryption
TO DISK = 'C:\Test\TestBackupEncryption_Unencrypted.bak';

BACKUP DATABASE TestBackupEncryption
TO DISK = 'C:\Test\TestBackupEncryption_Encrypted.bak'
WITH ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = BackupEncryptionCert);
GO

--Performance testing encrypted restores
DROP DATABASE TestBackupEncryption;
GO

RESTORE DATABASE TestBackupEncryption
FROM DISK = 'C:\Test\TestBackupEncryption_Unencrypted.bak';

DROP DATABASE TestBackupEncryption;
GO

RESTORE DATABASE TestBackupEncryption
FROM DISK = 'C:\Test\TestBackupEncryption_Encrypted.bak';
GO

--Combining compression and encryption
BACKUP DATABASE TestBackupEncryption
TO DISK = 'C:\Test\TestBackupEncryption_EncryptedAndCompressed.bak'
WITH ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = BackupEncryptionCert), 
COMPRESSION;
GO

--Taking a compressed but unencrypted backup for size comparison
BACKUP DATABASE TestBackupEncryption
TO DISK = 'C:\Test\TestBackupEncryption_UnencryptedAndCompressed.bak'
WITH COMPRESSION;
GO
