with import <nixpkgs> {};
runCommand "ged2dot" {
    buildInputs = [
        python3
    ];
} ""
