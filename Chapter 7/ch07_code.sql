--Create test database
CREATE DATABASE TestAlwaysEncrypted;
GO

--Creating a CMK (example only - your thumbprint will be different)
CREATE COLUMN MASTER KEY [TestCMK]
WITH
(
	KEY_STORE_PROVIDER_NAME = N'MSSQL_CERTIFICATE_STORE',
	KEY_PATH = N'CurrentUser/My/CE751A6A9CB3732508D6A7E8368E5B3770CF7328'
);
GO

--Creating a CEK (example only - your encrypted value will be different)
CREATE COLUMN ENCRYPTION KEY [TestCEK]
WITH VALUES
(
	COLUMN_MASTER_KEY = [TestCMK],
	ALGORITHM = 'RSA_OAEP',
	ENCRYPTED_VALUE = 0x016E000001630075007200720065006E00740075007300650072002F006D0079002F006300650037003500310061003600610039006300620033003700330032003500300038006400360061003700650038003300360038006500350062003300370037003000630066003700330032003800B2B50941CCCC53C3EFAE2FC455437B95223B879B228D74836F55C50E375186A8E29FEE2CE4AAA9AA95F05EA30F1527CB0E6431DD2F925B8D23EDA25C3F1B480736287A7745DD169761778241D9BB4474F7802734050C5F8D22A424BFC9B48823F409D3F94808E4FCDB745EB85AC39A96803F5561A91BEAFE4094BB34AA74C7CD0F78F95B786F3B5C8793FD9132FED72E52193E59BA3652C8CC077F7DC47D49D36E2995A1A0A3727910E22B091F44F36241E13C2D2EAD12F29BB6C162928E6136C87A7ED4B63104C6549F00FA5064DE4C7604122C9817836A9C8994CFF4054E92DF6E436DCA2E3B897289ECEAB3624FAFA28A99D39B3C6D31AB323ECB51AAEF7C2CC604F6B260C048F8DBA4773D7B44D5E6BEE31AD540D3C4A4BCCBB4B192C6CC9280138B8D75251572239C5B32F19F9FFD5028CF91D7A0E2F41FD9DE4DAD85BCB4FF0BE903868E4036EC495FFB328CA1D1D5BF2F39DF227156E5D619363C079BB87FCEF3D709B5C4EAE6EA017473AD2BD26101410D38864791A6A1D94B0F6F801C12A050069210E3CE9A412F9D0EE775959A6856C84DB504CCE5CCFCCE5515FCFC2DE60D23140F5941F3D9A9E5B7560E452129593C077AACDD2AFD09B885A0198DB13838BFA156B83E7D2855FB8B4950F812C14B1AF5078E762D5E4E488C43624CFC711174E9916E076AFEE816FABED6E97C299CCE87292F226CF0518EC69F13
);
GO

--Create Test Table
USE TestAlwaysEncrypted;
CREATE TABLE dbo.EncryptedTable(
Id INT IDENTITY(1,1) CONSTRAINT PK_EncryptedTable PRIMARY KEY CLUSTERED,
LastName nvarchar(50) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (
COLUMN_ENCRYPTION_KEY = TestCEK,
ENCRYPTION_TYPE = DETERMINISTIC,
ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
) NULL,
FirstName nvarchar(50) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (
COLUMN_ENCRYPTION_KEY = TestCEK,
ENCRYPTION_TYPE = RANDOMIZED,
ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NULL
);  
GO

