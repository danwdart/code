#!/usr/bin/env nix-shell
#! nix-shell -p gnupg p7zip -i bash

while [[ ! -f mine/nix/system/common/private/users/dwd/hashed_password ]]
do
    while [[ ! -f backup.7z ]]
    do 
        if [[ ! -f backup.7z.gpg ]]
        then
            echo You need the file backup.7z.gpg.
            exit 2
        fi
    
        while [[ ! -f /home/dwd/.gnupg/private-keys-v1.d/834DA13B922ACE3AC17C5EF8D46F2243B0E5BC58.key ]]
        do        
            if [[ ! -f allkeys.gpg ]]
            then
                echo "allkeys.gpg not found. Checking for allkeys.gpg.gpg..."
    
                if [[ ! -f allkeys.gpg.gpg ]]
                then
                    echo "You'll need to get the allkeys.gpg.gpg file before continuing."
                    exit 2
                fi
    
                echo "Now please enter the password for allkeys.gpg.gpg from 2023"
    
                while [[ ! -f allkeys.gpg ]]
                do
                    gpg --pinentry-mode=loopback --decrypt-file allkeys.gpg.gpg
                done
    	    fi
            rm -f allkeys.gpg.gpg
    
            gpg --pinentry-mode=loopback --import allkeys.gpg
        done
        rm allkeys.gpg
    
        gpg --pinentry-mode=loopback --decrypt-file backup.7z.gpg
    done
    
    7z x backup.7z
done

rm -f backup.7z
echo "All done."
