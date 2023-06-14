#!/bin/bash
echo $OSTYPE
openssl version
if [[ "$OSTYPE" =~ ^darwin ]]; then
    brew install openssl
    brew install gsed

    installedVersion=$(ls /usr/local/Cellar/openssl@3)
    open_ssl_binary="/usr/local/Cellar/openssl@3/$installedVersion/bin/openssl"
    sed_binary='gsed'
    # brew install <some-package>
fi

if [[ "$OSTYPE" =~ ^linux ]]; then
    open_ssl_binary='openssl'
    sed_binary='sed'
    # sudo apt-get install <some-package>
fi
# First we need to generate a self-signed CA certificate:
# Define Certificate Path
if [[ ! -d "$(dirname -- "${BASH_SOURCE[0]}")/../Cert" ]]; then
  # script statements if $DIR doesn't exist.
  mkdir "$(dirname -- "${BASH_SOURCE[0]}")/../Cert"
fi
if [[ ! -d "$(dirname -- "${BASH_SOURCE[0]}")/../UserCerts" ]]; then
  # script statements if $DIR doesn't exist.
  mkdir "$(dirname -- "${BASH_SOURCE[0]}")/../UserCerts"
fi
caPath="$(dirname -- "${BASH_SOURCE[0]}")/../Cert"

# Random password func
rand_pass () {
    pass=$($open_ssl_binary rand -base64 12)
    echo "$pass"
}

# Set variables and paths
outKey="$caPath/radius_ca_key.pem"
outCA="$caPath/radius_ca_cert.pem"
certKeyPass=$(rand_pass)
export certKeyPass=$(rand_pass)

countryCode='US'
stateCode='CO'
Locality='Boulder'
Organization='JumpCloud'
OrganizationUnit='Solutions_Architecture'
CommonName='JumpCloud.com'


reqDistinguishedName="[req_distinguished_name]\\n
C = $countryCode\\n
ST = $stateCode\\n
L = $Locality\\n
O = $Organization\\n
OU = $OrganizationUnit\\n
CN = $CommonName\\n
\\n"
# generate certs:
$open_ssl_binary req -x509 -newkey rsa:2048 -days 365 -keyout "$outKey" -out "$outCA" -passout pass:"$certKeyPass" -subj /C=$countryCode/ST=$stateCode/L=$Locality/O=$Organization/OU=$OrganizationUnit/CN=$CommonName
# validate the cert:
# $open_ssl_binary x509 -in "$outCA" -noout -text

# Define a user:
# TODO: update to be whoami
username='test.user'
firstName='test'
lastName='user'
localUsername=''
email="$username@domain.com"
certType='emailDN' # emailDN, emailSAN or usernameCN
JCUSERCERTPASS='potato'
JCUSERCERTVALIDITY='365'
# update extension files:
FILES="$(dirname -- "${BASH_SOURCE[0]}")/../Extensions/*"
for f in $FILES
do
    echo "Updating Extension file: $f"
    $sed_binary -i "s/C =.*/C = $countryCode/g" "$f"
    $sed_binary -i "s/ST =.*/ST = $stateCode/g" "$f"
    $sed_binary -i "s/L =.*/L = $Locality/g" "$f"
    $sed_binary -i "s/O =.*/O = $Organization/g" "$f"
    $sed_binary -i "s/OU =.*/OU = $OrganizationUnit/g" "$f"
    $sed_binary -i "s/CN =.*/CN = $CommonName/g" "$f"

    if [[ $certType == "EmailSAN" ]] && [[ $f =~ "EmailSAN" ]]; then
        $sed_binary -i "s/subjectAltName.*/subjectAltName = email:$email/g" "$f"
    fi
done


JCORGID='gxj36oq0400asdzq012dupmv'

# Set Extension Path
ExtensionPath="$(dirname -- "${BASH_SOURCE[0]}")/../Extensions/extensions-$certType.cnf"
# User Certificate Signing Request:
userCSR="$(dirname -- "${BASH_SOURCE[0]}")/../UserCerts/$username-cert-req.csr"
# define the user cert paths:
userKey="$(dirname -- "${BASH_SOURCE[0]}")/../UserCerts/$username-$certType-client-signed.key"
userCert="$(dirname -- "${BASH_SOURCE[0]}")/../UserCerts/$username-$certType-client-signed-cert.crt"
userPfx="$(dirname -- "${BASH_SOURCE[0]}")/../UserCerts/$username-client-signed.pfx"
rootCAKey=$outKey
rootCA=$outCA
$open_ssl_binary genrsa -out "$userKey" 2048
# Generate User CSR
$open_ssl_binary req -nodes -new -key "$rootCAKey" -passin pass:"$certKeyPass" -out "$userCSR" -subj /C=$countryCode/ST=$stateCode/L=$Locality/O=$JCORGID/OU=$OrganizationUnit/CN=$CommonName
$open_ssl_binary req -new -key "$userKey" -out "$userCSR" -config "$ExtensionPath" -subj /C=$countryCode/ST=$stateCode/L=$Locality/O=$JCORGID/OU=$OrganizationUnit/CN=/emailAddress=$email
# Gennerate User Cert
$open_ssl_binary x509 -req -in "$userCSR" -CA "$rootCA" -CAkey "$rootCAKey" -days $JCUSERCERTVALIDITY -passin pass:"$certKeyPass" -CAcreateserial -out "$userCert" -extfile $ExtensionPath
# Combine key and cert to create pfx file
$open_ssl_binary pkcs12 -export -out "$userPfx" -inkey "$userKey" -in "$userCert" -passout pass:"$JCUSERCERTPASS" -legacy # for 1.1.1. version of openssl legacy tag not needed
# Output
# $open_ssl_binary x509 -noout -text -in "$userCert"
# invoke-expression "$$open_ssl_binary pkcs12 -clcerts -nokeys -in $userPfx -passin pass:$($JCUSERCERTPASS)"\
certSN=$($open_ssl_binary x509 -noout -serial -in "$userCert" | cut -d'=' -f2)
echo $certSN