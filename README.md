# Experiments with sample reduction for DCA

This is a repository with experimental data and scripts for https://eprint.iacr.org/2018/095, to reproduce experiments with sample reduction techniques for differential computation analysis of whitebox crypto implementations.

The tracesets were obtained from [Deadpool](https://github.com/SideChannelMarvels/Deadpool): some with the scripts provided there, some using customized Pin plugins (TBD).

## Setting up the environment 

The easiest way to run the experiments is the `marvelsplus` Docker image from [Orka](https://github.com/SideChannelMarvels/Orka).
The image incorporates this repository (as `conditional-reduction` folder) and provides the environment with all the necessary tools.

Alternatively, you can set up the environment manually.
You need to have Julia with [Jlsca](https://github.com/Riscure/Jlsca), and [Daredevil](https://github.com/SideChannelMarvels/Daredevil) on the path.
Instructions on how to install these tools are in their repositories.
Visualization of results for the case studies requires python with matplotlib and numpy.
For cloning this repo with the included tracesets you will need [Git-LFS](https://git-lfs.github.com).
Without Git-LFS, only pointers to the tracesets will be cloned.

##  Running the experiments

After cloning this repo, first unpack all the tracesets by running `unpack-all-tracesets.sh`.

### Obtaining figures for Table 2

In the subfolder with a particular implementation, execute the shell script with `just200` in the name. For instance:

    wbs_aes_ches2016 $ ./runme.jlsca.just200.invmul.sh

The script will print the log to the console and save it to a file. In the log, the lines staring with `Reduction` will show the number of samples left after different dimensionality reduction steps for every target function. For instance:

    Reduction for 1: 49913 left after global dup col removal, 49894 left after removing the inv dup cols, 105 left after sample reduction

### Obtaining plots for the case studies

For `wbs_aes_ches2016` and `wbs_des_wyseur2007`, scripts are provided to show the evolution of the metrics with the growing number of traces.

First, convert traces to the Daredevil split binary format:

    wbs_aes_ches2016 $ ./convert-traceset.sh

Subfolder `experiment-mbair` contains scripts and logs from our experiments on a MacBook Air. You can copy this folder to separate logs for your machine.

Go to the experimental subfolder and execute the following scripts to obtain results with Daredevil and Jlsca respectively.

    experiment-mbair$ ./daredevil-evolution-invmul.sh
    experiment-mbair$ ../runme.jlsca.evo.invmul.sh
    experiment-mbair$ ../runme.jlsca.evo.klemsa.sh

Logs will be printed to the console and saved to files. Some scripts will take considerable time to execute.

To visualize the results, do:

    experiment-mbair$ ./process-logs.py

The picture will be saved as `results.eps`.
