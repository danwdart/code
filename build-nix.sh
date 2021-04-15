#!/usr/bin/env bash
set -e
trap 'exit 1' ERR
CODEDIR=$PWD/mine
cd $CODEDIR
echo Finding Nix projects...
for FILE in $(find $CODEDIR -name default.nix | grep -v external | grep -v ghcjs | grep -v dist-newstyle)
do
    DIRLOC=$(dirname $FILE)
    echo Entering $DIRLOC
    cd $DIRLOC
    if [[ -f .gitmodules ]]
    then
        echo .gitmodules found, updating...
        git submodule update --init --recursive
    fi
    if [[ -f shell.nix ]]
    then
        echo shell.nix detected
        nix-build shell.nix #  | cachix push websites
        nix-store -qR --include-outputs $(nix-instantiate shell.nix) | cachix push websites
    else
        echo No shell.nix detected, using default.nix
        nix-build # | cachix push websites
        nix-store -qR --include-outputs $(nix-instantiate) | cachix push websites
    fi
done
cd $CODEDIR
