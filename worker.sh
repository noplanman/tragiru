#!/bin/bash

# output something to keep alive
while sleep 1; do echo -n "."; done &

# configure runner
sed -i "s#TOKEN#${GITLAB_TOKEN}#" config/config.toml
sed -i "s#URL#${GITLAB_URL}#" config/config.toml

# start runner
docker pull gitlab/gitlab-runner:latest
docker run --name gitlab-runner --privileged \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    -v "$(pwd)/config:/etc/gitlab-runner" \
    -d gitlab/gitlab-runner:latest

# https://docs.travis-ci.com/user/customizing-the-build#Build-Timeouts
sleep $(( 45 * 60 ))

# restart process
ENCODED_SLUG=$(echo $TRAVIS_REPO_SLUG | sed 's/\//%2F/g')
curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Travis-API-Version: 3" \
    -H "Authorization: token ${TRAVIS_TOKEN}" \
    -d "{\"request\": {\"branch\":\"${TRAVIS_BRANCH}\"}}" \
    https://api.travis-ci.com/repo/${ENCODED_SLUG}/requests

exit 0
