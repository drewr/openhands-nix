# openhands-nix

Nix flake packaging for [OpenHands](https://github.com/OpenHands/OpenHands-CLI)
— the CLI for the [OpenHands](https://openhands.dev) AI software development
agent by [All Hands AI](https://www.all-hands.ai).

This flake provides `openhands` and `openhands-acp` as Nix-reproducible
binaries, kept up to date with hourly automated releases. It does not modify
OpenHands in any way — it is purely packaging.

## What is OpenHands?

[OpenHands](https://openhands.dev) (by All Hands AI) is an open-source AI
agent that writes code, edits files, runs shell commands, and browses the web
to complete software engineering tasks. The CLI exposes it as a terminal UI and
as an [Agent Client Protocol (ACP)](https://agentclientprotocol.com) server,
making it usable from any ACP-compatible editor such as
[agent-shell](https://github.com/xenodium/agent-shell) for Emacs.

## Usage

### Run directly

```bash
# Terminal UI
nix run github:drewr/openhands-nix

# ACP server mode (for editor integration)
nix run github:drewr/openhands-nix#openhands -- acp
```

### Add to a flake

```nix
{
  inputs.openhands-nix.url = "github:drewr/openhands-nix";

  outputs = { nixpkgs, openhands-nix, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ openhands-nix.overlays.default ];
          environment.systemPackages = [ pkgs.openhands-cli ];
        })
      ];
    };
  };
}
```

## Local LLM setup

OpenHands works with any OpenAI-compatible API, including
[Ollama](https://ollama.com). Set these environment variables before running:

```bash
export LLM_BASE_URL=http://localhost:11434/v1
export LLM_MODEL=ollama/deepseek-coder-v2:16b   # or any ollama model tag
export LLM_API_KEY=ollama                        # any non-empty string

openhands-acp   # ACP server mode
openhands       # terminal UI
```

Both binaries are wrapped with `--override-with-envs` so the variables above
are picked up automatically.

## Emacs / agent-shell

With [agent-shell](https://github.com/xenodium/agent-shell) installed:

```elisp
(setq agent-shell-acp-agent-command '("openhands-acp"))
```

Then `M-x agent-shell` to start a session.

## Updating

`hashes.json` is updated hourly by CI. To update manually:

```bash
nix develop
bash update.sh
```

## Credits

All credit for OpenHands goes to [All Hands AI](https://www.all-hands.ai) and
the [OpenHands contributors](https://github.com/All-Hands-AI/OpenHands/graphs/contributors).
This repo contains only Nix packaging — no OpenHands source code is included or modified.

- OpenHands: https://openhands.dev
- OpenHands CLI: https://github.com/OpenHands/OpenHands-CLI
- OpenHands SDK: https://github.com/All-Hands-AI/OpenHands
