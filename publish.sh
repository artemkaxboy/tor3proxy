#!/bin/sh

export DOCKER_REGISTRY_USERNAME=artemkaxboy
export DOCKER_IMAGE_NAME=tor3proxy


# debug = 1 if there is any uncommitted changes in the repository, 0 - otherwise
[ -z "$(git status --porcelain=v1 2>/dev/null)" ] && debug=1 || debug=0
# debug=0 # TODO delete

echo $debug

# if debug = 1 tag must be debug, otherwise depends on branch and tag
if [ "$debug" -eq 1 ]; then
    echo *********** $DOCKER_REGISTRY_USERNAME/$DOCKER_IMAGE_NAME:"$tag" **********************
    tag=debug
else
    current_commit=$(git log -n1 --pretty='%h')
    tag=$(git describe --exact-match --tags "$current_commit")
fi
[ $debug = 0 ] && echo DEBUG || echo not DEBUG

echo "$tag"
exit 1
version=snapshot
revision=todo
ref_name=$(git rev-parse --abbrev-ref HEAD)
now=$(date --rfc-3339=second --utc)

docker buildx build --push \
    --build-arg VERSION="$version" --build-arg REVISION="$revision" \
    --build-arg REF_NAME="$ref_name" --build-arg CREATED="$now" \
    --platform linux/amd64,linux/arm64 \
    --tag $DOCKER_REGISTRY_USERNAME/$DOCKER_IMAGE_NAME:$version \
    .
