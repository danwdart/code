with import <nixpkgs> {};
let
    gr-dab = import ./gr-dab.nix;
    # gr-dvbs = import ./gr-dvbs.nix;
    # gr-lte = import ./gr-lte.nix;
in
    runCommand "gnuradio" rec {
        shellHook = ''
        '';
        nativeBuildInputs = [
        ];
        buildInputs = [
            autoconf
            automake
            boost
            cmake
            cppunit
            gcc
            (gnuradio.override {
                extraPackages = [
                    gr-dab
                    # gr-dvbs
                    # gr-lte
                    hackrf
                ];
            })
            faad2
            libtool
            pkgconfig
            python3
        ];
    } ""
