--An insert pattern that fails
INSERT INTO dbo.EncryptedTable (LastName, FirstName)
VALUES ('McGiffen', 'Matthew');
GO

--The correct way to insert data
DECLARE @LastName nvarchar(50) = 'McGiffen';
DECLARE @FirstName nvarchar(50) = 'Matthew';

INSERT INTO dbo.EncryptedTable (LastName, FirstName)
VALUES (@LastName, @FirstName);
GO

--Another pattern that fails - implicit conversions are not allowed
DECLARE @LastName nvarchar(100) = 'McGiffen';
DECLARE @FirstName nvarchar(100) = 'Matthew';

INSERT INTO dbo.EncryptedTable (LastName, FirstName)
VALUES (@LastName, @FirstName);
GO

--Reading data with a simple select query
SELECT *
FROM dbo.EncryptedTable;
GO

--Running the insert again to capture the execution with an XEvent trace
DECLARE @LastName nvarchar(50) = 'McGiffen';
DECLARE @FirstName nvarchar(50) = 'Matthew';

INSERT INTO dbo.EncryptedTable (LastName, FirstName)
VALUES (@LastName, @FirstName);
GO

--The call that requests the encryption metadata for the query
exec sp_describe_parameter_encryption N'DECLARE @LastName AS NVARCHAR (50) = @pacc87acf4618488b80bc61f6ac68114f;

DECLARE @FirstName AS NVARCHAR (50) = @p4113aa748f2e4ff585556f8eaa618f0d;

INSERT  INTO dbo.EncryptedTable (LastName, FirstName)
VALUES                         (@LastName, @FirstName);

',N'@pacc87acf4618488b80bc61f6ac68114f nvarchar(50),@p4113aa748f2e4ff585556f8eaa618f0d nvarchar(50)' 
GO

--The actual query execution captured by the trace - example only, the encrypted values would differ on your system
exec sp_executesql N'DECLARE @LastName AS NVARCHAR (50) = @pacc87acf4618488b80bc61f6ac68114f;

DECLARE @FirstName AS NVARCHAR (50) = @p4113aa748f2e4ff585556f8eaa618f0d;

INSERT  INTO dbo.EncryptedTable (LastName, FirstName)
VALUES                         (@LastName, @FirstName);

',N'@pacc87acf4618488b80bc61f6ac68114f nvarchar(50),@p4113aa748f2e4ff585556f8eaa618f0d nvarchar(50)',@pacc87acf4618488b80bc61f6ac68114f=0x01F82323F52B604A838ABC880ECDEB6CDD26ED47813F507A2EAA78FA1EE10FF47B2ED7C73C1A76580B6C0753A95DF5C944C5E590C2ED7E0AF59F1B4054317018584A9B8E3B4B0D9C4341B32DE2990E22C1,@p4113aa748f2e4ff585556f8eaa618f0d=0x012AC8899AACB8F1DDCEF4F6B2EB090F5E56687FDBB67D237E0E3D6D91C7F96C29F39396C633FB27DD92C7F2FABC18600D154FE1D426000CDB401ECD8BFD04AAC3;
GO

--Running the select again to capture with our trace
SELECT *
FROM dbo.EncryptedTable;
GO

--Issuing a query with a predicate - this way doesn't work
SELECT *
FROM dbo.EncryptedTable
WHERE LastName = 'McGiffen';
GO

--The correct way to issue a query with a predicate against an encrypted column
DECLARE @LastName nvarchar(50) = 'McGiffen';

SELECT *
FROM dbo.EncryptedTable
WHERE LastName = @Lastname; 
GO

--The same pattern fails if you attempt it against a column using randomized encryption
DECLARE @FirstName nvarchar(50) = 'Matthew';

SELECT *
FROM dbo.EncryptedTable
WHERE FirstName = @FirstName;
GO

--Comparisons are case sensitive so this returns no results
DECLARE @Lastname nvarchar(50) = 'MCGIFFEN';

SELECT *
FROM dbo.EncryptedTable
WHERE LastName = @Lastname;
GO

--Creating an index on our column with deterministic encryption
CREATE NONCLUSTERED INDEX IX_LastName 
ON dbo.EncryptedTable(LastName);
GO

--Including columns that use randomized encryption
CREATE NONCLUSTERED INDEX IX_LastName_Include_FirstName
ON dbo.EncryptedTable(LastName) INCLUDE(FirstName);
GO

--Viewing the the statistics for an index
DBCC SHOW_STATISTICS('dbo.EncryptedTable','IX_LastName');
GO

--Working with stored procedures
CREATE PROCEDURE dbo.EncryptedTable_Insert
	@LastName nvarchar(50),
	@FirstName nvarchar(50)
AS
BEGIN
	INSERT INTO dbo.EncryptedTable (LastName, FirstName)
	VALUES (@LastName, @FirstName);
END
GO

CREATE PROCEDURE dbo.EncryptedTable_Update
	@Id int,
	@LastName nvarchar(50),
	@FirstName nvarchar(50)
AS
BEGIN
	UPDATE dbo.EncryptedTable 
	SET
		LastName = @LastName, 
		FirstName =  @FirstName
	WHERE Id = @Id;
END
GO

CREATE PROCEDURE dbo.EncryptedTable_SelectBy_LastName
	@LastName nvarchar(50)
AS
BEGIN
	SELECT Id, LastName, FirstName
	FROM dbo.EncryptedTable 
	WHERE LastName = @LastName;
END
GO

--This query pattern will not work with a stored procedure targeting encrypted columns
EXEC dbo.EncryptedTable_Insert
	@LastName= 'Smith',
	@FirstName = 'John';
GO

--The correct way to execute a stored procedure targeting encrypted columns
DECLARE	@LastName nvarchar(50) = 'John';
DECLARE	@FirstName nvarchar(50) = 'Smith';

EXEC dbo.EncryptedTable_Insert
	@LastName= @LastName,
	@FirstName = @FirstName;
GO

--Executing the update procedure
DECLARE @Id int = 1
DECLARE	@NewLastName nvarchar(50) = 'McGiffen';
DECLARE	@NewFirstName nvarchar(50) = 'Matt';

EXEC dbo.EncryptedTable_Update
	@Id = @Id,
	@LastName= @NewLastName,
	@FirstName = @NewFirstName;
GO

--Executing the search stored procedure
DECLARE	@LastName nvarchar(50) = 'McGiffen';

EXEC dbo.EncryptedTable_SelectBy_LastName
	@LastName= @LastName;
GO


