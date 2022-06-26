{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
    gomod2nix.url = "github:tweag/gomod2nix";
    protoc-gen-validate-src = {
      flake = false;
      url = github:envoyproxy/protoc-gen-validate;
    };
  };

  outputs =
    { self, nixpkgs, flake-utils, gomod2nix, protoc-gen-validate-src }:
    let
      overlays = [ gomod2nix.overlays.default ];
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
      in
      rec {
        packages = flake-utils.lib.flattenTree
        { 
          protoc-gen-validate = pkgs.buildGoApplication {
              name = "protoc-gen-validate";
              src = "${protoc-gen-validate-src}/";
              modules = ./gomod2nix.toml;
              subPackages = [ "." ];
          };
        };
        
        defaultPackage = packages.protoc-gen-validate;
        devShell =
          pkgs.mkShell {
            buildInputs = [ pkgs.gomod2nix ];
            packages = with pkgs; [
              go_1_17
            ];
          };

        apps.protoc-gen-validate = flake-utils.lib.mkApp { name = "protoc-gen-validate"; drv = packages.protoc-gen-validate; };
      });
}

