# Experiments with sample reduction for differential computation analysis

This repository contains experimental data and scripts to reproduce experiments with sample reduction techniques for differential computation analysis of whitebox crypto implementations.

## Setting up the environment 

The easiest way to run the experiments is the 'marvelsplus' Docker image from https://github.com/ikizhvatov/Orka. The image includes this repository and provides environment with all the necessary tools.

Alternatively, you can set up the environment manually. You need to have Julia with [Jlsca](https://github.com/Riscure/Jlsca), and [Daredevil](https://github.com/SideChannelMarvels/Daredevil) on the path. For cloning this repo with the included tracesets you will need [Git-LFS](https://git-lfs.github.com). Without Git-LFS, only pointers to large datasets will be cloned.

##  Running the experiments

First, unpack all the tracesets by running the `unpack-all-tracesets.sh`.

To run the experiments, execute runme scripts in the subfolders. To be detailed.

##  More details 

Take a look at [this tutorial](https://github.com/ikizhvatov/jlsca-tutorials/blob/master/rhme2017-qual-wb.ipynb).