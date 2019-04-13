# How to publish new version of docker image

    docker pull {user}/{image}:latest
    docker tag {user}/{image}:latest {user}/{image}:{version}
    docker push {user}/{image}:{version}