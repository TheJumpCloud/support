#!/bin/bash

## Requires curl, jq

echo "Enter your API Key "
read -s apikey

getSystems() { # Gets systems where ssh password login, public key authentication, and multifactor authentication are enabled/allowed

curl -# \
  -X 'POST' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apikey}" \
  -d '{ "filter" : 
        { "and" : 
          [ 
            { "allowSshPasswordAuthentication" : "true" }, 
            { "allowPublicKeyAuthentication" : "true" }, 
            { "allowMultiFactorAuthentication" : "true" }
          ] 
        }, 
      "fields" : "id" }' \
"https://console.jumpcloud.com/api/search/systems"

}

putSystemParams() { # Updates systems found in getSystems with the desired sshd params

echo "Updating system ${system_id}" >> results

curl -silent -w "%{http_code}" \
  -X PUT https://console.jumpcloud.com/api/systems/"${system_id}" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "x-api-key: ${apikey}" \
  -d '{
      "allowSshPasswordAuthentication":"false",
      "allowSshRootLogin":"false",
      "allowMultiFactorAuthentication":"false",
      "allowPublicKeyAuthentication":"true"
      }'

echo >> results
echo >> results

}

ids=$(getSystems | jq '.results[].id' | tr -d '"')

if [[ -z "${ids}" ]]; then
 echo "No systems match the filter criteria"  && exit 0
fi

cat << EOF >> results
Systems matching the filter criteria:

${ids}

EOF

for i in `echo "${ids}"`; do system_id=$i && putSystemParams >> results; done

