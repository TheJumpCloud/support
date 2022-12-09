# this script will generate a Self Signed CA (root cert) to be imported on the
# Radius CBA-BYO Authentication UI

# Enter the Org Name that will act as the CA
$orgID = "yourOrgID"

################################################################################
# Do Not Edit Below:
################################################################################
write-host "running in $PSSCRIPTROOT"
cd $PSSCRIPTROOT
# ::REM Generate Root Server Private Key and server certificate (self signed as CA)
Echo "Generating Self Signed Root CA Certificate"
if (test-path -path "$PSSCRIPTROOT/Cert") {
    write-host "Cert Path Exists"
} else {
    write-host "Createing Cert Path"
    New-Item -ItemType Directory -Path "$PSSCRIPTROOT/Cert"
}
$outKey = "$psscriptroot/Cert/selfsigned-ca-key.pem"
$outCA = "$psscriptroot/Cert/selfsigned-ca-cert.pem"
openssl req -x509 -newkey rsa:2048 -days 365 -keyout $outKey -out $outCA -passout pass:$($orgID) -subj "/C=/ST=/L=/O=JumpClout Test/OU=/CN=Test Intermediate 1"
# ::REM PEM pass phrase: myorgpass
openssl x509 -in $outCA -noout -text
# openssl x509 -in ca-cert.pem -noout -text