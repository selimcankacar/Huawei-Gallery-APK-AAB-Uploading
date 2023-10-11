# Replace these values with your suitable values.
client_id="<clientid>"
client_secret="<clientsecret>"
appid="<appid>"

# GENERATE TOKEN AND ASSIGN TO A VARIABLE (1)
token=$(curl -H 'Content-Type: application/json' -d '{ "grant_type":"client_credentials","client_id": "'$client_id'", "client_secret": "'$client_secret'"}' -X POST https://connect-api.cloud.huawei.com/api/oauth2/v1/token | jq -r .access_token)

# GET UPLOAD URL, AUTHCODE  & STORE RESPONSE BODY (2)
curl -H 'Content-Type: application/json' -H "Authorization: Bearer $token" -H "client_id: $client_id" -X GET "https://connect-api.cloud.huawei.com/api/publish/v2/upload-url?appId=${appid}&suffix=aab&releaseType=1" | jq . > answer.json

# PARSE RESPONSE BODY (3)
url=$(cat answer.json | jq -r .uploadUrl)
authcode=$(cat answer.json | jq .authCode)
fileCount=1
name="<file>.aab"
parseType=0

echo "-----------STARTING-----------"

# UPLOAD AAB FİLE & STORE RESPONSE BODY (4)
curl --location "$url" \
--form 'file=@"/Users/selimcankacar/folder/<file>.aab"' \
--form "authCode="$authcode"" \
--form 'fileCount="1"' | jq . > answer2.json

#PARSE RESPONSE BODY (5)
desturl=$(cat answer2.json | jq -r '.result.UploadFileRsp.fileInfoList.[0].fileDestUlr')

#UPDATING APP FILE INFORMATION (6)
curl --location --request PUT "https://connect-api.cloud.huawei.com/api/publish/v2/app-file-info?appId=${appid}" \
--header "client_id: $client_id" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $token" \
--data '{
       "fileType":5,
       "files":{
              "fileName":"'$name'",
              "fileDestUrl":"'$desturl'"
       }
}'
