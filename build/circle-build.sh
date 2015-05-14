#!/bin/bash

set -e

gopath0="${GOPATH%%:*}"

# Run our build container with a set of volumes mounted that will
# allow the container to store persistent build data on the host
# computer.
#
# TODO(pmattis): We should specify --rm, but the docker version on
# CircleCI is oldish (1.4) and contains a bug in removing volumes,
# complaining:
#
#   Failed to destroy btrfs snapshot: operation not permitted
docker run -it \
       --volume="${gopath0}/src:/go/src" \
       --volume="${PWD}:/go/src/github.com/cockroachdb/cockroach" \
       --volume="${gopath0}/pkg:/go/pkg" \
       --volume="${gopath0}/pkg/linux_amd64_netgo:/usr/src/go/pkg/linux_amd64_netgo" \
       --volume="${gopath0}/bin/linux_amd64:/go/bin" \
       --workdir="/go/src/github.com/cockroachdb/cockroach" \
       --env="CACHE=/go/pkg/cache" \
       "cockroachdb/builder" "$@"
