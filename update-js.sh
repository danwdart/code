#!/usr/bin/env nix-shell
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/master.tar.gz -p nodejs nodePackages.npm nodePackages.npm-check-updates python -i bash
set -euxo pipefail

CODEDIR=$PWD/mine
cd $CODEDIR
echo Finding JS projects...
for FILE in $(find $CODEDIR -name package.json | grep -v bower_components | grep -v node_modules)
do
    DIRLOC=$(dirname $FILE)
    echo Entering $DIRLOC
    cd $DIRLOC
    if [[ -f .gitmodules ]]
    then
        echo .gitmodules found, updating...
        git submodule update --init --recursive
    fi
    rm package-lock.json || echo irrelevant
    rm yarn.lock || echo irrelevant
    ncu -ut greatest
    npm install
    git add package.json package-lock.json
    git commit -m "npm updates for $(basename $DIRLOC)" || echo nah
    git push
done
cd $CODEDIR
echo Done!