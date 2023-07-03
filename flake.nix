{
  description = "A flake for building libsbml for Flint";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;

  inputs.libsbml = {
    url = github:sbmlteam/libsbml/186f62fc34f5836cff0ed162aa5e8b880f22fcb1;
    flake = false;
  };

  outputs = { self, nixpkgs, libsbml }: let

    allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f (import nixpkgs { inherit system; }));

  in {

    packages = forAllSystems (pkgs: with pkgs; let

      flint-libsbml = stdenv.mkDerivation {
        pname = "flint-libsbml";
        version = "3.4.1";

        nativeBuildInputs = [ pkg-config ];

        buildInputs = [ libxml2 ];

        checkInputs = [ check ];

        src = libsbml;

        patches = [ ./makefile-common-vars.patch ];

        configureFlags = [
          "--disable-compression"
          "--without-bzip2"
          "--without-zlib"
        ];

        postInstall = lib.optionalString stdenv.isDarwin ''
          install_name_tool -id $out/lib/libsbml.3.4.1.dylib $out/lib/libsbml.3.4.1.dylib
        '';

        # doCheck = true;
      };

    in {

      default = flint-libsbml;

    });
  };
}
