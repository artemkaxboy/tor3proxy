#!/bin/bash

export DOCKER_REGISTRY_USERNAME=artemkaxboy
export DOCKER_IMAGE_NAME=tor3proxy

echo """
########################
######## RULES #########
########################

1.   Git has local changes:
      VERSION:  local
      REVISION: local
      REF_NAME: {current branch}
      TAG:      debug

2.   Git doesn't have changes:
2.1. Last commit has tag vX.X.X
      VERSION:  vX.X.X
      REVISION: {commit_hash}
      REF_NAME: {current branch}
      TAG:      vX vX.X vX.X.X latest

2.2. Last commit doesn't have tag vX.X.X
      VERSION:  local
      REVISION: {commit_hash}
      REF_NAME: {current_branch}
      TAG:      snapshot
"""

# git status --porcelain returns all repo changes if any. But when it is called in non-repo directory it fails with a message
# we are suppressing message here and checks return code further
git_status=$(git status --porcelain=v1 2>/dev/null)
if [ $? -ne 0 ]; then
    echo Git repository not found!
    exit 1
fi

# debug = 1 if there is any uncommitted changes in the repository, 0 - otherwise
if [ ${#git_status} -gt 0 ]; then
    debug=1
    echo "You have uncommitted changes. 'debug' tag will be used to build images. To get 'latest' and version tags for images, make sure you do not have uncommited changes."
else
    debug=0
fi
# debug=0 # TODO delete

# creates empty array
tags=()
# if debug = 1 tag must be debug, otherwise depends on branch and tag
if [ $debug -ne 0 ]; then
    tags+=("debug")
else
    current_commit=$(git log -n1 --pretty='%h')
    revision=${current_commit:0:7}

    # Finds git tag on the very last commit, fails if there is none. Use tag 'snapshot' on non tagged commit
    if ! git describe --exact-match --tags "$current_commit" >/dev/null 2>/dev/null ; then
        echo "There is no version tag on the latest commit, 'snapshot' tag will be used to build images. To get 'latest' and version tags for images, tag commit with 'v*.*.*' tag."
        tags+=("snapshot")
        version=snapshot

    else
        # check if tags contain version tag, use snapshot otherwise

        while read -r git_tag; do

            if [[ $git_tag =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then

                version=$git_tag
                tags+=("${BASH_REMATCH[1]}" "${BASH_REMATCH[1]}.${BASH_REMATCH[2]}" "${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}" "latest")
                echo "'${git_tag}' tag found, '${tags[*]}' tags will be used to build images"
            fi

        # `< <(COMMAND)` loads command result line by line to while loop
        done < <( git tag --points-at HEAD )

        # if there is no any version or latest tag use `snapshot`
        if [ ${#tags[@]} -eq 0 ]; then
            echo "No 'vX.X.X' tag found, 'snapshot' tag will be used to build images"
            tags+=("snapshot")
        fi
    fi
fi

# if version was not set
[ ${#version} -eq 0 ] && version=local
[ ${#revision} -eq 0 ] && revision=local

tags_string=
for tag in "${tags[@]}"
do
    echo "Building: $DOCKER_REGISTRY_USERNAME/$DOCKER_IMAGE_NAME:$tag"
    tags_string="${tags_string} --tag $DOCKER_REGISTRY_USERNAME/$DOCKER_IMAGE_NAME:$tag"
done

ref_name=$(git rev-parse --abbrev-ref HEAD)
now=$(date --rfc-3339=second --utc)

# Don't quote ${tags_string} it breaks command
docker buildx build --push \
    --build-arg VERSION="$version" --build-arg REVISION="$revision" \
    --build-arg REF_NAME="$ref_name" --build-arg CREATED="$now" \
    --platform linux/amd64,linux/arm64 \
    ${tags_string} \
    .
