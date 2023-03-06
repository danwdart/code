with import <nixpkgs> {};
let gr-dab-src =
    builtins.fetchTarball "https://github.com/andrmuel/gr-dab/archive/master.tar.gz";
in stdenv.mkDerivation {
  src = gr-dab-src;
  name = "gr-dab";
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