# Key rotation to a new CMK
# Create a new CMK (certificate) in the Current User certificate store
$certificate = New-SelfSignedCertificate -Subject "AlwaysEncryptedCert" -CertStoreLocation Cert:CurrentUser\My -KeyExportPolicy Exportable -Type DocumentEncryptionCert -KeyUsage KeyEncipherment -KeySpec KeyExchange -KeyLength 2048

# Import the SqlServer module
Import-Module "SqlServer"

# Connect to the database
$serverName = ".\MSSQLSERVER01"
$databaseName = "TestAlwaysEncrypted"
$connectionString = "Server = " + $serverName + "; Database = " + $databaseName + "; Integrated Security = True"
$database = Get-SqlDatabase -ConnectionString $connectionString

# Create a settings object for the new CMK
$newCMKSettings = New-SqlCertificateStoreColumnMasterKeySettings -CertificateStoreLocation "CurrentUser" -Thumbprint $certificate.Thumbprint

# Create the CMK object in your database
$newCMKName = "TestCMK3"
New-SqlColumnMasterKey -Name $newCMKName -InputObject $database -ColumnMasterKeySettings $newCMKSettings

# Initialize rotation - Add protection via the new CMK to your CEKs
$oldCMKName = "TestCMK2"
Invoke-SqlColumnMasterKeyRotation -SourceColumnMasterKeyName $oldCMKName -TargetColumnMasterKeyName $newCMKName -InputObject $database

# Complete rotation - Remove protection via the old CMK from your CEKs
Complete-SqlColumnMasterKeyRotation -SourceColumnMasterKeyName $oldCMKName  -InputObject $database

# Remove the old CMK object from your database
Remove-SqlColumnMasterKey -Name $oldCMKName -InputObject $database 




# Rotating the CEK
# Import the SqlServer module.
Import-Module "SqlServer"

# Connect to the database.
$serverName = ".\MSSQLSERVER01"
$databaseName = "TestAlwaysEncrypted"
$connectionString = "Server = " + $serverName + "; Database = " + $databaseName + "; Integrated Security = True"
$database = Get-SqlDatabase -ConnectionString $connectionString

# Generate a new CEK encrypted by the existing CMK
$CMKName = "TestCMK3"
$newCEKName = "TestCEK2"
New-SqlColumnEncryptionKey -Name $newCEKName -InputObject $database -ColumnMasterKey $CMKName 


# Find all columns encrypted with the old column encryption key, then create a SqlColumnEncryptionSetting object for each column.
$columnEncryptionSettingsArray = @()
$oldCEKName = "TestCEK"
$tables = $database.Tables
for($i=0; $i -lt $tables.Count; $i++){
    $columns = $tables[$i].Columns
    for($j=0; $j -lt $columns.Count; $j++) {
        if($columns[$j].isEncrypted -and $columns[$j].ColumnEncryptionKeyName -eq $oldCEKName) {
            $columnName = $tables[$i].Schema + "." + $tables[$i].Name + "." + $columns[$j].Name 
            $columnEncryptionSettingsArray += New-SqlColumnEncryptionSettings -ColumnName $columnName -EncryptionType $columns[$j].EncryptionType -EncryptionKey $newCEKName
        }
     }
}

# Re-encrypt all columns using thew old CEK to use the new one
Set-SqlColumnEncryption -ColumnEncryptionSettings $columnEncryptionSettingsArray -InputObject $database -UseOnlineApproach -MaxDowntimeInSeconds 120 -LogFileDirectory .

# Remove the old CEK from the database
Remove-SqlColumnEncryptionKey -Name $oldCEKName -InputObject $database 
