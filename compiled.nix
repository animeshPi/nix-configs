let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  
  # Add the necessary dependencies and packages in this List.
  pythonldlibpath = lib.makeLibraryPath (with pkgs; [
    zlib
    zstd
    stdenv.cc.cc
    curl
    openssl
    attr
    libssh
    bzip2
    libxml2
    acl
    libsodium
    util-linux
    xz
    systemd
  ]);
  
  wrapPrefix = "LD_LIBRARY_PATH";
  
  patchedpython = pkgs.symlinkJoin {
    name = "python";
    paths = [ pkgs.python312 ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/python3.12" --prefix ${wrapPrefix} : "${pythonldlibpath}"
    '';
  };
  
in

pkgs.stdenv.mkDerivation {
  name = "custom-python-env";
  buildInputs = [ patchedpython ];

  shellHook = ''
    export PYTHONPATH=${patchedpython}/lib/python3.12/site-packages
    export LD_LIBRARY_PATH="${pythonldlibpath}"
  '';
}

