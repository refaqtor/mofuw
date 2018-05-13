#!/bin/sh

set -euo pipefail

trap 'echo setup script failed at line $LINENO' ERR

git clone https://github.com/2vg/mofuparser

git clone https://github.com/2vg/mofuhttputils

mv mofuparser/src/mofuparser.nim ./src/

mv mofuhttputils/src/mofuhttputils.nim ./src/