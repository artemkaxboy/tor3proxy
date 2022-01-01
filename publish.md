# How to publish new version of docker image

    docker pull {user}/{image}:latest
    docker tag {user}/{image}:latest {user}/{image}:{version}
    docker push {user}/{image}:{version}

## Insatalling multi arch requirements

Source <https://docs.docker.com/buildx/working-with-buildx/#build-multi-platform-images>

docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --use --name mybuild node-amd64
docker buildx create --append --name mybuild node-arm64
docker buildx build --push --build-arg VERSION=snapshot --build-arg REVISION=local --build-arg REF_NAME=dev  --platform linux/amd64,linux/arm64 -t artemkaxboy/tor3proxy:snapshot .

```shell
$(git rev-parse --abbrev-ref HEAD)
```
