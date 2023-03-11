#!/bin/sh

echo "Finding ignored files..."

FILES=$(git submodule foreach --recursive --quiet 'git ls-files -io --exclude-standard | \
    grep -v node_modules | \
    grep -v dist-newstyle | \
    grep -v result | \
    grep -v .direnv | \
    grep -v hie.yaml | \
    grep -v \\.o$ | \
    grep -v \\.a$ | \
    grep -v \\.hi$ | \
    grep -v stan.html | \
    grep -v \\.fd$ | \
    grep -v _stub\\.h$ | \
    grep -v .hie | \
    grep -v log | \
    grep -v vendor | \
    grep -v gradle | \
    grep -v .eslintcache | \
    grep -v .next | \
    grep -v woocommerce | \
    grep -v external | \
    grep -v build | sed -e 's@^@\$displaypath/@'') || exit 1

echo "Finding skipped files..."

FILES_SKIPPED=$(git submodule foreach --recursive --quiet 'git ls-files -v | grep ^S | sed -e "s@^S\s@@g" | \
    grep -v node_modules | \
    grep -v dist-newstyle | \
    grep -v result | \
    grep -v .direnv | \
    grep -v hie.yaml | \
    grep -v \\.o$ | \
    grep -v \\.a$ | \
    grep -v \\.hi$ | \
    grep -v stan.html | \
    grep -v \\.fd$ | \
    grep -v _stub\\.h$ | \
    grep -v .hie | \
    grep -v log | \
    grep -v vendor | \
    grep -v gradle | \
    grep -v .eslintcache | \
    grep -v .next | \
    grep -v woocommerce | \
    grep -v external | \
    grep -v build | sed -e 's@^@\$displaypath/@'') || exit 1

IFS=$'\n'
for FILE in $FILES
do
    echo "Adding $FILE..."
    7z a backup.7z -- "$FILE" >> backup.log 2>backup_error.log
done

for FILE in $FILES_SKIPPED
do
    echo "Adding skipped $FILE..."
    7z a backup.7z -- "$FILE" >> backup.log 2>backup_error.log
done

echo Encrypting backup...

gpg -eobackup.7z.gpg -rdan@dandart.co.uk backup.7z