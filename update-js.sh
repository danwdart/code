#!/usr/bin/env nix-shell
#! nix-shell -p nodejs nodePackages.npm nodePackages.npm-check-updates python3 -i bash
set -euxo pipefail

CODEDIR=$PWD/mine
cd $CODEDIR
echo Finding JS projects...
for FILE in $(find $CODEDIR -name package.json | grep -v bower_components | grep -v node_modules)
do
    DIRLOC=$(dirname $FILE)
    BASE=$(basename $DIRLOC)
    echo Entering $DIRLOC
    cd $DIRLOC
    git pull
    if [[ -f .gitmodules ]]
    then
        echo .gitmodules found, updating...
        git submodule update --init --recursive
    fi
    rm package-lock.json || echo "nothing to remove"
    rm yarn.lock || echo "nothing to remove"
    ncu -ut latest || echo "Can't get the latest versions. Never mind."
    npm install --include=dev @snyk/protect || echo "Maybe we can't install snyk."
    npx @snyk/cli-protect-upgrade || echo "Couldn't upgrade the snyk stuff."
    npm install --package-lock-only || echo "couldn't create ourselves a package-lock.json, eh."
    npm install || echo "not all that bad in honesty it'll really just be my machine we just won't have a lockfile"
    npm audit fix --force || echo "yeah that's okay"
    git add package.json || echo "well if there's nothing there's nothing tbh"
    git add package-lock.json || echo "well if there's nothing there's nothing tbh"
    git commit -m "npm updates for $BASE" || echo "Nothing to commit, don't care"
    git push
done
cd $CODEDIR
echo "Done!"