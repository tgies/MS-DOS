#! /bin/bash

# Public Domain

[[ -z "$DOSEMU" ]] && DOSEMU=dosemu
"$DOSEMU" -dumb -td -kt < /dev/null -K "$PWD" -E "mak.bat"
