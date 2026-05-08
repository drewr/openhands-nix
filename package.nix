{
  lib,
  fetchFromGitHub,
  python312,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
  ...
}:
let
  meta = lib.importJSON ./hashes.json;

  src = fetchFromGitHub {
    owner = "OpenHands";
    repo = "OpenHands-CLI";
    rev = meta.rev;
    hash = meta.hash;
  };

  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = src; };

  overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };

  pythonSet =
    (python312.pkgs.callPackage pyproject-nix.build.packages { }).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.wheel
          overlay
        ]
      );
in
pythonSet.mkVirtualEnv "openhands-cli" workspace.deps.default
