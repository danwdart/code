#!/usr/bin/env nix-shell
#! nix-shell -p haskell.packages.ghc98.stylish-haskell haskell.packages.ghc912.hlint haskell.packages.ghc912.apply-refact haskell.packages.ghc910.cabal-fmt statix shellcheck parallel -i bash
set -euo pipefail
mkdir -p ~/.parallel
touch ~/.parallel/will-cite
# echo "will cite" | parallel --citation
INITDIR=~/code
cd $INITDIR
echo > hints
echo Finding Nix projects...
for DIRLOC in ~/code/mine ~/code/contrib
do
    echo Using repos location "$DIRLOC"
    cd "$DIRLOC"
    for NIXES in $(find "$DIRLOC" -name "*.nix" | grep -v nixpkgs | grep -v "dist-*" | grep -v reflex-platform)
    do
        DIR=$(dirname "$NIXES")
        BASE=$(basename "$NIXES")
        echo Updating "$BASE"...
        pushd "$DIR"
        echo Running statix...
        statix fix
        popd
    done
done
echo Finding Bash projects...
for DIRLOC in ~/code/mine ~/code/contrib
do
    echo Using repos location "$DIRLOC"
    cd "$DIRLOC"
    for SHELLS in $(find "$DIRLOC" -name "*.sh" | grep -v nixpkgs | grep -v "dist-*" | grep -v reflex-platform | grep -v "gwallgofrwydd/src")
    do
        DIR=$(dirname "$SHELLS")
        BASE=$(basename "$SHELLS")
        echo Updating "$BASE"...
        pushd "$DIR"
        echo Running shellcheck...
        shellcheck -s bash -f diff *.sh | git apply || echo "ok so..."
        shellcheck -s bash *.sh || echo "ok so deal with it"
        popd
    done
done
echo Finding Haskell projects...
for DIRLOC in ~/code/mine/haskell ~/code/mine/multi/projects/haskell ~/code/contrib
do
    echo Using repos location "$DIRLOC"
    cd "$DIRLOC"
    for CABALS in $(find "$DIRLOC" -name "*.cabal" | grep -v .stack-work | grep -v "dist-*" | grep -v reflex-platform)
    do
        DIR=$(dirname "$CABALS")
        BASE=$(basename "$DIR")
        echo Updating "$BASE"...
        pushd "$DIR"
        FILES=$(find -name "*.hs" | grep -v .stack-work | grep -v "dist-*" | grep -v reflex-platform)
        echo Going to deal with $FILES
        echo Running hlint...
        parallel --halt never hlint --refactor --refactor-options=-i ::: $FILES || echo Failure running hlint
        echo "Here's what to do now..."
        echo $PWD >> $INITDIR/hints
        parallel --halt never hlint ::: $FILES >> $INITDIR/hints || echo Failure running hlint
        echo Running stylish-haskell...
        parallel --halt never stylish-haskell -i ::: $FILES || echo Failure running stylish-haskell
        echo Running cabal-fmt...
        cabal-fmt -i *.cabal
        echo Finished updating "$BASE"
        popd
    done
done
