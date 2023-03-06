with import <nixpkgs> {};
runCommand "sandsifter" {
    buildInputs = [
        gcc
        python310
        python310Packages.capstone
        capstone
    ];
} ""
