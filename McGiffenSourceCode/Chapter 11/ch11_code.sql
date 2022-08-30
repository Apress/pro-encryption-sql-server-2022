--Generate new CMK object to rotate to - you will have a different certificate thumbprint
CREATE COLUMN MASTER KEY [TestCMK2]
WITH
(
	KEY_STORE_PROVIDER_NAME = N'MSSQL_CERTIFICATE_STORE',
	KEY_PATH = N'CurrentUser/My/33371B41FB08953F2FEF249B0913B49BE87F7CD3'
);
GO

--Add protection from the new CMK to your CEK - you will have a different encrypted value
ALTER COLUMN ENCRYPTION KEY [TestCEK]
ADD VALUE
(
	COLUMN_MASTER_KEY = [TestCMK2],
	ALGORITHM = 'RSA_OAEP',
	ENCRYPTED_VALUE = 0x016E000001630075007200...
);
GO

--Remove protection from the old CMK from your CEK
ALTER COLUMN ENCRYPTION KEY [TestCEK]
DROP VALUE
(
	COLUMN_MASTER_KEY = [TestCMK]
)
GO







