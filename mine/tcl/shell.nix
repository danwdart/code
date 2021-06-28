with import <nixpkgs> {};
runCommand "tcl" {
    buildInputs = [
        tk
    ];
} ""
