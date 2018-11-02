#!/bin/bash

###############################################################################
#
# jumpcloud_test_utility.sh - This is a menu driven utility for testing common
#       common protocols via command line, icluding LDAP, General Access API
#       and Events API
#
# Questions or issues with the operation of the script, please contact
# support@jumpcloud.com
#
# Author: Rob Holden | rholden@jumpcloud.com
# 
###############################################################################

clear

#
# Help screen
#

help() {
cat << EOF
###################################################################
#                                                                 #
#             JumpCloud command line testing utility              #        
#                                                                 #
###################################################################

Enter q to exit

This utility is meant to assist in testing and configuring LDAP
with JumpCloud using the native ldapsearch command and API
interaction.            

Step 1. Enter LDAP account variables				
	
LDAP Binding User account name:  If you do not know this, please
refer to 
https://support.jumpcloud.com/customer/portal/articles/2439911

Password:  This is the password for the LDAP Binding User	

Organization ID				

Step 2. Pick a port using option 2 or 3				

Step 3. Option 4 will allow you to connect to LDAP and search  
using the defined account variables				

Option 5 will list common strings used by the applications	
that will athenticate to JumpCloud LDAP.			

Option 6 will access API options

Option 9 displays this help screen				

Option 0 will exit the utility					
EOF
}


#
# ldapsearch
#

# Check for ldapsearch command

ldapsearch=`which ldapsearch`

which ldapsearch &>/dev/null;

if [ $? != 0 ]
	then
		echo "ldapsearch is not in your path or not installed.  Please correct and rerun this script";
		exit 1;
fi

# To make it a little bit easier to test against other than production.
CONSOLE_URL="https://console.jumpcloud.com"
if [ ! -z "${JUMPCLOUD_URL_OVERRIDE}" ]; then
    CONSOLE_URL=${JUMPCLOUD_URL_OVERRIDE}
fi

echo "CONSOLE_URL=${CONSOLE_URL}"

# Check account vars have been entered

check_ldap_config() {

if [ -z "$port" ]
        then
                echo "Port Undefined, using default 636";
                port=636;
                read -rsp $'press key to continue \n' -n1 key
fi

if [ "$port" = "389 -ZZ" ]
        then
                uri=ldap
        else
                uri=ldaps
fi

if [ -z "$user" ]
        then
                echo -e "\nAccount variables undefined, enter information and reselect\n";
                read_account;
fi
}

# Define ldapsearch 

ldsearch() {

check_ldap_config

$ldapsearch -H ${uri}://ldap.jumpcloud.com:${port} -x -b "ou=Users,o=${oid},dc=jumpcloud,dc=com" -D "uid=${user},ou=Users,o=${oid},dc=jumpcloud,dc=com" -w "${pass}" "(objectClass=${search_param})" | less

}

#
# Display common configuration strings
#

