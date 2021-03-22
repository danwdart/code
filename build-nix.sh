#!/usr/bin/env bash
CODEDIR=$PWD/mine
cd $CODEDIR
echo Finding Nix projects...
for FILE in $(find $CODEDIR -name default.nix | grep -v external)
do
    DIRLOC=$(dirname $FILE)
    echo Entering $DIRLOC
    cd $DIRLOC
    if [[ -f shell.nix ]]
    then
        echo shell.nix detected
        nix-build shell.nix | cachix push websites || exit 1
        nix-store -qR --include-outputs $(nix-instantiate shell.nix) | cachix push websites
    else
        echo No shell.nix detected, using default.nix
        nix-build | cachix push websites || exit 1
        nix-store -qR --include-outputs $(nix-instantiate) | cachix push websites
    fi
done
cd $CODEDIR
