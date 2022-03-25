#!/usr/bin/env nix-shell
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/haskell-updates.tar.gz -p git -i bash
set -euxo pipefail

CODEDIR=$PWD/mine
cd $CODEDIR
echo Finding Reflex projects...
for DIR in $(find $CODEDIR -name reflex-platform)
do
    echo Entering $DIR
    cd $DIR
    git pull
    cd ..
    git add reflex-platform
    git commit -m 'Update reflex' || echo not all
    git push
done
cd $CODEDIR
echo Done!