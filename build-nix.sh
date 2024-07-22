#!/usr/bin/env bash
set -euo pipefail
# Show where we were when there was a problem.
# TODO
trap pwd ERR

buildDefault() {
    nix-shell shell.nix --run "cabal new-build all -j12"
    nix-build -j12  # | cachix push dandart
}

pushShell() {
    nix-store -qR --include-outputs $(nix-instantiate shell.nix --add-root result-shell --indirect) | cachix push dandart
}

buildShell() {
    nix-build shell.nix -o result-shell -j12 #  | cachix push dandart
    pushShell &
}

help() {
    echo "Usage: $0 (n)"
    echo "n: "
}

ORIG=$(pwd)
CODEDIRS="$PWD/mine $PWD/contrib"
NUMCODEDIRS=0
for CODEDIR in $CODEDIRS
do
    ((NUMCODEDIRS+=1))
done
CODEDIRNUMBER=0
for CODEDIR in $CODEDIRS
do
    ((CODEDIRNUMBER+=1))
    # Uncomment to skip
    # if [ 2 -gt $CODEDIRNUMBER ]; then continue; fi

    cd $CODEDIR
    echo Finding Nix projects in $CODEDIR...
    # jobfinder, websites
    PROJECTS=$(find $CODEDIR -name default.nix | \
        grep -v jobfinder | \
        grep -v archery | \
        # grep -v family | \
        # fatal: Could not parse object 'cff413cfad99d6a2c6594a286b9d7446fc357ff3'.
        # grep -v consolefrp | \
        # grep -v static | \
        grep -v misostuff | \
        grep -v kasmveh | \
        grep -v ffijs | \
        grep -v haskell-tools | \
        grep -v external | \
        grep -v ghcjs | \
        grep -v dist-newstyle | \
        grep -v reflex-platform | \
        grep -v wasm-backend | \
        grep -v cards-ui
        # grep -v tumblr-editor | \
        # grep -v hs-webdriver | \
        )
    NUMPROJECTS=0
    for FILE in $PROJECTS
    do
        # Double brackets mean as a number, else concat
        ((NUMPROJECTS+=1))
    done
    PROJECTNUMBER=0
    for FILE in $PROJECTS
    do
        # Double brackets mean as a number, else concat
        ((PROJECTNUMBER+=1))

        # Uncomment to skip
        if [[ $# > 0 && $1 -gt $PROJECTNUMBER ]]
        then
            echo Skipping $FILE
            continue
        fi

        DIRLOC=$(dirname $FILE)
        BASE=$(basename $DIRLOC)

        # if [[ "family" == $BASE ]]; then continue; fi

        # if [[ "chatter" == $BASE || "dubloons" == $BASE || "hs-stdlib" == $BASE || "jobfinder" == $BASE || "9.2.2" == $BASE || "peoplemanager" == $BASE || "tumblr-editor" == $BASE ]]; then continue; fi

        # waiting for https://github.com/NixOS/nixpkgs/issues/197388
        # if [[ "9.4.2" == $BASE || "peoplemanager" == $BASE ]]; then continue; fi

        PREFIX="$BASE ($PROJECTNUMBER/$NUMPROJECTS) >>> "
        PREFIX_SED="$BASE ($PROJECTNUMBER\/$NUMPROJECTS) >>> "

        echo "$PREFIX Entering $DIRLOC"
        cd $DIRLOC
        if [[ -f .gitmodules ]]
        then
            echo "$PREFIX .gitmodules found, updating..."
            git submodule update --init --recursive
        fi
        if [[ -f shell.nix ]]
        then
            echo "$PREFIX Building shell.nix..."
            buildShell $BASE 2>&1 | sed "s/^/$PREFIX_SED /g"
            echo "$PREFIX Building default.nix..."
            buildDefault $BASE 2>&1 | sed "s/^/$PREFIX_SED /g"
        else
            echo "$PREFIX No shell.nix detected, building default.nix"
            buildDefault $BASE 2>&1 | sed "s/^/$PREFIX_SED /g"
        fi
    done
    cd $CODEDIR
    echo "Finished processing Nix projects in $CODEDIR"
done
cd $ORIG
echo "Finished all"
