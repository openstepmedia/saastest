#!/usr/bin/env bash

doPush=0
if [[ "${CI_REGISTRY_USER}" != "" ]]; then
    docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD}

    releaseImg="${CI_REGISTRY_IMAGE}:devops-${CI_COMMIT_REF_NAME}"
    doPush=1
else :
    releaseImg="devops"
fi

echo "release image: ${releaseImg}"

docker pull ${releaseImg} || true

docker build -f tools/devops/Dockerfile --cache-from ${releaseImg} -t ${releaseImg} .

if [[ $doPush == 1 ]]; then
    docker push ${releaseImg}
fi

binPath=$GOROOT/bin/devops
echo "installing to: ${binPath}"

docker run --rm --entrypoint=cat devops /devops > $binPath
