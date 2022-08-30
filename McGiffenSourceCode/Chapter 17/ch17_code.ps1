# Configure HGS to use TPM mode
Set-HgsServer -TrustTpm

# Enable the HGS Windows feature on the SQL Box
Enable-WindowsOptionalFeature -Online -FeatureName HostGuardian -All

# Lowering VBS requirements through the registry
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard -Name RequirePlatformSecurityFeatures -Value 0

# Configuring the attestation URL
Set-HgsClientConfiguration -AttestationServerUrl "https://MyHGSCluster/Attestation" -KeyProtectionServerUrl http://localhost

# Create code integrity policy
$tempolicyfile = "C:\Temp\AllowAll_Temp.xml"
Copy-Item -Path "$env:SystemRoot\schemas\CodeIntegrity\ExamplePolicies\AllowAll.xml" -Destination $tempolicyfile
Set-RuleOption -FilePath $tempolicyfile -Option 0 -Delete
Set-RuleOption -FilePath $tempolicyfile -Option 3

ConvertFrom-CIPolicy -XmlFilePath $tempolicyfile -BinaryFilePath "C:\Temp\MyCIPolicy.bin" 

# Collect required attestation artifacts
# Collect the Endorsement Key certificate and public key
$ComputerName = $env:computername
$OutputPath = "C:\Temp"
(Get-PlatformIdentifier -Name $ComputerName).Save("$OutputPath\$ComputerName-EK.xml")

# Collect the TPM baseline
Get-HgsAttestationBaselinePolicy -Path "$OutputPath\$ComputerName.tcglog" -SkipValidation

# Collects the applied code integrity policy
Copy-Item -Path "$env:SystemRoot\System32\CodeIntegrity\SIPolicy.p7b" -Destination "$OutputPath\$ComputerName-CIpolicy.bin" 

# Register the attestation artifacts with HGS
# Register the unique TPM Endorsement Key
Add-HgsAttestationTpmHost -Path "C:\Temp\MySQLServer-EK.xml"

# Register the TPM baseline
Add-HgsAttestationTpmPolicy -Name "MySQLServerHardwareAndSoftwareConfig" -Path "C:\Temp\MySQLServer.tcglog"

# Register the code integrity policy
Add-HgsAttestationCiPolicy -Name "AllowAll" -Path "C:\Temp\MySQLServer-CIpolicy.bin" 

# Disable IOMMU policy
Disable-HgsAttestationPolicy Hgs_IommuEnabled

# Check SQL Server can attest successfully
Get-HgsClientConfiguration

