#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
cd "$(dirname "${BASH_SOURCE[0]}")"

for po in *.po; do
	msgfmt -c "$po" -o /dev/null
done
