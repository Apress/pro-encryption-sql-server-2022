--Create test database
CREATE DATABASE TestAlwaysEncryptedEnclaves;
GO

--Create test table and data
USE TestAlwaysEncryptedEnclaves;

CREATE TABLE dbo.Person(Id INT IDENTITY(1,1) PRIMARY KEY, LastName nvarchar(50), FirstName nvarchar(50), Age INT NULL);

INSERT INTO dbo.Person (LastName,FirstName)
SELECT LastName.Name, FirstName.Name
FROM
(VALUES ('Smith'),('Jones'),('Taylor'),('Brown'),('Williams'),('Wilson'),('Johnson'),('Davies'),('Patel'),('Robinson')) AS LastName(Name)
CROSS JOIN
(VALUES ('David'),('John'),('Michael'),('Paul'),('Andrew'),('Susan'),('Margaret'),('Sarah'),('Patricia'),('Mary')) AS FirstName(Name);

UPDATE dbo.Person SET Age = (Id*Id) % 100

ALTER TABLE dbo.Person
ALTER COLUMN LastName nvarchar(50) COLLATE Latin1_General_BIN2
ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
WITH
(ONLINE = ON);

ALTER TABLE dbo.Person
ALTER COLUMN FirstName nvarchar(50) COLLATE Latin1_General_BIN2
ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
WITH
(ONLINE = ON);

ALTER TABLE dbo.Person
ALTER COLUMN Age INT
ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
WITH
(ONLINE = ON);
GO

--Performing an equality comparison agains a column using randomized encryption
DECLARE @LastName nvarchar(50) = 'Williams';
SELECT LastName,FirstName
FROM dbo.Person
WHERE LastName = @LastName;
GO

--XEvent capture of the sp_describe_parameter_encryption call
exec sp_describe_parameter_encryption N'DECLARE @LastName AS NVARCHAR (50) = @pf7d20ad250ca47268bf0b34ae2fc4673;    SELECT LastName,         FirstName  FROM   dbo.Person  WHERE  LastName = @LastName;    ',N'@pf7d20ad250ca47268bf0b34ae2fc4673 nvarchar(50)'
GO

--Executing a LIKE comparison
DECLARE @LastName nvarchar(50) = 'Sm%';

SELECT LastName,FirstName
FROM dbo.Person
WHERE LastName LIKE @LastName;
GO

--Executing a range query
DECLARE @LowAge INT = 21;
DECLARE @HighAge INT = 24;

SELECT LastName,FirstName, Age
FROM dbo.Person
WHERE Age BETWEEN @LowAge AND @HighAge;
GO

--Creating an index on a column with randomized encryption
CREATE NONCLUSTERED INDEX IX_LastName 
ON dbo.Person(LastName, FirstName);
GO

--Executing a SELECT that uses the index just created
DECLARE @LastName nvarchar(50) = 'Smith';
SELECT LastName, FirstName
FROM dbo.Person
WHERE LastName = @LastName;
GO

--Viewing the statitics
DBCC SHOW_STATISTICS('dbo.Person','IX_LastName');
GO

--Inserting a new row into our indexed table
DECLARE @LastName nvarchar(50) = 'McGiffen';
DECLARE @FirstName nvarchar(50) = 'Matthew';
DECLARE @Age int = 150;
INSERT INTO dbo.Person(LastName, FirstName, Age)
VALUES (@LastName, @FirstName, @Age);
GO

--Rebuilding the index
ALTER INDEX IX_LastName ON dbo.Person REBUILD;
GO

--Updating a row without committing the transaction
BEGIN TRAN
DECLARE @LastName nvarchar(50) = 'McGiffen';
UPDATE dbo.Person SET LastName = @LastName;

--Trying to view the table after a restart
SELECT *
FROM dbo.Person;
GO

--Running a query that will hydrate the CEK in the enclave
DECLARE @LastName nvarchar(50) = 'Williams';
SELECT LastName,FirstName
FROM dbo.Person
WHERE LastName = @LastName;
GO

--Turning on Accelerated Database Recovery
ALTER DATABASE TestAlwaysEncryptedEnclaves 
SET ACCELERATED_DATABASE_RECOVERY = ON;
GO

--Updating a row without committing the transaction
BEGIN TRAN
DECLARE @LastName nvarchar(50) = 'McGiffen';
UPDATE dbo.Person SET LastName = @LastName;

--Trying to view the table after a restart
SELECT *
FROM dbo.Person;
GO

