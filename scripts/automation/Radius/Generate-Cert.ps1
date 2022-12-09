# this script will generate a Self Signed CA (root cert) to be imported on the
# Radius CBA-BYO Authentication UI

# Edit the variables in Config.ps1 before running this script
. "$psscriptRoot/Config.ps1"

if ( ([System.String]::IsNullOrEmpty($JCORGID)) -Or ($JCORGID.Length -ne 24) ) {
    throw "OrganizationID not specified, please update config.ps1"
}

################################################################################
# Do Not Edit Below:
################################################################################
cd $PSSCRIPTROOT
# REM Generate Root Server Private Key and server certificate (self signed as CA)
Write-Host "Generating Self Signed Root CA Certificate"
if (test-path -path "$PSSCRIPTROOT/Cert") {
    write-host "Cert Path Exists"
} else {
    write-host "Createing Cert Path"
    New-Item -ItemType Directory -Path "$PSSCRIPTROOT/Cert"
}
$outKey = "$psscriptroot/Cert/selfsigned-ca-key.pem"
$outCA = "$psscriptroot/Cert/selfsigned-ca-cert.pem"
openssl req -x509 -newkey rsa:2048 -days 365 -keyout $outKey -out $outCA -passout pass:$($JCORGID) -subj "/C=$($Subj.countryCode)/ST=$($Subj.stateCode)/L=$($Subj.Locality)/O=$($Subj.Organization)/OU=$($Subj.OrganizationUnit)/CN=$($Subj.CommonName)"
# REM PEM pass phrase: myorgpass
openssl x509 -in $outCA -noout -text
# openssl x509 -in ca-cert.pem -noout -text
# Update Extensions Distinguished Names:
$exts = Get-ChildItem -Path "$PSSCRIPTROOT/Extensions"
foreach ($ext in $exts) {
    write-host "Updating Subject Headers for $($ext.Name)"
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