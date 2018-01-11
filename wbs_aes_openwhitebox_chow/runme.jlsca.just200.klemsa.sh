#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../jlsca-evolution.sh

just200 $DIR/chow_aes128_sb_ciph_693bb79cd7742262c969595c4f8d895f.trs KLEMSA
