# 8. macOS setup from scratch

This fork's `mac-port` branch runs PS5 Agent Remote on macOS. The upstream
release only ships a Windows `ps5bridge.dll`, so on a Mac you build the native
library yourself. The build uses Apple clang and takes a few minutes.

## Requirements

- macOS with the Xcode Command Line Tools: `xcode-select --install`
- Python 3.12 (`brew install python@3.12` or python.org) and git
- A PS5 on the same network **and the same subnet** as the Mac. PS5 discovery
  is broadcast-only, so a Mac on a different subnet of a large Wi-Fi network
  will not find the console. Rejoin Wi-Fi until the Mac's address matches.

## 1. Get the code and the Python environment

```sh
git clone --branch mac-port https://github.com/ShashwatM3/ps5-agent-remote.git
cd ps5-agent-remote
python3.12 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

## 2. Build the native library

```sh
git clone --depth 1 --branch v1.10.0 --recurse-submodules --shallow-submodules https://github.com/streetpea/chiaki-ng.git vendor/chiaki-ng-src
python3.12 -m venv .buildenv
.buildenv/bin/pip install "protobuf>=4,<6" grpcio-tools requests
.buildenv/bin/python tools/build_native.py
```

This writes `native/libps5bridge.dylib` (about 1 MB). The library links only
macOS system frameworks, so the build folders are not needed at runtime. To
reclaim about 750 MB afterwards:

```sh
rm -rf vendor .buildenv native/build
```

## 3. Start, sign in and link

```sh
./start.sh
```

The browser opens `http://127.0.0.1:8765`. Paste your PSN NPSSO token, then
type the 8-digit PIN from the PS5 (see [02 PS5 setup](02-ps5-setup.md)). The
token is saved to `.env.local` in the project folder, and the console link keys
go to `~/.ps5-remote/consoles.json`. To skip discovery, set the console's IP:
`PS5_HOST=<ip> ./start.sh`.

## 4. Connect Claude Code

```sh
.venv/bin/python tools/connect_agents.py claude --apply
```

This registers the `ps5` MCP server at user scope, pointing at this folder's
`.venv/bin/python` and `mcp_server.py`. If you move the folder, run it again.
