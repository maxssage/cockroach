#!/bin/bash

set -e

gopath0="${GOPATH%%:*}"
cachedir="${gopath0}/pkg/cache"
tag="cockroachdb/builder"

if ! docker images | grep -q "${tag}"; then
    # If there's a base image cached, load it. A click on CircleCI's "Clear
    # Cache" will make sure we start with a clean slate.
    mkdir -p "${cachedir}"
    if [[ ! -e "${cachedir}/builder.tar" ]]; then
	docker pull "${tag}"
	docker save "${tag}" > "${cachedir}/builder.tar"
    else
	docker load -i "${cachedir}/builder.tar"
    fi
fi

HOME= go get -d -u github.com/cockroachdb/build-cache
HOME= go get -u github.com/robfig/glock
grep -v '^cmd' GLOCKFILE | glock sync -n

# Pretend we're already bootstrapped, so that `make` doesn't try to get us
# started which is impossible without a working Go env.
touch .bootstrap && make '.git/hooks/*'

build=$(dirname $0)/circle-build.sh
${build} go install github.com/cockroachdb/build-cache
${build} build-cache restore .
${build} go test -v -i ./...
${build} build-cache save .
