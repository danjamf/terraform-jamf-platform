#!/bin/sh

#Jamf Connect Login Location
 jamfConnectLoginLocation="/Library/Security/SecurityAgentPlugins/JamfConnectLogin.bundle"
 
 jamfConnectLoginVersion=$(defaults read "$jamfConnectLoginLocation"/Contents/Info.plist "CFBundleShortVersionString" || echo "Does not exist")
echo "jamfConnectLoginVersion"
echo "<result>$jamfConnectLoginVersion</result>"