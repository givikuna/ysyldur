#!/usr/bin/env bash
set -euo pipefail

exec "${NIXTEST_BIN:?NIXTEST_BIN not set}" "$@"
