with import <nixpkgs> {};
let gr-dvbs-src =
    builtins.fetchTarball "https://github.com/drmpeg/gr-dvbs/archive/refs/heads/master.tar.gz";
in stdenv.mkDerivation {
  src = gr-dvbs-src;
  name = "gr-dvbs";
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