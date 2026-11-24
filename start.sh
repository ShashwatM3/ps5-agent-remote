#!/bin/sh
# macOS/Linux launcher for PS5 Agent Remote. Ctrl+C stops it.
cd "$(dirname "$0")"
[ -x .venv/bin/python ] || { echo "Not installed yet. Run: python3.12 -m venv .venv && .venv/bin/pip install -r requirements.txt"; exit 1; }
ls native/libps5bridge.* >/dev/null 2>&1 || { echo "Native library missing. Build it: .buildenv/bin/python tools/build_native.py"; exit 1; }
( sleep 2; open http://127.0.0.1:8765 2>/dev/null ) &
if command -v varlock >/dev/null 2>&1; then exec varlock run -- .venv/bin/python server.py; else exec .venv/bin/python server.py; fi
