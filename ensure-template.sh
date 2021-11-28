#!/usr/bin/env bash
ENSURE_FILES=".hlint.yaml .stylish-haskell.yaml .gitignore .envrc"
ENSURE_DELETE=".hlint .stylish-haskell"
MODEL_DIR=/home/dwd/code/mine/haskell/compositions
STARTDIR=/home/dwd/code
CABALS=$(find -name *.cabal | grep -v contrib | grep -v compositions | grep -v dist-newstyle | grep -v result | grep -v external | grep -v reflex-platform | grep -v wasm-cross)
cd $STARTDIR
for CABAL in $CABALS
do
    DIR=$(dirname $CABAL)
    BASE=$(basename $DIR)
    cd $DIR
    echo -- $BASE
    for FILE in $ENSURE_FILES
    do
        if [ ! -f $FILE ]
        then
            echo "Need to create $FILE here"
            cp $MODEL_DIR/$FILE .
            git add $FILE
            git commit -m "Add $FILE"
            git push
        fi
        cmp $MODEL_DIR/$FILE $FILE
        RET=$?
        if [ $RET -ne 0 ]
        then
            echo $FILE is different than model file. Syncing.
            cp $MODEL_DIR/$FILE $FILE
            git add $FILE
            git commit -m "Sync $FILE"
            git push
        fi
    done
    for FILE in $ENSURE_DELETE
    do
        if [ -f $FILE ]
        then
            echo "Need to delete $FILE here"
            rm $FILE
            git add $FILE
            git commit -m "Delete $FILE"
            git push
        fi
    done
    cd $STARTDIR
done