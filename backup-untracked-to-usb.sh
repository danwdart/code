#!/bin/sh

mkBackup7z() {
    echo "Finding ignored files..."

    FILES=$(git submodule foreach --recursive --quiet 'git ls-files -io --exclude-standard | \
        grep -v node_modules | \
        grep -v "dist-*" | \
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
        grep -v "dist-*" | \
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
}

mkBackup7zGpg() {
    [[ -f backup.7z ]] || mkBackup7z
    echo Encrypting backup...
    gpg -eobackup.7z.gpg -r 0240A2F45637C90C backup.7z
    rm backup.7z
}

mkGnupg7z() {
    7z a gnupg.7z ~/.gnupg >> backup.log 2>backup_error.log
}

mkGnupg7zGpg() {
    [[ -f gnupg.7z ]] || mkGnupg7z
    echo Encrypting keys...
    gpg -cognupg.7z.gpg gnupg.7z && rm gnupg.7z
}

[[ -f backup.7z.gpg ]] || mkBackup7zGpg
[[ -f gnupg.7z.gpg ]] || mkGnupg7zGpg

rsync -auvP backup.7z.gpg /run/media/dwd/Portable/ && rm backup.7z.gpg
rsync -auvP gnupg.7z.gpg /run/media/dwd/Portable/ && rm gnupg.7z.gpg