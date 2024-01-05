Describe 'distribute tests' {
    context 'certs for all users are generated' {
        it 'generates certs for all users' {
            . "/Users/jworkman/Documents/GitHub/support/scripts/automation/Radius/Functions/Public/Distribute-UserCerts.ps1"
            Distribute-UserCerts -generateType all
            # validate that the commands were created for valid users
        }
    }
}