echo_ldap_config() {
cat << EOF
###################################################################
#                Common LDAP Configuration Settings               #
###################################################################

### URI/LDAP Server ###

ldaps://ldap.jumpcloud.com:636
ldap://ldap.jumpcloud.com:389

### BIND DN ###

uid=${user},ou=Users,o=${oid},dc=jumpcloud,dc=com

### Search DN/Base Search DN ###

ou=Users,o=${oid},dc=jumpcloud,dc=com

### LDAP Search Example ###

$ldapsearch -H ${uri}://ldap.jumpcloud.com:${port} -x -b "ou=Users,o=${oid},dc=jumpcloud,dc=com" -D "uid=${user},ou=Users,o=${oid},dc=jumpcloud,dc=com" -w "${pass}" "(objectClass=inetOrgPerson)"

**If the above ldapsearch command results in invalid credentials, and the password contains special characters (!,@,#,etc...), replace the double quotes (") around the password with single quotes (') and retry

EOF
}

# Display the settings

ldap_config() {

check_ldap_config
echo_ldap_config | less

}

#
# read in oid, ldap service account and password
#

# read username, check for null input

read_user() {
echo -n "Enter LDAP Binding User account name: "
        read user;
if [ -z "$user" ]
        then
                echo "Input cannot be null"; read_user;
        else
                read_pass;
fi
}

# read password, check for null input

read_pass() {
echo -n "Enter password: "
        read -s pass;
echo
if [ -z "$pass" ]
        then
                echo "Input cannot be null"; read_pass;
        else
                read_oid;
fi
}

# read oid, check for null input

read_oid() {
echo -n "Enter the organization ID: "
        read oid;
if [ -z "$oid" ]
        then
                echo "Input cannot be null"; read_oid;
        else continue;
fi
}

read_account() {

read_user

read_pass

read_oid

}

# Single Record Get, enter _id, check for null input

single_get() {
echo -n "Enter the _id value: "
        read id;
if [ -z "$id" ]
       then
		echo "Input cannot be null"; single_get;
       else 
		id=/${id}; 
		get_api | python -m json.tool | less;
		continue;
fi
}

# API Call

get_api() {

if [ -z "$org_id" ]; then
curl  \
  -X 'GET' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${api_key}" \
     "${CONSOLE_URL}/api/${api_object}${id}"
else
curl  \
  -X 'GET' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${api_key}" \
  -H "x-org-id: ${org_id}" \
     "${CONSOLE_URL}/api/${api_object}${id}"
fi

}

# read apikey, check for null input

read_api_key() {
echo -n "Enter your API Key: "
	read api_key;
if [ -z "$api_key" ]
	then
		echo "Input cannot be null"; read_api_key;
	else continue;
fi
}


read_org_id() {
echo -n "Enter the Org ID: "
    read org_id;
if [ -z "$org_id" ]
    then
        echo "Input cannot be null"; read_org_id;
    else continue;
fi
}

#
# Define LDAP menu
#

ldap_menu() {

clear
cat << EOF
###### LDAP Search Options ######"

1. List Users
2. List POSIX Groups
3. List Groups of Names
4. List all Objects
0. Main Menu
EOF

}

#
# Read LDAP menu
#

read_ldap_menu() {
echo -ne "\nSelect an option: "
        read ldap_option
        case $ldap_option in
                1) search_param=inetOrgPerson; ldsearch;;
                2) search_param=posixGroup; ldsearch;;
                3) search_param=groupOfNames; ldsearch;;
                4) search_param=*; ldsearch;;
		0) break;;
                *) 
                if [ -z "$ldap_option" ]
                        then
                                echo "Input cannot be null"; sleep .5;
                        else
                                echo -e "\n${ldap_option} is not a valid option"; sleep .5;
                fi;;
        esac

}

#
# Launch LDAP search menu
#

ldap_search_menu() {

while true
do
        ldap_menu
        read_ldap_menu
done

}

#
# set_system_search_field
#

set_system_search_field() {

clear
cat << EOF
###########################
##  Valid Search Fields  ##
###########################

This list shows the search field name and valid
search parameters. There is no error correction for
invalid field or the parameter. Invalid data will
produce null results.

displayName  -  Alpha/numeric, the value of the System Name in list 
                view, Display Name in system details
hostname  -  Alpha/numeric, the hostname of the system
os  -  Alpha, the base OS type of the system 
version  -  Alpha/numeric, the specific version of the OS 

EOF

        if [ -z "$system_search_param" ]
then
        echo "Current search parameter is undefined"
else
        echo "Current Search parameter is \"${system_search_param}"\"
fi

echo -ne "\nSelect a search field: "
        read system_search_field

        if [ -z "$system_search_field" ]
then
        echo "Search field cannot be null"; sleep .5; set_system_search_field
else
        continue
fi
}

# Set system_search_param

set_system_search_param() {

clear

cat << EOF
##########################
## Set Search Parameter ##
##########################

The user search parameter is case *insensitive*
by default. Regex is accepted.

EOF
        if [ -z "$system_search_field" ]
then
        echo "Currnet search field is undefined"
else
        echo "Current search field is \"${system_search_field}"\"
fi

echo -ne "\nEnter a search string: "
        read system_search_param

        if [ -z "$system_search_param" ]
then
        echo "Search string undefined"; sleep .5; set_system_search_param
else
        continue
fi

}

#
# System search
#

system_search() {

curl \
  -d '{ "filter" : [{ "'"${system_search_field}"'" : { "$regex" : "(?i)'"${system_search_param}"'" }}]}' \
  -X 'POST' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${api_key}" \
  -H "x-org-id: ${org_id}" \
  "${CONSOLE_URL}/api/search/systems?limit=100&skip=10"

}

#
# Define system_search_menu
#

system_search_menu() {

clear
cat << EOF
##########################
###   System Search    ###
##########################

1. Set Search Field
2. Set Search Parameter
3. Run Search
0. System Menu
EOF

}

#
# Read system_search_menu
#

read_system_search_menu() {

echo -ne "\nSelect an option: "
        read system_search_option
        case $system_search_option in
                1) set_system_search_field;;
                2) set_system_search_param;;
                3) system_search | python -m json.tool | less;;
                0) break;;
                *)
                                if [ -z "$system_search_option" ]
                        then
                                echo "Input cannot be null"; sleep .5;
                        else
                                echo -e "\n${system_search_option} is not a valid option"; sleep .5;
                fi;;
        esac
}

