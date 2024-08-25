#!/usr/bin/env bash
set -euo pipefail
# Show where we were when there was a problem.
# TODO
trap pwd ERR

buildCabal_ghc910() {
    # Not in Nix yet
    # nix-shell -p "haskell.packages.ghc910.ghcWithPackages (ghc: with ghc; [ cabal-install ])"
    # nix-shell -p haskell.compilers.ghc910 haskell.packages.ghc910.cabal-install
    return 0
}

buildCabal_ghc98() {
    if [[ "$1" == "compositions" || "$1" == "2021" || "$1" == "onlybase" || "$1" == "onlycore" ]]
    then
        echo "$1: ghc too new to do cabal build with ghc98."
        return 0
    fi

    if [[ "$1" == "funky-birthdays" || "$1" == "family" ]]
    then
        echo "$1: ghc too old to do cabal build with ghc98."
        return 0
    fi

    if [[ "$1" == "websites" ]]
    then
        echo "$1: compatibility issue for cabal builds - TODO fix."
        return 0
    fi

    if [[ "$1" == "monopoly" || "$1" == "projecteuler" || "$1" == "cards" || "$1" == "maths" || "$1" == "games" ]]
    then
        echo "$1: hspec issue - TODO fix. Building without tests."
        nix-shell -p "haskell.packages.ghc98.ghcWithPackages (ghc: with ghc; [ cabal-install ])" --run "cabal new-build --disable-tests"
        return 0
    fi

    if [[ "$1" == "coinflicker" ]]
    then
        echo "$1: needs to include libGL - however it is that you do that."
        return 0
    fi

    if [[ "$1" == "9.8" ]]
    then
        echo "$1: needs to include libudev - however it is that you do that."
        return 0
    fi

    if [[ "$1" == "reflex-headless" || "$1" == "consolefrp" ]]
    then
        echo "$1: TODO needs to add the option in cabal.project to allow newer because of reflex. Building with allow-newer for now."
        nix-shell -p "haskell.packages.ghc98.ghcWithPackages (ghc: with ghc; [ cabal-install ])" --run "cabal new-build --allow-newer"
        return 0
    fi

    if [[ "$1" == "peoplemanager" ]]
    then
        echo "$1: TODO update fakedata"
        return 0
    fi

    if [[ "$1" == "tumblr-api" ]]
    then
        echo "$1: fix humblr"
        return 0
    fi

    if [[ "$1" == "js-backend" ]]
    then
        echo "$1: requires js backend"
        return 0
    fi

    nix-shell -p "haskell.packages.ghc98.ghcWithPackages (ghc: with ghc; [ cabal-install ])" --run "cabal new-build"
    # nix-shell -p haskell.compilers.ghc98 haskell.packages.ghc98.cabal-install
}

buildCabal() {
    buildCabal_ghc910 $1
    buildCabal_ghc98 $1
}

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

        PREFIX="$BASE ($PROJECTNUMBER/$NUMPROJECTS) >>> "
        PREFIX_SED="$BASE ($PROJECTNUMBER\/$NUMPROJECTS) >>> "

        echo "$PREFIX Entering $DIRLOC"
        pushd $DIRLOC
        if [[ -f .gitmodules ]]
        then
            echo "$PREFIX .gitmodules found, updating..."
            git submodule update --init --recursive
        fi
        echo "$PREFIX Building cabal-only..."
        buildCabal $BASE 2>&1 | sed "s/^/$PREFIX_SED /g"
        if [[ -f shell.nix ]]
        then
            echo "$PREFIX Building shell.nix..."
            buildShell 2>&1 | sed "s/^/$PREFIX_SED /g"
            echo "$PREFIX Building default.nix..."
            buildDefault 2>&1 | sed "s/^/$PREFIX_SED /g"
        else
            echo "$PREFIX No shell.nix detected, building default.nix"
            buildDefault 2>&1 | sed "s/^/$PREFIX_SED /g"
        fi
    done
    popd
    echo "Finished processing Nix projects in $CODEDIR"
done
cd $ORIG
echo "Finished all"
