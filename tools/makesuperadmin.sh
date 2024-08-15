#!/bin/bash
###########################################################################################
## Create an API Client ID and Client Secret with FULL permissions - use for testing only #
###########################################################################################

#Prompt the user for API credentials
read -p "Enter username: " username
read -s -p "Enter password: " password
echo

# Prompt the user for the Jamf Pro URL
read -p "Enter Jamf Pro URL (e.g., https://example.jamfcloud.com): " url

# Perform actions with the provided credentials and URL
# For example:
echo "Using username: $username"
echo "Using password: $password"
echo "Using URL: $url"
#The name of the API Role
api_role_displayName="API Power Role"
#The name of the API Role
api_client_displayName="API Power User"
#The access token lifetime in seconds
lifetime="600"

#Base64 encode username:password
#encodedCredentials=$( printf "$username:$password" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )

#echo "encodedCredentials: $encodedCredentials"

authresponse=$(curl -s -u "$username":"$password" "$url"/api/v1/auth/token -X POST)
bearerToken=$(echo "$authresponse" | plutil -extract token raw -)

echo "$bearerToken"

#Generate an auth token
#authToken=$( /usr/bin/curl "$url/uapi/auth/tokens" \
#--silent \
#--request POST \
#--header "Authorization: Basic $encodedCredentials" )

#Parse authToken for token, omit expiration
#token=$( /usr/bin/awk -F \" '{ print $4 }' <<< "$authToken" | /usr/bin/xargs )

#GET all the current available privileges for an API Role
json=$(curl --request GET \
--url $url/api/v1/api-role-privileges \
--header "authorization: Bearer $bearerToken" \
--header 'accept: application/json')

#Extract ALL the API privileges available
privileges=$(echo "$json" | jq -r '.privileges[]' | awk '{printf "\"%s\", ", $0}' | sed 's/, $//')

#Create API Role
response=$(curl --request POST \
--url "$url/api/v1/api-roles" \
--header "authorization: Bearer $bearerToken" \
--header 'accept: application/json' \
--header 'content-type: application/json' \
--data "{
	\"displayName\": \"$api_role_displayName\",
	\"privileges\": [
		$privileges
	]
}")

#Extract displayName to use in next call
displayName=$(echo "$response" | jq -r '.displayName' | sed 's/displayName: //')

#Create API Client
response=$(curl --request POST \
--url "$url/api/v1/api-integrations" \
--header "authorization: Bearer $bearerToken" \
--header 'accept: application/json' \
--header 'content-type: application/json' \
--data "{
	\"displayName\": \"$api_client_displayName\",
	\"enabled\": \"true\",
	\"accessTokenLifetimeSeconds\": \"$lifetime\",
	\"authorizationScopes\": [
		\"$displayName\"
	]
}")

#Extract id of the API Client to use in next call
Id=$(echo "$response" | jq -r '.id')

#Create API Client Secret
response=$(curl --request POST \
--url "$url/api/v1/api-integrations/$Id/client-credentials" \
--header "authorization: Bearer $bearerToken" \
--header 'accept: application/json' )

#Extract the Client ID and Client Secret and print then out
clientId=$(echo "$response" | jq -r '.clientId')
clientSecret=$(echo "$response" | jq -r '.clientSecret')

echo "clientId: $clientId"
echo "clientSecret: $clientSecret"