# this script will generate a Self Signed CA (root cert) to be imported on the
# Radius CBA-BYO Authentication UI

# Edit the variables in Config.ps1 before running this script
. "$JCScriptRoot/Config.ps1"

if ( ([System.String]::IsNullOrEmpty($JCORGID)) -Or ($JCORGID.Length -ne 24) ) {
    throw "OrganizationID not specified, please update config.ps1"
}

################################################################################
# Do Not Edit Below:
################################################################################
Set-Location $JCScriptRoot

# REM Generate Root Server Private Key and server certificate (self signed as CA)
Write-Host "Generating Self Signed Root CA Certificate"
if (Test-Path -Path "$JCScriptRoot/Cert") {
    Write-Host "Cert Path Exists"
} else {
    Write-Host "Creating Cert Path"
    New-Item -ItemType Directory -Path "$JCScriptRoot/Cert"
}
# Check if cert exists, prompt user to overwrite with a while loop
if (Test-Path -Path "$JCScriptRoot/Cert/radius_ca_cert.pem") {
    Write-Host "CA Cert already exists"
    $overwrite = Read-Host "Do you want to overwrite the existing CA Cert? (y/n)"
    if ($overwrite -eq "y") {
        Write-Host "Overwriting CA Cert..."
    } else {
        Write-Host "Exiting "
        break
    }
}
$CertPath = Resolve-Path "$JCScriptRoot/Cert"
$outKey = "$CertPath/radius_ca_key.pem"
$outCA = "$CertPath/radius_ca_cert.pem"
# Ask the user to enter a pass phrase for the CA key:
# Clear the pass phrase from the env:
$env:certKeyPassword = ""
$secureCertKeyPass = Read-Host -Prompt "Enter a password for the certificate key" -AsSecureString
$certKeyPass = ConvertFrom-SecureString $secureCertKeyPass -AsPlainText
# Save the pass phrase in the env:
$env:certKeyPassword = $certKeyPass
Invoke-Expression "$opensslBinary req -x509 -newkey rsa:2048 -days 365 -keyout $outKey -out $outCA -passout pass:$($env:certKeyPassword) -subj /C=$($Subj.countryCode)/ST=$($Subj.stateCode)/L=$($Subj.Locality)/O=$($Subj.Organization)/OU=$($Subj.OrganizationUnit)/CN=$($Subj.CommonName)"
# REM PEM pass phrase: myorgpass
Invoke-Expression "$opensslBinary x509 -in $outCA -noout -text"
# openssl x509 -in ca-cert.pem -noout -text
# Update Extensions Distinguished Names:
$exts = Get-ChildItem -Path "$JCScriptRoot/Extensions"
foreach ($ext in $exts) {
    Write-Host "Updating Subject Headers for $($ext.Name)"
    $extContent = Get-Content -Path $ext.FullName -Raw
    $reqDistinguishedName = "[req_distinguished_name]
C = $($subj.countryCode)
ST = $($subj.stateCode)
L = $($subj.Locality)
O = $($subj.Organization)
OU = $($subj.OrganizationUnit)
CN = $($subj.CommonName)

"
    $extContent -Replace ("\[req_distinguished_name\][\s\S]*(?=\[v3_req\])", $reqDistinguishedName) | Set-Content -Path $ext.FullName -NoNewline -Force
}
