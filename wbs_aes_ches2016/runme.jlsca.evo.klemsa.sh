#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../jlsca-evolution.sh

evo $DIR/ches2016_aes128_sb_ciph_dec1a551f1eddec0de4b1dae5c0de511.trs KLEMSA
