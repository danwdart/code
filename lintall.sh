#!/usr/bin/env nix-shell
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/master.tar.gz -p stylish-haskell hlint haskellPackages.apply-refact parallel -i bash
set -e
touch ~/.parallel/will-cite
# echo "will cite" | parallel --citation
INITDIR=~/code
cd $INITDIR
echo Finding Haskell projects...
for DIRLOC in ~/code/mine/haskell ~/code/mine/multi/projects/haskell
do
    echo Using repos location $DIRLOC
    cd $DIRLOC
    for CABALS in $(find $DIRLOC -name "*.cabal" | grep -v .stack-work | grep -v dist-newstyle | grep -v reflex-platform)
    do
        DIR=$(dirname $CABALS)
        BASE=$(basename $DIR)
        echo Updating $BASE...
        cd $DIR
        FILES=$(find -name "*.hs" | grep -v .stack-work | grep -v dist-newstyle | grep -v reflex-platform)
        echo Going to deal with $FILES
        echo Running hlint...
        parallel --halt never hlint --refactor --refactor-options=-i ::: $FILES || echo Failure running hlint
        echo Running stylish-haskell...
        parallel --halt never stylish-haskell -i ::: $FILES || echo Failure running stylish-haskell
        echo Finished updating $BASE
        cd $INITDIR
    done
done
