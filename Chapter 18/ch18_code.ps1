# Create a self-signed certificate to use for TLS
New-SelfSignedCertificate -Type SSLServerAuthentication `
    -Subject "CN=matthewmcgiffen.com" -FriendlyName 'matthewmcgiffen.com' `
    -DnsName "matthewmcgiffen.com",'localhost.' `
    -KeyAlgorithm 'RSA' -KeyLength 2048 -Hash 'SHA256' `
    -TextExtension '2.5.29.37={text}1.3.6.1.5.5.7.3.1' `
    -NotAfter (Get-Date).AddMonths(36) `
    -KeyExportPolicy Exportable -KeySpec KeyExchange `
    -Provider 'Microsoft RSA SChannel Cryptographic Provider' `
    -CertStoreLocation Cert:\LocalMachine\My `
| fl -Property Thumbprint,FriendlyName,DnsNameList,NotAfter,PrivateKey,SerialNumber,Subject,Issuer 
