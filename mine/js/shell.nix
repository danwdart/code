with import <nixpkgs> {};
runCommand "js" {
    buildInputs = [
        nodejs
        nodePackages.npm # version with node is too old
        nodePackages.npm-check-updates
        python312 # for npm stuff
        yarn # haven't decided yet
    ];
} ""
