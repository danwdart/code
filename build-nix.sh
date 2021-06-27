#!/usr/bin/env bash

buildDefault() {
    nix-build # | cachix push websites
    nix-store -qR --include-outputs $(nix-instantiate) | cachix push websites
}

buildShell() {
    nix-build shell.nix #  | cachix push websites
    nix-store -qR --include-outputs $(nix-instantiate shell.nix) | cachix push websites
}

# set -e
# trap 'exit 1' ERR
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
        echo shell.nix detected, will build both shell.nix and default.nix
        echo Building shell.nix...
        buildShell
        echo Building default.nix...
        if [[ -d external ]]
        then
            echo Reflex detected, skipping default build
        else
            if [[ -d result ]]
            then
                echo result exists, skipping
            else
                buildDefault
            fi
        fi
    else
        echo No shell.nix detected, building default.nix
        buildDefault
    fi
done
cd $CODEDIR
