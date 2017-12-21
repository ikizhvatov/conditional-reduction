#!/bin/bash

echo "Converting the trs into daredevil split binary format..."
julia -e 'using Jlsca.Trs; trs2splitbin("wyseur2007_des_enc_3032343234363236.trs", 1, 8, true)'
mv data_UInt8_200t.bin wyseur2007_des_enc_3032343234363236.input
mv samples_UInt8_200t.bin wyseur2007_des_enc_3032343234363236.trace
