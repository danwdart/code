#!/usr/bin/env bash
set -e
CODEDIR=$PWD/mine
cd $CODEDIR
echo Finding dotenvrc projects...
for FILE in $(find $CODEDIR -name .envrc)
do
    echo $FILE
    DIRLOC=$(dirname $FILE)
    echo $DIRLOC
    cd $DIRLOC
    echo Allowing direnv...
    direnv allow
    direnv exec . echo "direnv set up."
done
cd $CODEDIR
