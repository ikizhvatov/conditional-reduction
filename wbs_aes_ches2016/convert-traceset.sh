#!/bin/bash

echo "Converting the trs into daredevil split binary format..."
julia -e 'using Jlsca.Trs; trs2splitbin("ches2016_aes128_sb_ciph_dec1a551f1eddec0de4b1dae5c0de511.trs", 1, 16, true)'
mv data_UInt8_200t.bin ches2016_aes128_sb_ciph_dec1a551f1eddec0de4b1dae5c0de511.input
mv samples_UInt8_200t.bin ches2016_aes128_sb_ciph_dec1a551f1eddec0de4b1dae5c0de511.trace
