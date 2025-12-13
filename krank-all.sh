#!/usr/bin/env nix-shell
#! nix-shell -i bash
set -euo pipefail

ORIG=$(pwd)
CODEDIRS="$PWD/mine" # $PWD/contrib
for CODEDIR in $CODEDIRS
do
    cd "$CODEDIR"
    echo Finding Nix projects in "$CODEDIR"...
    PROJECTS=$(find "$CODEDIR" -name default.nix | grep -v external | grep -v ghcjs | grep -v "dist-*" | grep -v wasm-cross | grep -v reflex-platform | grep -v templates)
    NUMPROJECTS=0
    for FILE in $PROJECTS
    do
        ((NUMPROJECTS+=1))
    done
    PROJECTNUMBER=0
    for FILE in $PROJECTS
    do
        ((PROJECTNUMBER+=1))
        DIRLOC=$(dirname "$FILE")
        BASE=$(basename "$DIRLOC")
        PREFIX="$BASE ($PROJECTNUMBER/$NUMPROJECTS) >>> "
        # PREFIX_SED="$BASE ($PROJECTNUMBER\/$NUMPROJECTS) >>> "

        # Uncomment to skip
        # if [ 17 -gt $PROJECTNUMBER ]; then continue; fi

        echo "$PREFIX Entering $DIRLOC"
        cd "$DIRLOC"

        nix-shell --run "krank *.nix"
    done
    cd "$CODEDIR"
    echo "Finished processing Nix projects in $CODEDIR"
done
cd "$ORIG"
echo "Finished all"