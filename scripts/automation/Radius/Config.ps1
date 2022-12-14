# READ ONLY API KEY
$JCAPIKEY = 'yourApiKey'
# JUMPCLOUD ORGID
$JCORGID = 'yourOrgId'
# JUMPCLOUD USER GROUP
$JCUSERGROUP = '635079e21490b90001eb275b'
# USER CERT PASSWORD (user must enter this when importing cert)
$JCUSERCERTPASS = 'secret1234!'
# Enter Cert Subject Headers (do not enter strings with spaces)
$Subj = [PSCustomObject]@{
    countryCode      = "US"
    stateCode        = "CO"
    Locality         = "Boulder"
    Organization     = "JumpCloud"
    OrganizationUnit = "Solutions_Architecture"
    CommonName       = "JumpCloud.com"
}

# Cert Type Generation Options:
# Chose One Of:
# EmailSAN
# EmailDN
# UsernameCn (Default)
$CertType = "UsernameCn"