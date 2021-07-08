with import <nixpkgs> {};
runCommand "asm" {
    buildInputs = [
        nasm
        qemu
    ];
} ""
