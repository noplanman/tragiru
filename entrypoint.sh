#!/bin/bash

# display runner log
docker logs -f gitlab-runner &

# https://docs.travis-ci.com/user/customizing-the-build#Build-Timeouts
MAX_DURATION=$((45 * 60))
STARTING_TIME=$(date +%s)
ENDING_TIME=$(($STARTING_TIME + $MAX_DURATION))

echo -n "Waiting for restart"
while [[ $(date +%s) -lt $ENDING_TIME ]]; do
    # some kind of output is required otherwise
    # travis will cancel the job earlier
    echo -n "."
    sleep 10
done

if [[ "$TRAVIS_TOKEN" != "" ]]; then
    ENCODED_SLUG=$(echo $TRAVIS_REPO_SLUG |sed 's/\//%2F/g')
    # start a rebuild again
    curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -H "Travis-API-Version: 3" \
     -H "Authorization: token ${TRAVIS_TOKEN}" \
     -d "{\"request\": {\"branch\":\"${TRAVIS_BRANCH}\"}}" \
     "https://api.travis-ci.org/repo/${ENCODED_SLUG}/requests"
fi
