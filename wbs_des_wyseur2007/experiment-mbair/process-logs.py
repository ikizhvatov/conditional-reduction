#!/usr/bin/env python3

# Parse logs of daredevil and jlsca to extract and plot the evolution of:
# - timing
# - known key ranking
# - (for jlsca only) number of samples left after conditional reduction

import matplotlib.gridspec as gridspec
import matplotlib.pyplot as plt
import numpy as np
import re

# Parse Daredevil log, return a list of 16 ranks and the total runtime
def parseDaredevilLog(filename):

    keyByteRanks = []

    with open(filename) as f:
        while True:            
            # find the block of results
            line = f.readline()
            match = re.search(r'^Best \d.*#(\d*)\s.*sum', line)
            if not match:
                # see if we reached the end of the log
                end = re.search(r'\[INFO\] Total attack.*done in (.*) seconds', line)
                if end:
                    runtime = float(end.group(1))
                    #print('Total runtime: %.02f s' % runtime)
                    break
                else:
                    continue

            # we are at the start of the key byte block
            #print('Key byte %02d: ' % int(match.group(1)), end='')
            while True:
                line = f.readline()
                match = re.search(r'^(\d*):.*<==$', line.strip())
                if match:
                    rank = int(match.group(1))
                    keyByteRanks.append(rank)
                    #print('rank %d' % rank)
                    break
                if not line.strip():
                    keyByteRanks.append(None)
                    #print('rank >10')
                    break

    return keyByteRanks, runtime

# Parse Jlsca log, return a list of 16 ranks, the total runtime, and nubmer of remaining samples per key byte
def parseJlscaLog(filename):

    keyByteRanks = []
    numSamplesLeft = []

    with open(filename) as f:

        # parse number of points remaiing afer condred
        while True:
            line = f.readline()
            match = re.search(r'^Reduction for (\d*): (\d*) left.*removal, (\d*) left.*cols, (\d*) left', line)
            if match:
                bytenum = int(match.group(1))
                leftAfterDupRemoval = int(match.group(2))
                leftAfterInvDupRemoval = int(match.group(3))
                leftAfterCondRed = int(match.group(4))
                numSamplesLeft.append([leftAfterDupRemoval, leftAfterInvDupRemoval, leftAfterCondRed])
                if bytenum == 8:
                    break 

        # parse key ranks and total runtime
        # TODO: adapt for 2 phases
        while True:            
            # find the block of results
            line = f.readline()
            match = re.search(r'^target: (\d*)', line)
            if not match:
                # see if we reached the end of the log
                end = re.search(r'^knownkey match', line)
                if end:
                    line = f.readline()
                    time = re.search(r'^(.*) seconds', line)
                    runtime = float(time.group(1))
                    #print('Total runtime: %.02f s' % runtime)
                    break
                else:
                    continue

            # we are at the start of the key byte block
            #print('Key byte %02d: ' % int(match.group(1)), end='')
            while True:
                line = f.readline()
                match = re.search(r'(\d*), correct', line)
                if match:
                    rank = int(match.group(1))
                    keyByteRanks.append(rank)
                    #print('rank %d' % rank)
                    break

    return keyByteRanks, runtime, numSamplesLeft


if __name__ == '__main__':

    # define list of trace numbers
    traceRange = list(range(10,101,10))
    traceRange.append(150)
    traceRange.append(200)

    # all we need
    ranksDaredevil = []
    timesDaredevil = []
    ranksDaredevilDeadpool = []
    timesDaredevilDeadpool = []
    ranksJlsca = []
    timesJlsca = []
    samplesJlsca = []

    for n in traceRange:
        ranks, times = parseDaredevilLog('daredevil.log.%dtraces' % n)
        ranksDaredevil.append(ranks)
        timesDaredevil.append(times)
        ranks, times = parseDaredevilLog('daredevil.deadpool.log.%dtraces' % n)
        ranksDaredevilDeadpool.append(ranks)
        timesDaredevilDeadpool.append(times)
        ranks, times, samples = parseJlscaLog('jlsca.DESSBOX.log.%dtraces' % n)
        ranksJlsca.append(ranks)
        timesJlsca.append(times)
        samplesJlsca.append(samples)

    # convert
    samplesJlsca = np.array(samplesJlsca)
    ranksJlsca = np.array(ranksJlsca)

    # debug printout
    print(traceRange)
    print(ranksJlsca)
    print(timesJlsca)
    print(samplesJlsca)

    #############
    # The plotting
    
    # overall figure layout
    fig = plt.figure(figsize=(6, 7))
    gs = gridspec.GridSpec(4, 1, height_ratios=[2,1,2,2])
    axTime = plt.subplot(gs[0])
    axTimeZoom = plt.subplot(gs[1])
    axSamples = plt.subplot(gs[2])
    axRanks = plt.subplot(gs[3])
    #fig.suptitle('Wyseur2007 on dual-core laptop')

    # plot time
    axTime.plot(traceRange, timesDaredevil, label='Ddl')
    axTime.plot(traceRange, timesJlsca, label='Our tool')
    axTime.plot(traceRange, timesDaredevilDeadpool, label='Ddl presel.')
    axTime.set_ylim([0, 1000])
    axTime.set_xlim([0, 200])
    axTime.set_ylabel('Runtime, s')
    axTime.grid(b=True, which='both', color='0.75')
    axTime.tick_params(axis='x', which='both', top='off', bottom='off', labelbottom='off')
    axTime.legend()

    # plot zoomed time
    axTimeZoom.plot(traceRange, timesJlsca, color='tab:orange')
    axTimeZoom.plot(traceRange, timesDaredevilDeadpool, color='tab:green')
    axTimeZoom.set_ylim([0, 30])
    axTimeZoom.set_xlim([0, 200])
    axTimeZoom.set_ylabel('Runtime, s')
    axTimeZoom.grid(b=True, which='both', color='0.75')
    axTimeZoom.tick_params(axis='x', which='both', top='off', bottom='off', labelbottom='off')

    # plot cumulative number of samples left for Jlsca
    axSamples.plot(traceRange, np.sum(samplesJlsca[:,:,2], axis=1), color='tab:orange')
    # daredevil constant number but for reference (so far manually parsed)
    axSamples.plot(traceRange, [2548744*8] * len(traceRange), color = 'tab:blue')
    axSamples.plot(traceRange, [72080*8] * len(traceRange), color = 'tab:green')
    axSamples.set_xlim([0, 200])
    axSamples.set_ylabel('#samples (sum)')
    axSamples.set_yscale('log')
    axSamples.grid(b=True, which='both', color='0.75')
    axSamples.tick_params(axis='x', which='both', top='off', bottom='off', labelbottom='off')

    # plot key ranks
    axRanks.plot(traceRange, ranksDaredevil, color='tab:blue')
    axRanks.plot(traceRange, ranksDaredevilDeadpool, color='tab:green')
    axRanks.plot(traceRange, ranksJlsca[:,0:6], color='tab:orange')
    axRanks.set_ylim([0, 20])
    axRanks.set_xlim([0, 200])
    axRanks.set_ylabel('key byte rank')
    axRanks.set_xlabel('#traces')
    axRanks.grid(b=True, which='both', color='0.75')

    fig.tight_layout()
    plt.savefig('results.eps')
    #plt.show()
