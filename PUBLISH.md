# How to publish new version of docker image

## Insatalling multi arch requirements

Source <https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images>

docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --use --name mybuild node-amd64
docker buildx create --append --name mybuild node-arm64

## Publishing debug

* make changes
* run ./publish.sh
* :debug images published

## Publishing snapshot

* make changes
* commit changes
* push changes (accept PR)
* check tests result
* run ./publish.sh
* :snapshot images published

## Publishing release

* make changes
* commit changes
* push changes (accept PR)
* check tests result
* tag commit with 'vX.Y.Z' tag
* push tag
* run ./publish.sh
* :X.Y.Z :X.Y :X :latest images published
