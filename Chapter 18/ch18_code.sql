--Identify SPID for your connection
SELECT @@SPID;
GO

--Check encryption status for your connection
SELECT session_id, encrypt_option, connect_time
FROM sys.dm_exec_connections 
WHERE session_id = @@SPID;
GO
