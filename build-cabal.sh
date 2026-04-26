#!/usr/bin/env bash
set -euo pipefail
# Show where we were when there was a problem.
# TODO
trap pwd ERR

NIXPKGS="https://github.com/NixOS/nixpkgs/archive/master.zip"

checkCabal() {
    HERE="$1"

    if [[ "tumblr-editor" == "$HERE"
        || "websites" == "$HERE"
        || "archery" == "$HERE"
        || "common" == "$HERE"
    ]] # TODO come back to common
    then
        echo Ignoring running cabal-outdated.
        return 0
    fi
    nix-shell -I nixpkgs=$NIXPKGS -p haskell.compiler.ghc914 cabal-install --run "cabal outdated --exit-code" 2>&1 | sed 's/^/Cabal outdated: /' 

    # nix-shell -p haskell.compiler.ghc914 cabal-install --run "cabal check" 2>&1 | sed 's/^/Cabal check: /'
    # return 0
}

testCabal() {
    HERE="$1"
    if [[ "websites" == "$HERE"
        || "common" == "$HERE"
        || "jolharg-web-database" == "$HERE"
        || "jolharg-web-types" == "$HERE"
        || "jolharg-web-models" == "$HERE"
        || "jolharg-database" == "$HERE"
        || "jolharg-emails" == "$HERE"
        || "jolharg-servant" == "$HERE"
        || "jolharg-reflex" == "$HERE"
        || "jolharg-web" == "$HERE"
        || "jolharg-servant-examples" == "$HERE"
        || "db-instances" == "$HERE"
        || "jolharg-api-types" == "$HERE"
        || "jolharg-models" == "$HERE"
        || "ui" == "$HERE"
        || "api" == "$HERE"
        || "archery" == "$HERE"
        || "misostuff" == "$HERE"
        || "js-backend" == "$HERE"
        || "wasm-backend" == "$HERE"
        || "ghcjs-stuff" == "$HERE"
        || "ffijs" == "$HERE"
        || "slsdemo" == "$HERE"
        || "reflex-stuff" == "$HERE"
        || "tumblr-api" == "$HERE"
    ]] # TODO come back to common
    then
        echo Ignoring running cabal-test.
        return 0
    fi
    nix-shell -I nixpkgs=$NIXPKGS -p haskell.compiler.ghc914 cabal-install --run "cabal test" 2>&1 | sed 's/^/Cabal test: /' 
}

buildCabal_shell() {
    HERE="$1"
    FILES_REQUIRED="$2"
    SHELL_NIX="$3"
    CABAL="$4"
    COMPILER="$5"
    HC_PKG="$6"
    HSC2HS="$7"
    EXTRA_CABAL_FLAGS="$8"

    if [[
        "ui" == "$HERE" ||
        "api" == "$HERE" ||
        "misostuff" == "$HERE" ||
        "js-backend" == "$HERE" ||
        "tumblr-api" == "$HERE" ||
        "cards-ui" == "$HERE"
    ]]
    then
        echo Ignoring building this.
        return 0
    fi

    # nix-shell -j auto -p zlib haskell.compiler.ghc914 cabal-install --run "cabal clean && cabal new-build -j" 2>&1 | sed 's/^/GHC 9.12: /'
    # cabal clean && 
    if [ ! -f "$SHELL_NIX" ]
    then
        echo No "$SHELL_NIX" file for "$HERE".
        if [ "$FILES_REQUIRED" == "true" ]
        then
            return
        fi
        return
    fi
    echo "Building the shell..."
    nix-build -I nixpkgs=$NIXPKGS --extra-experimental-features flakes "$SHELL_NIX" -o result-"$SHELL_NIX"-shell
    echo "Built the shell. Building the package..."
    nix-shell -I nixpkgs=$NIXPKGS --extra-experimental-features flakes "$SHELL_NIX" --run "$CABAL new-build --with-compiler=$COMPILER --with-hc-pkg=$HC_PKG --with-hsc2hs=$HSC2HS $EXTRA_CABAL_FLAGS -j" 2>&1 | sed "s/^/GHC in $SHELL_NIX: /"
    # nix-shell -I nixpkgs=$NIXPKGS -p "haskell.packages.ghc914.cabal-clean" --run "cabal-clean" 2>&1 | sed 's/^/cabal-clean: /' || exit 1
    # nix-shell -I nixpkgs=$NIXPKGS -j auto shell-jsbackend.nix --run "cabal clean && cabal new-build -j" 2>&1 | sed 's/^/GHC 9.12 JS Backend: /'
    # nix-shell -I nixpkgs=$NIXPKGS -j auto -p "pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc914 cabal-install" --run "cabal clean && cabal new-build -j" 2>&1 | sed 's/^/GHC 9.12 JS Backend: /'
    # TODO flag
    # echo "Unfreezing the dependencies..."
    # rm *.freeze || true
    # echo "Freezing the dependencies..."
    # nix-shell -I nixpkgs=$NIXPKGS --extra-experimental-features flakes "$SHELL_NIX" --run "$CABAL v2-freeze --with-compiler=$COMPILER --with-hc-pkg=$HC_PKG --with-hsc2hs=$HSC2HS $EXTRA_CABAL_FLAGS -j" 2>&1 | sed "s/^/GHC in $SHELL_NIX: /"
    echo "Built the package."
}

