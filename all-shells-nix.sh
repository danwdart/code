#!/usr/bin/env bash
set -euo pipefail
# Show where we were when there was a problem.
# TODO
trap pwd ERR


pushShell() {
    # This gives a warning about --add-root but we already added the root above.
    nix-store -qR --include-outputs $(nix-instantiate shell.nix) | cachix push dandart
}

buildShell() {
    nix-build shell.nix -o result-shell #  | cachix push dandart
    pushShell &
}

ORIG=$(pwd)
CODEDIRS="$PWD/mine" # $PWD/contrib
for CODEDIR in $CODEDIRS
do
    cd $CODEDIR
    echo Finding Nix projects in $CODEDIR...
    PROJECTS=$(find $CODEDIR -name default.nix | grep -v external | grep -v ghcjs | grep -v "dist-*" | grep -v wasm-cross | grep -v reflex-platform | grep -v templates)
    NUMPROJECTS=0
    for FILE in $PROJECTS
    do
        ((NUMPROJECTS+=1))
    done
    PROJECTNUMBER=0
    for FILE in $PROJECTS
    do
        ((PROJECTNUMBER+=1))
        DIRLOC=$(dirname $FILE)
        BASE=$(basename $DIRLOC)
        PREFIX="$BASE ($PROJECTNUMBER/$NUMPROJECTS) >>> "
        PREFIX_SED="$BASE ($PROJECTNUMBER\/$NUMPROJECTS) >>> "

        # Uncomment to skip
        # if [ 18 -gt $PROJECTNUMBER ]; then continue; fi

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
            buildShell 2>&1 | sed "s/^/$PREFIX_SED /g"
        fi
    done
    cd $CODEDIR
    echo "Finished processing Nix projects in $CODEDIR"
done
cd $ORIG
echo "Finished all"