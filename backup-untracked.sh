#!/bin/sh
git submodule foreach --recursive "git ls-files -io --exclude-standard | \
    grep -v node_modules | \
    grep -v dist-newstyle | \
    grep -v result | \
    grep -v .direnv | \
    grep -v hie.yaml | \
    grep -v \\.o$ | \
    grep -v \\.a$ | \
    grep -v \\.hi$ | \
    grep -v stan.html | \
    grep -v \\.fd$ | \
    grep -v _stub\\.h$ | \
    grep -v .hie | \
    grep -v log | \
    grep -v build || echo ''"

#  -z | xargs -0 tar rvf