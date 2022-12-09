# READ ONLY API KEY
$JCAPIKEY = 'yourApiKey'
# JUMPCLOUD ORGID
$JCORGID = 'yourOrgId'
# JUMPCLOUD USER GROUP
$JCUSERGROUP = '635079e21490b90001eb275b'
# Enter Cert Subject Headers:
$Subj = [PSCustomObject]@{
    countryCode      = "US"
    stateCode        = "CO"
    Locality         = "Boulder"
    Organization     = "JumpCloud"
    OrganizationUnit = "Solutions Architecture"
    CommonName       = "JumpCloud.com"
}

# Cert Type Generation Options:
# Chose One Of:
# EmailSAN
# EmailDN
# UsernameCn (Default)
$CertType = "EmailSAN"