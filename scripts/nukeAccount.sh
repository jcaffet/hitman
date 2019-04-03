#!/bin/sh

usage(){
    echo "Usage: $0 <profile> <accountId>"
    echo "profile : aws profile to reach Hitman assets"
    echo "accountId : aws account to nuke"
}

if [ $# -eq 2 ]; then
   profile=$1
   account=$2
else
   usage;
   exit 1;
fi

PAYLOAD='{"mode":"standalone", "accountId":"'"${account}"'"}'

echo "Get session on profile ${profile}"
echo "Payload : |${PAYLOAD}|"
aws --profile=${profile} lambda invoke \
    --function-name sharedservices-hitman \
    --invocation-type Event \
    --payload '{"mode":"standalone", "accountId":"'"${account}"'"}' \
    outfile.txt