launch_system_search_menu() {

while true
do
        system_search_menu
        read_system_search_menu
done

}

#
# set_user_search_field
#

set_user_search_field() {

clear
cat << EOF
###########################
##  Valid Search Fields  ##
###########################

This list shows the search field name and valid
search parameters. There is no error correction for 
invalid field or the parameter. Invalid data will
produce null results.

email  -  Alpha/numeric, the email address associated with the user
firstname  -  Alpha/numeric, the first name associated with the user
lastname  -  Alpha/numeric, the last name associated with the user
username  -  Alpha/numeric, the unique username associated with the user

EOF

	if [ -z "$user_search_param" ]
then
	echo "Current search parameter is undefined"
else
	echo "Current Search parameter is \"${user_search_param}"\"
fi

echo -ne "\nSelect a search field: "
        read user_search_field

        if [ -z "$user_search_field" ]
then
        echo "Search field cannot be null"; sleep .5; set_user_search_field
else
	continue
fi
}

# Set user_search_param

set_user_search_param() {

clear

cat << EOF
##########################
## Set Search Parameter ##
##########################

The user search parameter is case *insensitive* 
by default. Regex is accepted.

EOF
	if [ -z "$user_search_field" ]
then
	echo "Currnet search field is undefined"
else
	echo "Current search field is \"${user_search_field}"\"
fi

echo -ne "\nEnter a search string: "
	read user_search_param

	if [ -z "$user_search_param" ]
then
	echo "Search string undefined"; sleep .5; set_user_search_param
else
	continue
fi

}


#
# User search
#

user_search() {

#call_type=POST
#search="  -d '{ \"filter\" : [{\"${user_search_field}\" : { \"\\$regex\" : \"(?i)${user_search_param}\"}}]}'"
#get_api | python -m json.tool | less

curl \
  -d '{ "filter" : [{ "'"${user_search_field}"'" : { "$regex" : "(?i)'"${user_search_param}"'" }}]}' \
  -X 'POST' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${api_key}" \
  -H "x-org-id: ${org_id}" \
  "${CONSOLE_URL}/api/search/systemusers?limit=100"

}

#
# Define user_search_menu
#

user_search_menu() {

clear
cat << EOF
##########################
###    User Search     ###
##########################

1. Set Search Field
2. Set Search Parameter
3. Run Search
0. User Menu
EOF

}

#
# Read user_search_menu
#

read_user_search_menu() {

echo -ne "\nSelect an option: "
	read user_search_option
	case $user_search_option in
		1) set_user_search_field;;
		2) set_user_search_param;;
		3) user_search | python -m json.tool | less;;
		0) break;;
		*)
		                if [ -z "$user_search_option" ]
                        then
                                echo "Input cannot be null"; sleep .5;
                        else
                                echo -e "\n${user_search_option} is not a valid option"; sleep .5;
                fi;;
        esac
}

launch_user_search_menu() {

while true
do
        user_search_menu
        read_user_search_menu
done

}

#
# Define command_menu
#

command_menu() {

clear
cat << EOF
##########################
###    Commands        ###
##########################

1. Commands multi record GET (limit 100)
2. Commands single record GET
3. Command results multi record GET (limit 100)
4. Command results single record GET
0. API Menu
EOF

}

#
# Read command menu
#

read_command_menu() {
api_object=commands
echo -ne "\nSelect an option: "
        read command_option
        case $command_option in
                1) api_object=$api_object?limit=100; get_api | python -m json.tool | less;;
                2) single_get;;
		3) api_object=commandresults?limit=100; get_api | python -m json.tool | less;;
		4) api_object=commandresults; single_get;;
                0) break;;
                *)
                if [ -z "$commmand_option" ]
                        then
                                echo "Input cannot be null"; sleep .5;
                        else
                                echo -e "\n${command_option} is not a valid option"; sleep .5;
                fi;;
        esac
}


launch_command_menu() {

while true
do
        command_menu
        read_command_menu
done

}

#
# Define system_menu
#

system_menu() {

clear
cat << EOF
##########################
###      Systems       ###
##########################

1. Multi record GET (limit 100)
2. Single record GET
3. Search
0. API Menu
EOF

}

#
# Read system menu
#

read_system_menu() {
api_object=systems
echo -ne "\nSelect an option: "
	read system_option
	case $system_option in
		1) api_object=$api_object?limit=100; get_api | python -m json.tool | less;;
		2) single_get;;
		3) launch_system_search_menu;;
		0) break;;
		*) 
		if [ -z "$system_option" ]
        		then
                		echo "Input cannot be null"; sleep .5;
        		else
                		echo -e "\n${system_option} is not a valid option"; sleep .5;
		fi;;
	esac
}

