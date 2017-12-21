#!/bin//bash

# execute jlsca on a given filename with a different number of tracesets
# log output and wall time

# arg1 filename
# arg2 attacktype (KLEMSA, VANILLA, or INVMUL)
evo() {
	# configuration
	START=10 # nubmer of trace to start from
	END=100 # max number of traces
	STEP=10 # increment for the number of traces

	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	
	# do the job
	for ((n=START;n<=END;n+=STEP)); do
	    echo "Running the beauty for $n traces..."

	    # execute the beauty
	    (\time julia $DIR/main.jl $1 CONDRED $2 $n) 2>&1 | tee jlsca.$2.log.${n}traces
	done

	# two extra points
	(\time julia $DIR/main.jl $1 CONDRED $2 150) 2>&1 | tee jlsca.$2.log.150traces
	(\time julia $DIR/main.jl $1 CONDRED $2 200) 2>&1 | tee jlsca.$2.log.200traces

	echo "Done!"
}

# arg1 filename
# arg2 attacktype (KLEMSA, VANILLA, or INVMUL)
just200() {
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

	(\time julia $DIR/main.jl $1 CONDRED $2 200) 2>&1 | tee jlsca.$2.log.200traces

	echo "Done!"
}
