# Setting up our virtual NAT
# Create an internal network switch
New-VMSwitch -SwitchName NATswitch -SwitchType Internal

# Retrieve details for the new switch
Get-NetAdapter

# Configure a static IP fo the switch
New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceIndex <ifIndex from last command>

# Configure NAT
New-NetNat -Name NATnetwork -InternalIPInterfaceAddressPrefix 192.168.0.0/24


# Install and configure HGS
# Install HGS Windows feature
Install-WindowsFeature -Name HostGuardianServiceRole -IncludeManagementTools -Restart

# Install HGS server
$adminPassword = ConvertTo-SecureString -AsPlainText '<password>' -Force
Install-HgsServer -HgsDomainName 'bastion.local' -SafeModeAdministratorPassword $adminPassword -Restart

# Initialize HGS attestation
Initialize-HgsAttestation -HgsServiceName 'hgs' -TrustHostKey


# Configure SQL Server for attestation
# Enable HGS
Enable-WindowsOptionalFeature -Online -FeatureName HostGuardian -All

# Create host key and export to file
Set-HgsClientHostKey 
Get-HgsClientHostKey -Path $HOME\Desktop\hostkey.cer

#Register the host key on the HGS VM
Add-HgsAttestationHostKey -Name 192.168.0.3 -Path $HOME\Desktop\hostkey.cer

#On the SQL Server VM set the attestation URL
Set-HgsClientConfiguration -AttestationServerUrl http://192.168.0.2/Attestation -KeyProtectionServerUrl http://192.168.0.2/KeyProtection/ 



