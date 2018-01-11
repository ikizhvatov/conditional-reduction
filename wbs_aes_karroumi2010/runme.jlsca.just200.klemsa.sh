#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../jlsca-evolution.sh

just200 $DIR/karroumi2010_aes128_sb_ciph_2b7e151628aed2a6abf7158809cf4f3c.trs KLEMSA
