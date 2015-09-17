#!/bin/sh

FROMTYPE="$1"
TOTYPE="$2"
shift
shift

pandoc -f "$FROMTYPE" -t "$TOTYPE" - "$@"
