#!/usr/bin/env bash
set -euo pipefail
# Show where we were when there was a problem.
# TODO
trap pwd ERR

checkCabal() {
    # nix-shell -p "haskell.packages.ghc910.ghcWithPackages (ghc: with ghc; [ cabal-install ])" --run "cabal check" 2>&1 | sed 's/^/Cabal check: /'
    return 0
}

buildCabal_ghc910() {
    if [[ "$1" == "funky-birthdays" || "$1" == "family" ]]
    then
        echo "$1: ghc requirement too old to do cabal build with ghc910."
        return 0
    fi

    if [[ "$1" == "coinflicker" ]]
    then
        echo "$1: needs to include libGL - however it is that you do that."
        return 0
    fi

    if [[ "$1" == "9.10" ]]
    then
        echo "$1: needs to include libudev - however it is that you do that."
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

    nix-shell -j auto -p "haskell.packages.ghc910.ghcWithPackages (ghc: with ghc; [ cabal-install ])" --run "cabal new-build" 2>&1 | sed 's/^/GHC 9.10: /'
    # nix-shell -p haskell.compilers.ghc910 haskell.packages.ghc910.cabal-install
}

buildCabal_ghc98() {
    if [[ "$1" == "9.10" || "$1" == "compositions" || "$1" == "ffi" || "$1" == "ffi-quickcheck" || "$1" == "cards" || "$1" == "kasmveh" ||"$1" == "maths" || "$1" == "peoplemanager" || "$1" == "reflex-headless" || "$1" == "projecteuler" || "$1" == "consolefrp" || "$1" == "tumblr-editor" || "$1" == "monopoly" || "$1" == "games" || "$1" == "whatcoffee" || "$1" == "hs-openfaas" || "$1" == "openfaas-examples" || "$1" == "4letters" || "$1" == "bots" || "$1" == "websites" || "$1" == "dubloons" || "$1" == "chatter" || "$1" == "2021" || "$1" == "onlybase" || "$1" == "onlycore" ]]
    then
        echo "$1: ghc requirement too new to do cabal build with ghc98."
        return 0
    fi

    if [[ "$1" == "funky-birthdays" || "$1" == "family" ]]
    then
        echo "$1: ghc requirement too old to do cabal build with ghc98."
        return 0
    fi

    if [[ "$1" == "coinflicker" ]]
    then
        echo "$1: needs to include libGL - however it is that you do that."
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

    nix-shell -j auto -p "haskell.packages.ghc98.ghcWithPackages (ghc: with ghc; [ cabal-install ])" --run "cabal new-build" 2>&1 | sed 's/^/GHC 9.8: /'
    # nix-shell -p haskell.compilers.ghc98 haskell.packages.ghc98.cabal-install
}

buildCabal_ghc98_jsbackend() {
    nix-shell -j auto -p "pkgsCross.pkgsHostBuild.ghcjs.haskell.packages.ghc98.ghcWithPackages (ghc: with ghc; [ cabal-install ])" --run "cabal new-build" 2>&1 | sed 's/^/GHC 9.8 JS Backend: /'
}

buildCabal_ghc910_jsbackend() {
    nix-shell -j auto -p "pkgsCross.pkgsHostBuild.ghcjs.haskell.packages.ghc910.ghcWithPackages (ghc: with ghc; [ cabal-install ])" --run "cabal new-build" 2>&1 | sed 's/^/GHC 9.10 JS Backend: /'
}

buildCabal() {
    buildCabal_ghc910 $1
    buildCabal_ghc98 $1
    # buildCabal_ghc910_jsbackend $1
    # buildCabal_ghc98_jsbackend $1
}

buildDefault() {
    nix-shell -j auto shell.nix --run "cabal new-build all -j" 2>&1 | sed 's/^/GHC Default: /'
    nix-build -j auto  # | cachix push dandart
}

pushShell() {
    # nix-store -qR --include-outputs $(nix-instantiate shell.nix --add-root result-shell --indirect) | grep -v \\.drv | cachix push dandart 2>&1 | sed 's/^/pushShell: /'
    nix-store -qR --include-outputs $(nix-store -qd $(nix-build shell.nix)) | grep -v \\.drv | cachix push dandart 2>&1 | sed 's/^/pushShell: /'
}

buildShell() {
    nix-build shell.nix -o result-shell -j auto 2>&1 | sed 's/^/buildShell: /' #  | cachix push dandart
    pushShell &
}

help() {
    echo "Usage: $0 (n)"
    echo "n: "
}

nix-channel --update
# these don't seem to really do anything...
nix-store -qR --include-outputs $(nix-instantiate -E "with import <nixpkgs> {}; (haskell.packages.ghc910.ghcWithPackages (ghc: with ghc; [ cabal-install ]))" --add-root cabalroot --indirect) | cachix push dandart 2>&1 | sed 's/^/pushing cabal: /'
# nix-store -qR --include-outputs $(nix-store -qd $(nix-build -E "with import <nixpkgs> {}; (haskell.packages.ghc910.ghcWithPackages (ghc: with ghc; [ cabal-install ]))")) | grep -v '\.drv$' | cachix push dandart 2>&1 | sed 's/^/pushing cabal: /'
# nix-build -E "with import <nixpkgs> {}; (haskell.packages.ghc910.ghcWithPackages (ghc: with ghc; [ cabal-install ]))" | cachix push dandart 2>&1 | sed 's/^/pushing cabal: /'
nix-shell -j auto -p "haskell.packages.ghc910.ghcWithPackages (ghc: with ghc; [ cabal-install ])" --run "cabal new-update" 2>&1 | sed 's/^/cabal new-update: /'

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
        # grep -v kasmveh | \
        grep -v ffijs | \
        grep -v haskell-tools | \
        grep -v external | \
        grep -v ghcjs | \
        grep -v dist-newstyle | \
        grep -v reflex-platform | \
        grep -v wasm-backend | \
        grep -v cards-ui | \
        grep -v yt-sort
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
        checkCabal $BASE 2>&1 | sed "s/^/$PREFIX_SED: Cabal checking: /g"
        buildCabal $BASE 2>&1 | sed "s/^/$PREFIX_SED: Cabal: /g"
        if [[ -f shell.nix ]]
        then
            echo "$PREFIX Nix Shell: Building shell.nix..."
            buildShell 2>&1 | sed "s/^/$PREFIX_SED: Nix Shell: /g"
            echo "$PREFIX Nix: Building default.nix..."
            buildDefault 2>&1 | sed "s/^/$PREFIX_SED: Nix: /g"
        else
            echo "$PREFIX No shell.nix detected, building default.nix"
            buildDefault 2>&1 | sed "s/^/$PREFIX_SED: Nix: /g"
        fi
    done
    popd
    echo "Finished processing Nix projects in $CODEDIR"
done
cd $ORIG
echo "Finished all"
