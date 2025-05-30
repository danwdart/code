#!/usr/bin/env bash
set -euo pipefail
# Show where we were when there was a problem.
# TODO
trap pwd ERR

checkCabal() {
    nix-shell -p haskell.compiler.ghc912 cabal-install --run "cabal outdated" 2>&1 || exit 1 | sed 's/^/Cabal outdated: /' 

    # nix-shell -p haskell.compiler.ghc912 cabal-install --run "cabal check" 2>&1 | sed 's/^/Cabal check: /'
    return 0
}


buildCabal_shell() {
    HERE=$1
    FILES_REQUIRED=$2
    SHELL=$3
    PROJECT=$4
    # nix-shell -j auto -p zlib haskell.compiler.ghc912 cabal-install --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.12: /'
    # cabal clean && 
    if [ ! -f "$SHELL" ]
    then
        echo No $SHELL file for $HERE.
        if [ "$FILES_REQUIRED" == "true" ]
        then
            exit 1
        fi
        return
    fi

    if [ ! -f "$PROJECT" ]
    then
        echo No $PROJECT file for $HERE.
        exit 1
        return
    fi

    nix-build --extra-experimental-features flakes $SHELL -o result-$SHELL-shell
    nix-shell --extra-experimental-features flakes $SHELL --run "cabal new-build --project-file=$PROJECT -j --minimize-conflict-set" 2>&1 | sed "s/^/GHC in $SHELL: /"
    # nix-shell -p "haskell.packages.ghc912.cabal-clean" --run "cabal-clean" 2>&1 | sed 's/^/cabal-clean: /' || exit 1
    # nix-shell -j auto shell-jsbackend.nix --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.12 JS Backend: /'
    # nix-shell -j auto -p "pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc912 cabal-install" --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.12 JS Backend: /'
}

buildCabal() {
    buildCabal_shell $1 true shell.nix cabal.project
    buildCabal_shell $1 false shell-jsbackend.nix cabal-jsbackend.project
    buildCabal_shell $1 false shell-wasm.nix cabal-wasm.project
}

help() {
    echo "Usage: $0 (n)"
    echo "n: "
}

nix-channel --update
# these don't seem to really do anything...
# nix-store -qR --include-outputs $(nix-instantiate -E "with import <nixpkgs> {}; (haskell.compiler.ghc912 cabal-install)" --add-root cabalroot --indirect) | cachix push dandart 2>&1 | sed 's/^/pushing cabal: /'
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
    PROJECTS=$(find $CODEDIR -name "*.cabal" | \
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
        grep -v slsdemo | \
        grep -v dist-newstyle | \
        grep -v reflex-platform | \
        grep -v wasm-backend | \
        grep -v cards-ui | \
        grep -v tumblr-api | \
        grep -v yt-sort | \
        grep -v java | \
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
    done
    popd
    echo "Finished processing Nix projects in $CODEDIR"
done
cd $ORIG
echo "Finished all"