# TODO project file for freeze
buildCabal() {
    echo "Building cabal ghc."
    buildCabal_shell "$1" true shell.nix cabal ghc ghc-pkg hsc2hs "" 2>&1 | sed "s/^/$PREFIX_SED: GHC: /g"
    # echo "Building cabal musl."
    # buildCabal_shell "$1" false shell-musl.nix cabal ghc ghc-pkg hsc2hs "--builddir=dist-musl -fmusl" 2>&1 | sed "s/^/$PREFIX_SED: Musl: /g"
    # echo "Building microhs."
    # buildCabal_shell "$1" false shell-mhs.nix mcabal mhs mhs mhs "--builddir=dist-mhs -fmhs" 2>&1 | sed "s/^/$PREFIX_SED: MicroHS: /g"
    # echo "Building cabal jsbackend."
    # buildCabal_shell "$1" false shell-jsbackend.nix cabal javascript-unknown-ghcjs-ghc javascript-unknown-ghcjs-ghc-pkg javascript-unknown-ghcjs-hsc2hs ""  2>&1 | sed "s/^/$PREFIX_SED: GHCJS: /g"
    echo "Building cabal wasm."
    buildCabal_shell "$1" false shell-wasm.nix wasm32-wasi-cabal wasm32-wasi-ghc wasm32-wasi-ghc-pkg wasm32-wasi-hsc2hs "" 2>&1 | sed "s/^/$PREFIX_SED: WASM: /g"
}

help() {
    echo "Usage: $0 (n)"
    echo "n: number to skip to"
}

