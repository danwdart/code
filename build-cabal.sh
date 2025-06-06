#!/usr/bin/env bash
set -euo pipefail
# Show where we were when there was a problem.
# TODO
trap pwd ERR

checkCabal() {
    nix-shell -p haskell.compiler.ghc912 cabal-install --run "cabal outdated --exit-code" 2>&1 | sed 's/^/Cabal outdated: /' 

    # nix-shell -p haskell.compiler.ghc912 cabal-install --run "cabal check" 2>&1 | sed 's/^/Cabal check: /'
    # return 0
}


buildCabal_shell() {
    HERE="$1"
    FILES_REQUIRED="$2"
    SHELL="$3"
    CABAL="$4"
    COMPILER="$5"
    HC_PKG="$6"
    HSC2HS="$7"
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

    nix-build --extra-experimental-features flakes "$SHELL" -o result-$SHELL-shell 
    nix-shell --extra-experimental-features flakes "$SHELL" --run "$CABAL new-build --with-compiler=$COMPILER --with-hc-pkg=$HC_PKG --with-hsc2hs=$HSC2HS -j --minimize-conflict-set" 2>&1 | sed "s/^/GHC in $SHELL: /"
    # nix-shell -p "haskell.packages.ghc912.cabal-clean" --run "cabal-clean" 2>&1 | sed 's/^/cabal-clean: /' || exit 1
    # nix-shell -j auto shell-jsbackend.nix --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.12 JS Backend: /'
    # nix-shell -j auto -p "pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc912 cabal-install" --run "cabal clean && cabal new-build -j --minimize-conflict-set" 2>&1 | sed 's/^/GHC 9.12 JS Backend: /'
}

buildCabal() {
    buildCabal_shell $1 true shell.nix cabal ghc ghc-pkg hsc2hs
    buildCabal_shell $1 false shell-jsbackend.nix cabal javascript-unknown-ghcjs-ghc javascript-unknown-ghcjs-ghc-pkg javascript-unknown-ghcjs-hsc2hs
    buildCabal_shell $1 false shell-wasm.nix wasm32-wasi-cabal wasm32-wasi-ghc wasm32-wasi-ghc-pkg wasm32-wasi-hsc2hs
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
nix-shell -j auto -p pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc912 cabal-install --run "cabal update" 2>&1 | sed 's/^/ghcjs cabal update: /'
nix-shell -j auto -p pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc912 cabal-install --run "cabal new-update" 2>&1 | sed 's/^/ghcjs cabal new-update: /'
nix-shell --extra-experimental-features flakes -j auto -p "(builtins.getFlake "gitlab:haskell-wasm/ghc-wasm-meta?host=gitlab.haskell.org").packages.x86_64-linux.default" --run "wasm32-wasi-cabal update" 2>&1 | sed 's/^/wasm32-wasi-cabal update: /'
nix-shell --extra-experimental-features flakes -j auto -p "(builtins.getFlake "gitlab:haskell-wasm/ghc-wasm-meta?host=gitlab.haskell.org").packages.x86_64-linux.default" --run "wasm32-wasi-cabal new-update" 2>&1 | sed 's/^/wasm32-wasi-cabal new-update: /'

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

    pushd $CODEDIR
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
        grep -v js-backend | \
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
popd
echo "Finished all"
