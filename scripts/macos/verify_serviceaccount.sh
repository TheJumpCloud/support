 MacOSMinorVersion=$(sw_vers -productVersion | cut -d '.' -f 2)	 MacOSMinorVersion=$(sw_vers -productVersion | cut -d '.' -f 2)
 MacOSPatchVersion=$(sw_vers -productVersion | cut -d '.' -f 3)	 MacOSPatchVersion=$(sw_vers -productVersion | cut -d '.' -f 3)
 	 
 if [[ $MacOSMinorVersion -lt 13 ]]; then	 if [[ $MacOSMinorVersion -lt 13 ]]; then
     echo "Error:  Target system is not on macOS 10.13"	     echo "Error:  Target system is not on macOS 10.13"
     exit 2	     exit 2
-fi	+else
 	 
-JCSA_Username="_jumpcloudserviceaccount"	+curl --silent --output /tmp/jumpcloud-agent.pkg "https://s3.amazonaws.com/jumpcloud-windows-agent/production/jumpcloud-agent.pkg" > /dev/null
-JCSA_FullName="JumpCloud Service Account"	+mkdir -p /opt/jc
+cat <<-EOF > /opt/jc/agentBootstrap.json
+{
+"publicKickstartUrl": "https://kickstart.jumpcloud.com:443",
+"privateKickstartUrl": "https://private-kickstart.jumpcloud.com:443",
+"connectKey": "$YOUR_CONNECT_KEY"
+}
+EOF
 	 
-sysadmin_name="sysadminctl"	
-if [[ $MacOSMinorVersion -eq 13 ]]; then	
-    if [[ $MacOSPatchVersion -lt 4 ]]; then	
-        sysadmin_name="/opt/jc/bin/sysadminkludge"	
-    fi	
-fi	
 	 
-result=$($sysadmin_name -secureTokenStatus $JCSA_Username 2>&1 )	+cat <<-EOF > /var/run/JumpCloud-SecureToken-Creds.txt
-unknown_user=$(echo $result | grep "Unknown user $JCSA_Username")	+$SECURETOKEN_ADMIN_USERNAME;$SECURETOKEN_ADMIN_PASSWORD
-enabled=$(echo $result | grep "Secure token is ENABLED for user $JCSA_FullName")	+EOF
 	 
-if [[ ! -z $unknown_user ]]; then	+installer -pkg /tmp/jumpcloud-agent.pkg -target / &
-    echo "Error:  JumpCloud Service Account not installed"	
-    exit 2	
 fi	 fi
-	+exit 0 
-if [[ -z $enabled ]]; then	
-    echo "Error:  JumpCloud Service Account does not have a secure token"	
-    exit 3	
-fi	
-	
-echo "Success: JumpCloud Service Account has been properly created"	
-exit 0
