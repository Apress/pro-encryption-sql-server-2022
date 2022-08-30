# Inserting data into encrypted columns
$connectionstring = "Data Source=.\MSSQLSERVER02; Integrated Security=SSPI; Initial Catalog=TestAlwaysEncrypted; Column Encryption Setting=Enabled"
$query = "INSERT INTO dbo.EncryptedTable (LastName, FirstName) VALUES (@LastName, @FirstName);"
$connection = new-object system.data.SqlClient.SQLConnection($connectionString)
$connection.Open()

$command = new-object system.data.sqlclient.sqlcommand($query,$connection)

$LastName = new-object System.Data.SqlClient.SqlParameter
$LastName.ParameterName = "@LastName"
$LastName.SqlDbType = "nvarchar"
$LastName.Size = 50
$LastName.Value = "Jones"

$FirstName = new-object System.Data.SqlClient.SqlParameter
$FirstName.ParameterName = "@FirstName"
$FirstName.SqlDbType = "nvarchar"
$FirstName.Size = 50
$FirstName.Value = "Fred"

$command.Parameters.Add($LastName)
$command.Parameters.Add($FirstName)

$command.ExecuteNonQuery()
$connection.Close()


#Executing a select query against encrypted columns
$connectionstring = "Data Source=.\MSSQLSERVER02; Integrated Security=SSPI; Initial Catalog=TestAlwaysEncrypted; Column Encryption Setting=Enabled"
$query = "SELECT Id, LastName, FirstName FROM dbo.EncryptedTable WHERE LastName = @LastName;"
$connection = new-object system.data.SqlClient.SQLConnection($connectionString)
$connection.Open()

$command = new-object system.data.sqlclient.sqlcommand($query,$connection)

$LastName = new-object System.Data.SqlClient.SqlParameter
$LastName.ParameterName = "@LastName"
$LastName.SqlDbType = "nvarchar"
$LastName.Size = 50
$LastName.Value = "Jones"

$command.Parameters.Add($LastName)

$reader = $command.ExecuteReader()

while($reader.Read())
{
    Write-Host ($reader.GetValue(0), $reader.GetValue(1), $reader.GetValue(2))
}
$reader.Close()
$connection.Close()


#Executing our update stored procedure
$connectionstring = "Data Source=.\MSSQLSERVER02; Integrated Security=SSPI; Initial Catalog=TestAlwaysEncrypted; Column Encryption Setting=Enabled"
$query = "dbo.EncryptedTable_Update"
$connection = new-object system.data.SqlClient.SQLConnection($connectionString)
$connection.Open()

$command = new-object system.data.sqlclient.sqlcommand
$command.CommandType = [System.Data.CommandType]::StoredProcedure
$command.CommandText = $query
$command.Connection = $connection

$Id = new-object System.Data.SqlClient.SqlParameter
$Id.ParameterName = "@Id"
$Id.SqlDbType = "int"
$Id.Value = 4

$LastName = new-object System.Data.SqlClient.SqlParameter
$LastName.ParameterName = "@LastName"
$LastName.SqlDbType = "nvarchar"
$LastName.Size = 50
$LastName.Value = "Jones"

$FirstName = new-object System.Data.SqlClient.SqlParameter
$FirstName.ParameterName = "@FirstName"
$FirstName.SqlDbType = "nvarchar"
$FirstName.Size = 50
$FirstName.Value = "Frederick"

$command.Parameters.Add($Id)
$command.Parameters.Add($LastName)
$command.Parameters.Add($FirstName)

$command.ExecuteNonQuery()
$connection.Close() 


#Executing our select stored procedure to view the data
$connectionstring = "Data Source=.\MSSQLSERVER02; Integrated Security=SSPI; Initial Catalog=TestAlwaysEncrypted; Column Encryption Setting=Enabled"
$query = "dbo.EncryptedTable_SelectBy_LastName"
$connection = new-object system.data.SqlClient.SQLConnection($connectionString)
$connection.Open()

$command = new-object system.data.sqlclient.sqlcommand
$command.CommandType = [System.Data.CommandType]::StoredProcedure
$command.CommandText = $query
$command.Connection = $connection

$LastName = new-object System.Data.SqlClient.SqlParameter
$LastName.ParameterName = "@LastName"
$LastName.SqlDbType = "nvarchar"
$LastName.Size = 50
$LastName.Value = "Jones"

$command.Parameters.Add($LastName)

$reader = $command.ExecuteReader()

while($reader.Read())
{
    Write-Host ($reader.GetValue(0), $reader.GetValue(1), $reader.GetValue(2))
}
$reader.Close()
$connection.Close() 
