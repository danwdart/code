#!/usr/bin/env bash
set -euo pipefail
# Show where we were when there was a problem.
# TODO
trap pwd ERR

pushDefault() {
    # This gives a warning about --add-root but we already added the root above.
    nix-store -qR --include-outputs $(nix-instantiate) | cachix push websites
}

buildDefault() {
    nix-build # | cachix push websites
    # pushDefault &
}

pushShell() {
    # This gives a warning about --add-root but we already added the root above.
    nix-store -qR --include-outputs $(nix-instantiate shell.nix) | cachix push websites
}

buildShell() {
    nix-build shell.nix -o result-shell #  | cachix push websites
    pushShell &
}

buildReflex() {
    #if [[ -f shell-ghcjs.nix ]]
    #then
    #    #nix-build shell-ghcjs.nix
    #    #nix-store -qR --include-outputs $(nix-instantiate shell-ghcjs.nix) | cachix push websites
    #fi
    #if [[ -f shell-wasm.nix ]]
    #then
    #    #nix-build shell-wasm.nix
    #    #nix-store -qR --include-outputs $(nix-instantiate shell-wasm.nix) | cachix push websites
    #fi
    
    #nix-build -A ghc.common -o result/common
    #nix-store -qR --include-outputs $(nix-instantiate -A ghc.common) | cachix push websites

    #nix-build -A ghc.backend -o result/backend
    #nix-store -qR --include-outputs $(nix-instantiate -A ghc.backend) | cachix push websites

    #nix-build -A ghc.frontend -o result/frontend-ghc
    #nix-store -qR --include-outputs $(nix-instantiate -A ghc.frontend) | cachix push websites

    #nix-build -A ghcjs.common -o result/common-ghcjs
    #nix-store -qR --include-outputs $(nix-instantiate -A ghcjs.common) | cachix push websites

    #nix-build -A ghcjs.frontend -o result/frontend
    #nix-store -qR --include-outputs $(nix-instantiate -A ghcjs.frontend) | cachix push websites

    # nix-build -A android.frontend -o result/android # Too much memory and OOM crashes
    # Infinite recursion errors
    # nix-build -A wasm.common -o result/common-wasm
    # nix-build -A wasm.frontend -o result/frontend-wasm
    echo skipping for now
}

buildReflexOrDefault() {
    if [[ -d external ]]
    then
        buildReflex
    else
        buildDefault
    fi
}

ORIG=$(pwd)
CODEDIRS="$PWD/mine" # $PWD/contrib
for CODEDIR in $CODEDIRS
do
    cd $CODEDIR
    echo Finding Nix projects in $CODEDIR...
    PROJECTS=$(find $CODEDIR -name default.nix | grep -v external | grep -v ghcjs | grep -v dist-newstyle | grep -v wasm-cross | grep -v reflex-platform | grep -v templates)
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
        # if [ 17 -gt $PROJECTNUMBER ]; then continue; fi

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
            echo "$PREFIX Building default.nix..."
            buildReflexOrDefault 2>&1 | sed "s/^/$PREFIX_SED /g"
        else
            echo "$PREFIX No shell.nix detected, building default.nix"
            buildReflexOrDefault 2>&1 | sed "s/^/$PREFIX_SED /g"
        fi
    done
    cd $CODEDIR
    echo "Finished processing Nix projects in $CODEDIR"
done
cd $ORIG
echo "Finished all"