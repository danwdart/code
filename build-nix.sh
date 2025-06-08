#!/usr/bin/env bash
set -euo pipefail
# Show where we were when there was a problem.
# TODO
trap pwd ERR

checkCabal() {
    nix-shell -p haskell.compiler.ghc912 cabal-install --run "cabal outdated" 2>&1 | sed 's/^/Cabal outdated: /' || exit 1

    # nix-shell -p haskell.compiler.ghc912 cabal-install --run "cabal check" 2>&1 | sed 's/^/Cabal check: /'
    return 0
}

buildCabal_ghc912() {
    if [[ "$1" == "onlycore" || "$1" == "onlybase" ]]
    then
        echo "$1: updated to ghc 9.12 (only nix), skipping."
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

    nix-shell -j auto -p zlib haskell.compiler.ghc912 cabal-install --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.10: /'
    # nix-shell -p zlib haskell.compiler.ghc912 cabal-install
    nix-shell -p "haskell.packages.ghc912.cabal-clean" --run "cabal-clean" 2>&1 | sed 's/^/cabal-clean: /' || exit 1
}

buildCabal_ghc912() {
    if [[ "$1" != "onlycore" && "$1" != "onlybase" ]]
    then
        echo "Not using ghc 9.12 for this project yet."
        return 0
    fi

    # nix-shell -j auto -p zlib haskell.compiler.ghc912 cabal-install --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.12: /'
    nix-shell -p zlib haskell.compiler.ghc912 cabal-install --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.12: /'
    nix-shell -p "haskell.packages.ghc912.cabal-clean" --run "cabal-clean" 2>&1 | sed 's/^/cabal-clean: /' || exit 1
}

buildCabal_ghc912_jsbackend() {
    # nix-shell -j auto -p pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc912 pkgsCross.ghcjs.pkgsBuildHost.cabal-install --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.10 JS Backend: /'
    nix-shell -j auto -p "pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc912 cabal-install" --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.10 JS Backend: /'
}

buildCabal_ghc912_jsbackend() {
    nix-shell -j auto -p pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc912 pkgsCross.ghcjs.pkgsBuildHost.cabal-install --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.12 JS Backend: /'
    # nix-shell -j auto -p "pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc912 cabal-install" --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.12 JS Backend: /'
}

buildCabal() {
    buildCabal_ghc912 $1
    buildCabal_ghc912 $1
    # buildCabal_ghc912_jsbackend $1
    # buildCabal_ghc912_jsbackend $1
}

buildDefault() {
    nix-shell -j auto shell.nix --run "cabal clean && cabal new-build --minimize-conflict-set all -j" 2>&1 | sed 's/^/Cabal in default shell.nix: /'
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
nix-store -qR --include-outputs $(nix-instantiate -E "with import <nixpkgs> {}; (haskell.compiler.ghc912 cabal-install)" --add-root cabalroot --indirect) | cachix push dandart 2>&1 | sed 's/^/pushing cabal: /'
# nix-store -qR --include-outputs $(nix-store -qd $(nix-build -E "with import <nixpkgs> {}; (haskell.compiler.ghc912 cabal-install)")) | grep -v '\.drv$' | cachix push dandart 2>&1 | sed 's/^/pushing cabal: /'
# nix-build -E "with import <nixpkgs> {}; (haskell.compiler.ghc912 cabal-install)" | cachix push dandart 2>&1 | sed 's/^/pushing cabal: /'
nix-shell -j auto -p haskell.compiler.ghc912 cabal-install --run "cabal update" 2>&1 | sed 's/^/cabal update: /'
nix-shell -j auto -p haskell.compiler.ghc912 cabal-install --run "cabal new-update" 2>&1 | sed 's/^/cabal new-update: /'

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
        # grep -v consolefrp | \
        # grep -v static | \
        grep -v misostuff | \
        # grep -v kasmveh | \
        grep -v ffijs | \
        grep -v haskell-tools | \
        grep -v external | \
        grep -v ghcjs | \
        grep -v "dist-*" | \
        grep -v reflex-platform | \
        grep -v wasm-backend | \
        grep -v cards-ui | \
        grep -v tumblr-api | \
        grep -v yt-sort | \
        grep -v nixpkgs
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
            buildDefault $BASE 2>&1 | sed "s/^/$PREFIX_SED: Nix: /g"
        else
            echo "$PREFIX No shell.nix detected, building default.nix"
            buildDefault $BASE 2>&1 | sed "s/^/$PREFIX_SED: Nix: /g"
        fi
    done
    popd
    echo "Finished processing Nix projects in $CODEDIR"
done
cd $ORIG
echo "Finished all"
