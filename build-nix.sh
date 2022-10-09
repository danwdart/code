#!/usr/bin/env bash
set -euo pipefail
# Show where we were when there was a problem.
# TODO
trap pwd ERR

buildDefault() {
    nix-build # | cachix push websites
}

pushShell() {
    nix-store -qR --include-outputs $(nix-instantiate shell.nix --add-root result-shell --indirect) | cachix push websites
}

buildShell() {
    nix-build shell.nix -o result-shell #  | cachix push websites
    pushShell &
}

buildReflex() {
    nix-build shell.nix -o result/shell
    (nix-store -qR --include-outputs $(nix-instantiate shell.nix --add-root result-shell --indirect) | cachix push websites) &

    nix-build shell-ghcjs.nix -o result/shell-ghcjs
    (nix-store -qR --include-outputs $(nix-instantiate shell-ghcjs.nix --add-root result-shell-ghcjs --indirect) | cachix push websites) &

    #if [[ -f shell-wasm.nix ]]
    #then
    #    #nix-build shell-wasm.nix
    #    #nix-store -qR --include-outputs $(nix-instantiate shell-wasm.nix) | cachix push websites
    #fi

    nix-build -A ghc.common -o result/common
    # nix-store -qR --include-outputs $(nix-instantiate -A ghc.common) | cachix push websites

    nix-build -A ghc.backend -o result/backend
    # nix-store -qR --include-outputs $(nix-instantiate -A ghc.backend) | cachix push websites

    nix-build -A ghc.frontend -o result/frontend-ghc
    # nix-store -qR --include-outputs $(nix-instantiate -A ghc.frontend) | cachix push websites

    nix-build -A ghcjs.common -o result/common-ghcjs
    # nix-store -qR --include-outputs $(nix-instantiate -A ghcjs.common) | cachix push websites

    nix-build -A ghcjs.frontend -o result/frontend
    # nix-store -qR --include-outputs $(nix-instantiate -A ghcjs.frontend) | cachix push websites

    # nix-build -A android.frontend -o result/android # Too much memory and OOM crashes
    # Infinite recursion errors
    # nix-build -A wasm.common -o result/common-wasm
    # nix-build -A wasm.frontend -o result/frontend-wasm
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
        grep -v consolefrp | \
        grep -v static | \
        grep -v ffijs | \
        grep -v websites | \
        grep -v nixos-manager | \
        grep -v home-manager | \
        grep -v haskell-tools | \
        grep -v external | \
        grep -v ghcjs | \
        grep -v dist-newstyle | \
        grep -v wasm-cross | \
        grep -v reflex-platform | \
        grep -v templates | \
        grep -v tumblr-editor | \
        grep -v hs-webdriver | \
        grep -v tree-diff | \
        grep -v warp | \
        grep -v twee) # webdriver
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
        # if [ 16 -gt $PROJECTNUMBER ]; then continue; fi

        DIRLOC=$(dirname $FILE)
        BASE=$(basename $DIRLOC)

        # if [[ "chatter" == $BASE || "dubloons" == $BASE || "hs-stdlib" == $BASE || "jobfinder" == $BASE || "9.2.2" == $BASE || "peoplemanager" == $BASE || "tumblr-editor" == $BASE ]]; then continue; fi

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