launch_system_menu() {

while true
do
	system_menu
	read_system_menu
done

}

#
# Define user_menu
#

user_menu() {

clear
cat << EOF
##########################
###       Users        ###
##########################

1. Multi record GET (limit 100)
2. Single record GET
3. Search
0. API Menu
EOF

}

#
# Read user menu
#

read_user_menu() {
api_object=systemusers;
echo -ne "\nSelect an option: "
        read user_option
        case $user_option in
                1) api_object=$api_object?limit=100; get_api | python -m json.tool | less;;
                2) single_get;;
                3) launch_user_search_menu;;
                0) break;;
                *) 
                if [ -z "$user_option" ]
                        then
                                echo "Input cannot be null"; sleep .5;
                        else
                                echo -e "\n${user_option} is not a valid option"; sleep .5;
                fi;;
        esac

}

launch_user_menu() {

while true
do
	user_menu
	read_user_menu
done

}

#
# Get Events for prev 24 hrs
#

set_date() {

end_date=`date -u +%Y-%m-%dT%H:%M:%SZ`

months=(0 31 28 31 30 31 30 31 31 30 31 30 31)

today=`date -u +%d`
yesterday=`expr $today - 1`
month=`date -u +%m`
yestermonth=${month}
year=`date -u +%Y`
yesteryear=${year}

if ((${yesterday} < 10))
        then
        if ((${yesterday} == 0))
            then
                yestermonth=`expr $month - 1`
                if ((${yestermonth} == 0))
                    then
                        yesteryear=`expr $year - 1`
                        yestermonth=12
                        yesterday=31
                    else
                        yesterday=${months[${yestermonth}]}
                        yesteryear=${year}
                fi
        else
            yesterday=0${yesterday}
        fi
fi

start_date=`date -u +${yesteryear}-%${yestermonth}-${yesterday}T%H:%M:%SZ`

}

call_events() {

if [ -z "${org_id}" ]; then
    curl \
     -G \
     -H "x-api-key: ${api_key}" \
     -H "Content-Type:application/json" \
     --data-urlencode "startDate=${start_date}" \
     "https://events.jumpcloud.com/events"
else
    curl \
     -G \
     -H "x-api-key: ${api_key}" \
     -H "x-org-id: ${org_id}" \
     -H "Content-Type:application/json" \
     --data-urlencode "startDate=${start_date}" \
     "https://events.jumpcloud.com/events"
fi

}

#
# Define API menu
#

api_menu() {

clear
cat << EOF
##########################
###     API Access     ###
##########################

1. Enter API Key (Required)
2. Enter OrgId (Required for multi-tenant admin)
3. Users
4. Systems
5. Commands
6. Events (Prev 24 hrs UTC)
0. Main Menu
EOF

}

#
# Read API menu
#

read_api_menu() {
echo -ne "\nSelect an option: "
	read api_option
	case $api_option in
		1) read_api_key;;
		2) read_org_id;;
		3) launch_user_menu;;
		4) launch_system_menu;;
		5) launch_command_menu;;
		6) set_date;call_events | python -m json.tool | less;;
                0) break;;
                *) 
                if [ -z "$api_option" ]
                        then
                                echo "Input cannot be null"; sleep .5;
                        else
                                echo -e "\n${api_option} is not a valid option"; sleep .5;
                fi;;
        esac

}
 
#
# Launch API menu
#

launch_api_menu() {

while true
do
	api_menu
	read_api_menu
done

}



#
# Define main menu
#

main_menu() {
clear
cat << EOF
###########################
####    Main Menu     #####
###########################

1. Enter LDAP account variables
2. Set LDAP port 389 (STARTTLS)
3. Set LDAP port 636 (SSL)
4. LDAP Search Menu
5. Display Common LDAP settings
6. API access
9. Help
0. Exit
EOF

}

#
# Read main menu options
#

read_main_menu() {
echo -ne "\nSelect an option: "
        read option
        case $option in
                1) read_account;;
                2) port="389 -ZZ"; echo -e "\n**Port set to 389\n";;
                3) port=636; echo -e "\n**Port set to 636\n";;
                4) ldap_search_menu;;
                5) ldap_config;;
		6) launch_api_menu;;
                9) help | less;;
                0) exit 0;;
                *) 
                if [ -z "$option" ]
                        then
                                echo "Input cannot be null"; sleep .5;
                        else
                                echo -e "\n${option} is not a valid option"; sleep .5;
                fi;;
        esac
}

#
# Launch main menu
#

while true
do
        main_menu
        read_main_menu
done

