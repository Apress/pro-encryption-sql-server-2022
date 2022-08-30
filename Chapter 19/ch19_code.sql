--Looking at the output from the HASHBYTES function
SELECT HASHBYTES ('SHA2_512','Password');
GO

--Making a small change to our input value
SELECT HASHBYTES ('SHA2_512','Password1');
GO

--Creating a table for our demos
USE Test;
CREATE TABLE dbo.Users (
	Id int IDENTITY(1,1),
	UserName varchar(50),
	Salt varbinary(16),
	HashedPassword varbinary(64)
);
GO

--Store New User and Password
DECLARE @UserName varchar(50) = 'matt.mcgiffen';
DECLARE @PassWord varchar(50) = 'SomePassword';
DECLARE @Salt varbinary(16);
DECLARE @HashedAndSaltedPassword varbinary(64);

SET @Salt = CRYPT_GEN_RANDOM(16);

SET @HashedAndSaltedPassword = HASHBYTES('SHA2_512', @Salt + CAST(@Password AS varbinary(50)));

INSERT INTO dbo.Users (UserName, Salt, HashedPassword)
VALUES (@UserName, @Salt, @HashedAndSaltedPassword);
GO

--Verify User's Password
DECLARE @UserName varchar(50) = 'matt.mcgiffen';
DECLARE @PassWord varchar(50) = 'SomePassword';
DECLARE @Salt varbinary(16);
DECLARE @HashedAndSaltedPassword varbinary(64);

SELECT 
	@Salt = Salt,
	@HashedAndSaltedPassword = HashedPassword
FROM dbo.Users
WHERE UserName = @UserName;

IF HASHBYTES('SHA2_512', @Salt + CAST(@Password AS varbinary(50))) = @HashedAndSaltedPassword
BEGIN
	PRINT 'Password is correct'
END
ELSE BEGIN
	PRINT 'Password is incorrect'
END;
GO




