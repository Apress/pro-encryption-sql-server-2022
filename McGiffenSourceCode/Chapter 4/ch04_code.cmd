sqlservr.exe -c -m -s {InstanceName}

sqlcmd -s {InstanceName}

RESTORE DATABASE master FROM DISK = ‘C:\Test\master.bak’ WITH REPLACE;
GO
