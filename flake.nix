{
  description = "Nix package for OpenHands-CLI — ACP-enabled coding agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      uv2nix,
      pyproject-nix,
      pyproject-build-systems,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        openhands-cli = pkgs.callPackage ./package.nix {
          inherit uv2nix pyproject-nix pyproject-build-systems;
        };
      in
      {
        packages = {
          default = openhands-cli;
          inherit openhands-cli;
        };

        apps = {
          default = {
            type = "app";
            program = "${openhands-cli}/bin/openhands";
          };
          acp = {
            type = "app";
            program = "${openhands-cli}/bin/openhands-acp";
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nix-prefetch-github
            jq
            curl
          ];
        };
      }
    )
    // {
      overlays.default = final: _prev: {
        openhands-cli = final.callPackage ./package.nix {
          inherit uv2nix pyproject-nix pyproject-build-systems;
        };
      };
    };
}
