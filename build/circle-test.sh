#!/bin/bash

set -e

build=$(dirname $0)/circle-build.sh
${build} make test \
	 TESTTIMEOUT=30s TESTFLAGS='-v -vmodule=multiraft=5,raft=1' \
	 > "${CIRCLE_ARTIFACTS}/testrace.log"
