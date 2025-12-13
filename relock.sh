#!/usr/bin/env nix-shell
#! nix-shell -p haskell.compiler.ghc912 cabal-install -i bash
set -euo pipefail
INITDIR=~/code
cd "$INITDIR"
echo Finding Haskell projects...
for DIRLOC in ~/code/mine/haskell ~/code/mine/multi/projects/haskell ~/code/contrib
do
    echo Using repos location "$DIRLOC"
    cd "$DIRLOC"
    for CABALS in $(find "$DIRLOC" -name "*.cabal" | \
        grep -v .stack-work | \
        grep -v jobfinder | \
        grep -v openfaas-examples | \
        grep -v slsdemo | \
        grep -v discord-webhook | \
        grep -v ffijs | \
        grep -v kmlfun | \
        grep -v "dist-*" | \
        grep -v onlybase | \
        grep -v onlycore | \
        grep -v js-backend | \
        grep -v reflex-platform)
    do
        DIR=$(dirname "$CABALS")
        BASE=$(basename "$DIR")
        echo Updating "$BASE"...
        pushd "$DIR"
        rm cabal.project.freeze || echo "nah"
        cabal v2-freeze
        echo Finished updating "$BASE"
        popd
    done
done
