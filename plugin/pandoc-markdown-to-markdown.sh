#!/bin/sh
pandoc -f markdown -t markdown - "$@"