nix-channel --update
# these don't seem to really do anything#     [[ -f ~/.local/bin/refactor ]] || cabal install apply-refact cabal-add cabal-fmt doctest ghci-dap ghcid ghcide haskell-debug-adapter haskell-language-server hasktags hlint hoogle hpack implicit-hie stan stylish-haskell weeder --allow-newer
# nix-store -qR --include-outputs $(nix-instantiate -E "with import <nixpkgs> {}; (haskell.compiler.ghc914 cabal-install)" --add-root cabalroot --indirect) | cachix push dandart 2>&1 | sed 's/^/pushing cabal: /'
# nix-store -qR --include-outputs $(nix-store -qd $(nix-build -E "with import <nixpkgs> {}; (haskell.compiler.ghc914 cabal-install)")) | grep -v '\.drv$' | cachix push dandart 2>&1 | sed 's/^/pushing cabal: /'
# nix-build -E "with import <nixpkgs> {}; (haskell.compiler.ghc914 cabal-install)" | cachix push dandart 2>&1 | sed 's/^/pushing cabal: /'
echo "Updating cabal packages..."
nix-shell -I nixpkgs=$NIXPKGS -j auto -p haskell.compiler.ghc914 cabal-install --run "cabal update" 2>&1 | sed 's/^/cabal update: /'
# nix-shell -I nixpkgs=$NIXPKGS -j auto -p haskell.compiler.ghc914 cabal-install --run "cabal new-update" 2>&1 | sed 's/^/cabal new-update: /'
# echo "Cabal packages updated. Updating cabal-ghcjs packages..."
# nix-shell -I nixpkgs=$NIXPKGS -j auto -p pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc914 cabal-install --run "cabal update" 2>&1 | sed 's/^/ghcjs cabal update: /'
# nix-shell -I nixpkgs=$NIXPKGS -j auto -p pkgsCross.ghcjs.pkgsBuildHost.haskell.compiler.ghc914 cabal-install --run "cabal new-update" 2>&1 | sed 's/^/ghcjs cabal new-update: /'
echo "cabal-ghcjs packages updated. Updating cabal-wasm packages..."
nix-shell -I nixpkgs=$NIXPKGS --extra-experimental-features flakes -j auto -p "(builtins.getFlake "gitlab:haskell-wasm/ghc-wasm-meta?host=gitlab.haskell.org").packages.x86_64-linux.default" --run "wasm32-wasi-cabal update" 2>&1 | sed 's/^/wasm32-wasi-cabal update: /'
# nix-shell --extra-experimental-features flakes -j auto -p "(builtins.getFlake "gitlab:haskell-wasm/ghc-wasm-meta?host=gitlab.haskell.org").packages.x86_64-linux.default" --run "wasm32-wasi-cabal new-update" 2>&1 | sed 's/^/wasm32-wasi-cabal new-update: /'
echo "cabal-wasm packages updated. Traversing directory structure..."

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

    pushd "$CODEDIR"
    echo Finding Nix projects in "$CODEDIR"...
    # jobfinder, websites
    PROJECTS=$(find "$CODEDIR" -name "*.cabal" | \
        grep -v "dist-*" \
        # grep -v jobfinder | \
        # grep -v archery | \
        # # grep -v family | \
        # # grep -v consolefrp | \
        # # grep -v static | \
        # grep -v misostuff | \
        # # grep -v kasmveh | \
        # grep -v ffijs | \
        # grep -v haskell-tools | \
        # grep -v external | \
        # grep -v ghcjs | \
        # grep -v slsdemo | \
        # grep -v reflex-platform | \
        # grep -v wasm-backend | \
        # grep -v cards-ui | \
        # grep -v tumblr-api | \
        # grep -v yt-sort | \
        # grep -v java | \
        # grep -v js-backend | \
        # grep -v static | \
        # grep -v nixpkgs
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
        if [[ $# -gt 0 && $1 -gt $PROJECTNUMBER ]]
        then
            echo Skipping "$FILE"
            continue
        fi

        DIRLOC=$(dirname "$FILE")
        BASE=$(basename "$DIRLOC")

        # TODO fix modules
        [[ "$BASE" == "websites" ]] && continue

        PREFIX="$BASE ($PROJECTNUMBER/$NUMPROJECTS) >>> "
        PREFIX_SED="$BASE ($PROJECTNUMBER\/$NUMPROJECTS) >>> "

        echo "$PREFIX Entering $DIRLOC"
        pushd "$DIRLOC"
        if [[ -f .gitmodules ]]
        then
            echo "$PREFIX .gitmodules found, updating..."
            git submodule update --init --recursive
        fi
        echo "$PREFIX Building cabal-only..."
        checkCabal "$BASE" 2>&1 | sed "s/^/$PREFIX_SED: Cabal checking: /g"
        buildCabal "$BASE" 2>&1 | sed "s/^/$PREFIX_SED: Cabal: /g"
        testCabal "$BASE" 2>&1 | sed "s/^/$PREFIX_SED: Cabal testing: /g"
        popd
    done
    popd
    echo "Finished processing Nix projects in $CODEDIR"
done
popd
echo "Finished all"
