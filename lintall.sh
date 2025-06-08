#!/usr/bin/env nix-shell
#! nix-shell -p haskell.packages.ghc98.stylish-haskell haskell.packages.ghc98.hlint haskell.packages.ghc98.apply-refact haskell.packages.ghc912.cabal-fmt parallel -i bash
set -euo pipefail
mkdir -p ~/.parallel
touch ~/.parallel/will-cite
# echo "will cite" | parallel --citation
INITDIR=~/code
cd $INITDIR
echo > hints
echo Finding Haskell projects...
for DIRLOC in ~/code/mine/haskell ~/code/mine/multi/projects/haskell ~/code/contrib
do
    echo Using repos location $DIRLOC
    cd $DIRLOC
    for CABALS in $(find $DIRLOC -name "*.cabal" | grep -v .stack-work | grep -v "dist-*" | grep -v reflex-platform)
    do
        DIR=$(dirname $CABALS)
        BASE=$(basename $DIR)
        echo Updating $BASE...
        pushd $DIR
        # FILES=$(find -name "*.hs" | grep -v .stack-work | grep -v "dist-*" | grep -v reflex-platform)
        # echo Going to deal with $FILES
        # echo Running hlint...
        # parallel --halt never hlint --refactor --refactor-options=-i ::: $FILES || echo Failure running hlint
        # echo "Here's what to do now..."
        # echo $PWD >> $INITDIR/hints
        # parallel --halt never hlint ::: $FILES >> $INITDIR/hints || echo Failure running hlint
        # echo Running stylish-haskell...
        # parallel --halt never stylish-haskell -i ::: $FILES || echo Failure running stylish-haskell
        echo Running cabal-fmt...
        cabal-fmt -i *.cabal
        echo Finished updating $BASE
        popd
    done
done
