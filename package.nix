{
  lib,
  fetchFromGitHub,
  symlinkJoin,
  makeWrapper,
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
          # Legacy setup.py packages without pyproject.toml that need setuptools injected
          (final: prev:
            let
              addSetuptools = pkg: pkg.overrideAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.setuptools ];
              });
            in {
              pyperclip = addSetuptools prev.pyperclip;
              func-timeout = addSetuptools prev.func-timeout;
            })
        ]
      );
in
let
  virtualenv = pythonSet.mkVirtualEnv "openhands-cli" workspace.deps.default;
in
symlinkJoin {
  name = "openhands-cli";
  paths = [ virtualenv ];
  nativeBuildInputs = [ makeWrapper ];
  # The pyproject.toml defines openhands-acp = "openhands_cli.acp:main" but that
  # module was reorganised into openhands_cli.acp_impl; create a shim instead.
  postBuild = ''
    rm $out/bin/openhands-acp
    makeWrapper ${virtualenv}/bin/openhands $out/bin/openhands-acp \
      --add-flags acp
  '';
  meta = {
    description = "OpenHands CLI — ACP-enabled coding agent for local and cloud LLMs";
    homepage = "https://github.com/OpenHands/OpenHands-CLI";
    license = lib.licenses.mit;
    mainProgram = "openhands-acp";
  };
}
