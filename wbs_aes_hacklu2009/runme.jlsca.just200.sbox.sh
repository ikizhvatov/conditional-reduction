#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../jlsca-evolution.sh

just200 $DIR/hacklu_aes128_sb_ciph_142bbe0e2d22e48097497d5fac5b5926.trs VANILLA
