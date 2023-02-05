Grand list of overrides excluding other86, jobfinder, tumblr-editor and consolefrp for now

41

# https://github.com/AndrewRademacher/aeson-casing/issues/7
aeson-casing = lib.dontCheck super.aeson-casing;
# ghc-exactprint: base >=4.8 && <4.16, ghc >=7.10.2 && <9.2
apply-refact = ghc92.apply-refact;
brick = lib.doJailbreak super.brick;
clay = lib.doJailbreak super.clay;
# Don't know why I need a doJailbreak in here, the version restriction of base
# looks up-to-date in the repository.
# https://github.com/stackbuilders/datetime/pull/13
datetime = lib.doJailbreak (self.callCabal2nix "datetime" (builtins.fetchGit {
    url = "https://github.com/l29ah/datetime.git";
    ref = "time-1.11";
}) {});
digits = (self.callHackage "digits" "0.3.1" {}).overrideDerivation (self: {
    prePatch = ''
        echo -e "> import Distribution.Simple\n> main = defaultMain" > Setup.lhs
    '';
});,
discord-haskell = lib.doJailbreak (self.callHackage "discord-haskell" "1.15.3" {});
# https://github.com/kowainik/extensions/issues/74
extensions = lib.doJailbreak (self.callCabal2nix "extensions" (builtins.fetchGit {
    url = "https://github.com/tomjaguarpaw/extensions.git";
    ref = "9.4";
    rev = "6748ccbcea0d06488b6e288e9b68233fe4d73eb7";
}) {});
# base >=4 && <4.17, time <1.12
feed = lib.doJailbreak super.feed;
# template-haskell >=2.11 && <2.19
freer-simple = lib.doJailbreak super.freer-simple;
fsutils = self.callCabal2nix "fsutils" (builtins.fetchGit {
    url = "https://github.com/danwdart/fsutils.git";
    rev = "e5f97a067955afffc8d120249488f9b59c38a24a";
}) {};
# not yet uploaded to hackage
gedcom = lib.doJailbreak (self.callCabal2nix "gedcom" (nixpkgs.fetchFromGitHub {
    owner = "CLowcay";
    repo = "hs-gedcom";
    rev = "148acdf9664d234d9ec67121448b92d786aa4461";
    sha256 = "1v02a9w678zmqa09513j24pkqjva5l3qik9qlyhw4px8fqddnaai";
}) {});
ghcid = (ghc.override {
    overrides = self: super: rec {
        # not in nix yet
        hspec-contrib = self.callHackage "hspec-contrib" "0.5.1.1" {};
    };
}).ghcid;
gloss = lib.doJailbreak super.gloss;
gloss-rendering = lib.doJailbreak super.gloss-rendering;
haskell-debug-adapter = (ghc.override {
    overrides = self: super: rec {
        # not in nix yet
        hspec-contrib = self.callHackage "hspec-contrib" "0.5.1.1" {};
    };
}).haskell-debug-adapter;
haskell-docs-cli = self.callCabal2nix "haskell-docs-cli" (builtins.fetchGit {
    url = "https://github.com/lazamar/haskell-docs-cli.git";
    rev = "6c40bd41f0f6be5f06afae2836c42710dc05cd87";
}) {};
# text >=0.11 && <1.3
hasktags                    = ghc92.hasktags;
hgettext = lib.markUnbroken super.hgettext;
# https://github.com/haskell-hint/hint/issues/151
hint = lib.dontCheck (self.callCabal2nix "hint" (nixpkgs.fetchFromGitHub {
    owner = "haskell-hint";
    repo = "hint";
    # ref
    rev = "b2bc76a748819713df534e6e3c376dbe27cc60ce";
    sha256 = "JwPHBNox1EUrT0nOanqA1ge1VbZ5bCIAcFGvJ8UBvVA=";
}) {});
# ghc-lib-parser >=9.0 && <9.1, ghc-lib-parser-ex >=9.0.0.4 && <9.0.1
hlint                       = ghc92.hlint;
# 2.1.0: aeson >=1.5 && <2.1
hslua-aeson = lib.doJailbreak super.hslua-aeson;
# not in nix yet
hspec-contrib = self.callHackage "hspec-contrib" "0.5.1.1" {};
humblr = self.callCabal2nix "humblr" (builtins.fetchGit {
    url = "https://github.com/danwdart/humblr.git";
    rev = "22b065ead87cb1c3c19545c54f8ff90fb1e314e9";
}) {};
# Don't know why doJailbreak does nothing here?
# https://github.com/chrra/iCalendar/pull/46
iCalendar = lib.doJailbreak (self.callCabal2nix "iCalendar" (builtins.fetchGit {
    url = "https://github.com/markus1189/iCalendar.git";
    ref = "update-bounds";
}) {});
ilist = lib.doJailbreak super.ilist;
# for 9.2.4 so far not 9.4.2?
inline-asm = lib.markUnbroken super.inline-asm;
krank                       = (ghc.override {
    overrides = self: super: rec {
    # not released yet
    PyF = self.callHackage "PyF" "0.11.1.0" {};
    # not released yet
    req = self.callHackage "req" "3.13.0" {};
    };
# updates to fix made since 0.2.3: https://github.com/guibou/krank/issues/94
}).callCabal2nix "krank" (builtins.fetchGit {
    url = "https://github.com/guibou/krank.git";
    rev = "dd799efa1f2d1fac4ce0f80c4f47731b32e6fcaf";
}) {};
OpenGLRaw = lib.doJailbreak super.OpenGLRaw;
# 2.17.1.1: aeson >=0.7 && <2.1
pandoc = lib.doJailbreak super.pandoc;
# not released yet
PyF = self.callHackage "PyF" "0.11.1.0" {};
# not released to nix yet
req = self.callHackage "req" "3.13.0" {};
sdl2 = lib.doJailbreak super.sdl2;
slist = lib.doJailbreak super.slist;
# also: https://github.com/kowainik/slist/issues/55
stan                        = lib.dontCheck ((ghc92.override {
    overrides = self: super: rec {
    # https://github.com/kowainik/extensions/issues/74
    extensions = lib.doJailbreak (self.callCabal2nix "extensions" (builtins.fetchGit {
        url = "https://github.com/tomjaguarpaw/extensions.git";
        ref = "9.4";
        rev = "6748ccbcea0d06488b6e288e9b68233fe4d73eb7";
    }) {});
    # https://github.com/kowainik/trial/issues/67
    trial-tomland = lib.doJailbreak (lib.markUnbroken super.trial-tomland);
    clay = lib.doJailbreak super.clay;
    slist = lib.doJailbreak super.slist;
    # relude 1.0.0.1: Module ‘Data.Semigroup’ does not export ‘Option(..)’ if using ghc92
    # relude = lib.doJailbreak (self.callHackage "relude" "1.1.0.0" {});
    };
# https://github.com/kowainik/stan/issues/423
}).callCabal2nix "stan" (builtins.fetchGit {
    url = "https://github.com/tomjaguarpaw/stan.git";
    ref = "9.4-compat";
    rev = "70c14718486f399c11209580d4762b73499cd0e3";
}) {});
# 0.0.4: text >=1.2 && <1.3
string-qq = lib.doJailbreak super.string-qq;
# ghc-lib-parser: base >=4.14 && <4.17, ghc-prim >0.2 && <0.9, time >=1.4 && <1.12
stylish-haskell = ghc92.stylish-haskell;
text-display = lib.doJailbreak (lib.markUnbroken super.text-display);
# https://github.com/kowainik/trial/issues/67
trial-tomland = lib.doJailbreak (lib.markUnbroken super.trial-tomland);
# nixpkgs only has 5.33
vty = lib.doJailbreak (self.callHackage "vty" "5.37" {});

# dhall 1.40.2: aeson >=1.0.0.0 && <2.1, template-haskell >=2.13.0.0 && <2.19
weeder                      = ghc92.weeder;