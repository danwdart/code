with import <nixpkgs> {};
let gr-lte-src =
    builtins.fetchTarball "https://github.com/kit-cel/gr-lte/archive/refs/heads/master.tar.gz";
in stdenv.mkDerivation {
  src = gr-lte-src;
  name = "gr-lte";
  preConfigure = ''
    HOME=/tmp
  '';
  nativeBuildInputs = [
    cmake
    grc
  ];
  buildInputs = [
    boost
    cppunit
    doxygen
    faad2
    fftwFloat
    git
    gmp
    gnuradio3_8
    log4cpp
    pkgconfig
    libsndfile
    python39Packages.thrift
    spdlog
    thrift
    volk
  ];
}