{
  description = "Flake for Crystal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    utils.url = "github:kreisys/flake-utils";

    crystal-src = {
      url = "github:crystal-lang/crystal/1.4.1";
      flake = false;
    };

    crystal-i686-linux = {
      url =
        "https://github.com/crystal-lang/crystal/releases/download/1.4.1/crystal-1.4.1-1-linux-x86_64.tar.gz";
      flake = false;
    };

    crystal-x86_64-darwin = {
      url =
        "https://github.com/crystal-lang/crystal/releases/download/1.4.1/crystal-1.4.1-1-linux-x86_64.tar.gz";
      flake = false;
    };

    crystal-x86_64-linux = {
      url =
        "https://github.com/crystal-lang/crystal/releases/download/1.4.1/crystal-1.4.1-1-linux-x86_64.tar.gz";
      flake = false;
    };

    bdwgc-src = {
      url = "github:ivmai/bdwgc/v8.2.0";
      flake = false;
    };

    crystalline-src = {
      url = "github:elbywan/crystalline/v0.6.0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, ... }@inputs:
    utils.lib.simpleFlake {
      inherit nixpkgs;
      name = "crystal";

      overlay = final: prev:
        let
          crystalVersion = "1.4.1";
          crystallineVersion = "0.6.0";
          bdwgcVersion = "8.2.0";
          llvmPackages = prev.llvmPackages_11;
        in {
          bdwgc = prev.callPackage ./pkgs/bdwgc {
            src = inputs.bdwgc-src;
            version = bdwgcVersion;
          };

          crystal-bin = prev.callPackage ./pkgs/crystal/package-bin.nix {
            version = crystalVersion;
            src = inputs."crystal-${prev.system}";
          };

          crystal = final.callPackage ./pkgs/crystal {
            inherit llvmPackages;
            version = crystalVersion;
            src = inputs.crystal-src;
          };

          crystal-specs = final.callPackage ./pkgs/crystal {
            inherit llvmPackages;
            version = crystalVersion;
            src = inputs.crystal-src;
            doCheck = true;
          };

          crystalline = final.callPackage ./pkgs/crystalline {
            inherit llvmPackages;
            version = crystallineVersion;
            src = inputs.crystalline-src;
          };
        };

      # This actually becomes `legacyPackages`
      packages = { crystal, crystal-bin, crystalline, bdwgc }@pkgs:
        pkgs // {
          defaultPackage = crystal;
        };

      shell = ./shell.nix;
    };
}