--Create additional tables and data for testing joins
--Create a second encrypted table
CREATE TABLE dbo.PersonSalary(Id INT IDENTITY(1,1) PRIMARY KEY, LastName nvarchar(50), FirstName nvarchar(50), Salary DECIMAL(10,2) NULL);

INSERT INTO dbo.PersonSalary (LastName,FirstName)
SELECT LastName.Name, FirstName.Name
FROM
(VALUES ('Smith'),('Jones'),('Taylor'),('Brown'),('Williams'),('Wilson'),('Johnson'),('Davies'),('Patel'),('Robinson')) AS LastName(Name)
CROSS JOIN
(VALUES ('David'),('John'),('Michael'),('Paul'),('Andrew'),('Susan'),('Margaret'),('Sarah'),('Patricia'),('Mary')) AS FirstName(Name);

UPDATE dbo.PersonSalary SET Salary = 100000 - (Id*Id*7)
GO

ALTER TABLE dbo.PersonSalary
ALTER COLUMN LastName nvarchar(50) COLLATE Latin1_General_BIN2
ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
WITH
(ONLINE = ON);

ALTER TABLE dbo.PersonSalary
ALTER COLUMN FirstName nvarchar(50) COLLATE Latin1_General_BIN2
ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
WITH
(ONLINE = ON);

ALTER TABLE dbo.PersonSalary
ALTER COLUMN Salary DECIMAL(10,2)
ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [TestCEK], ENCRYPTION_TYPE = Randomized, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
WITH
(ONLINE = ON);

CREATE INDEX IX_LastName 
ON dbo.PersonSalary(LastName, FirstName);

--Create unencrypted versions of our tables
CREATE TABLE dbo.Person_Unencrypted(Id INT IDENTITY(1,1) PRIMARY KEY, LastName nvarchar(50), FirstName nvarchar(50), Age INT NULL);

INSERT INTO dbo.Person_Unencrypted (LastName,FirstName)
SELECT LastName.Name, FirstName.Name
FROM
(VALUES ('Smith'),('Jones'),('Taylor'),('Brown'),('Williams'),('Wilson'),('Johnson'),('Davies'),('Patel'),('Robinson')) AS LastName(Name)
CROSS JOIN
(VALUES ('David'),('John'),('Michael'),('Paul'),('Andrew'),('Susan'),('Margaret'),('Sarah'),('Patricia'),('Mary')) AS FirstName(Name);

UPDATE dbo.Person_Unencrypted SET Age = (Id*Id) % 100;

CREATE INDEX IX_LastName 
ON dbo.Person_Unencrypted(LastName, FirstName);

CREATE TABLE dbo.PersonSalary_Unencrypted(Id INT IDENTITY(1,1) PRIMARY KEY, LastName nvarchar(50), FirstName nvarchar(50), Salary DECIMAL(10,2) NULL);

INSERT INTO dbo.PersonSalary_Unencrypted (LastName,FirstName)
SELECT LastName.Name, FirstName.Name
FROM
(VALUES ('Smith'),('Jones'),('Taylor'),('Brown'),('Williams'),('Wilson'),('Johnson'),('Davies'),('Patel'),('Robinson')) AS LastName(Name)
CROSS JOIN
(VALUES ('David'),('John'),('Michael'),('Paul'),('Andrew'),('Susan'),('Margaret'),('Sarah'),('Patricia'),('Mary')) AS FirstName(Name);

UPDATE dbo.PersonSalary_Unencrypted SET Salary = 100000 - (Id*Id*7);

CREATE INDEX IX_LastName 
ON dbo.PersonSalary_Unencrypted(LastName, FirstName);
GO

--Executing a query joining on encrypted columns
SELECT p.LastName, p.FirstName, p.Age, ps.Salary
FROM dbo.Person p
INNER JOIN dbo.PersonSalary ps
	ON p.LastName = ps.LastName
   AND p.FirstName = ps.FirstName;
GO

--Executing the same query against our unencrypted tables
SELECT p.LastName, p.FirstName, p.Age, ps.Salary
FROM dbo.Person_Unencrypted p
INNER JOIN dbo.PersonSalary_Unencrypted ps
	ON p.LastName = ps.LastName
   AND p.FirstName = ps.FirstName;
GO

--Capturing execution statistics
SET STATISTICS IO, TIME ON;
GO

--Attempting to force a hash match join
SELECT p.LastName, p.FirstName, p.Age, ps.Salary
FROM dbo.Person p
INNER HASH JOIN dbo.PersonSalary ps
	ON p.LastName = ps.LastName
   AND p.FirstName = ps.FirstName;
GO

























