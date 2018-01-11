#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../jlsca-evolution.sh

just200 $DIR/sstic2012_bits_1000_1824_des_enc_fd4185ff66a94afd.trs DESSBOX
