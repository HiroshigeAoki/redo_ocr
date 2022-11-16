#!/bin/bash
# https://github.com/dinosauria123/gcv2hocr/blob/master/gcvocr.sh
# 言語を英語に変更

echo '{"requests":[{"image":{"content":"' > ./temp.json
openssl base64 -in $1 | cat >> ./temp.json
echo '"},
"features":{"type":"TEXT_DETECTION","maxResults":2048},"imageContext":{"languageHints":'$LANG'}}]}' >> ./temp.json
curl -k -s -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
-H "Content-Type: application/json" \
https://vision.googleapis.com/v1/images:annotate?key=$2 --data-binary @./temp.json > "$1.json"
rm ./temp.json