#!/bin//bash

# execute daredevil on a given filename with a different number of traces
# saving all intermediate configs, output, and wall time

# configuration
CONFIG_TEMPLATE='daredevil.config.template.invmul' # the boilerplate with NUMTRACES placeholder
START=10 # nubmer of trace to start from
END=100 # max number of traces
STEP=10 # increment for the number of traces

# do the job
for ((n=START;n<=END;n+=STEP)); do
    echo "Running the beast for $n traces..."

    # generate config file for a given number of traces
    sed "s/NUMTRACES/$n/g" $CONFIG_TEMPLATE > daredevil.config.invmul.${n}traces

    # execute the beast
    (\time daredevil -c daredevil.config.invmul.${n}traces) 2>&1 | tee daredevil.log.invmul.${n}traces
done

# two extra points
sed "s/NUMTRACES/150/g" $CONFIG_TEMPLATE > daredevil.config.invmul.150traces
(\time daredevil -c daredevil.config.invmul.150traces) 2>&1 | tee daredevil.log.invmul.150traces
sed "s/NUMTRACES/200/g" $CONFIG_TEMPLATE > daredevil.config.invmul.200traces
(\time daredevil -c daredevil.config.invmul.200traces) 2>&1 | tee daredevil.log.invmul.200traces

echo "Done!"
