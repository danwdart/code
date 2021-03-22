#!/usr/bin/env nix-shell
#! nix-shell -p stylish-haskell hlint
set -e
INITDIR=~/code
cd $INITDIR
echo Finding Haskell projects...
for DIRLOC in ~/code/mine/haskell ~/code/mine/multi/projects/haskell
do
    echo Using repos location $DIRLOC
    cd $DIRLOC
    for STACKS in $(find $DIRLOC -name stack.yaml)
    do
        DIR=$(dirname $STACKS)
        BASE=$(basename $DIR)
        echo Updating $BASE...
        cd $DIR
        FILES=$(find -name *.hs | grep -v .stack-work | grep -v dist-newstyle)
        parallel --halt never hlint --refactor --refactor-options=-i ::: $FILES
        parallel --halt never stylish-haskell -i ::: $FILES
        echo Finished updating $BASE
        cd $INITDIR
    done
done
