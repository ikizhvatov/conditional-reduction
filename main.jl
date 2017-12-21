using Jlsca.Sca
using Jlsca.Trs
using Jlsca.Align
using Jlsca.Aes

import Jlsca.Sca.leak

type Klemsa <: Leakage
  multiplier::UInt8
end

leak(this::Klemsa, data::UInt8) = gf2dot(data, this.multiplier)

# Uses the leakage models defined by Jakub Klemsa in his MSc thesis (see
# docs/Jakub_Klemsa---Diploma_Thesis.pdf) to attack Dual AES implementations
# (see docs/dual aes.pdf)
function gf2dot(x::UInt8, y::UInt8)
  ret::UInt8 = 0

  for i in 0:7
    ret ⊻= ((x >> i) & 1) & ((y >> i) & 1)
  end

  return ret
end

@enum AttackMode KLEMSA=1 INVMUL=2 VANILLA=3 DESSBOX=4
@enum AnalysisMode CONDRED=1 INCCPA=2

function gofaster()
  if length(ARGS) < 1
    @printf("no input trace\n")
    return
  end

  filename = ARGS[1]
  analmode::AnalysisMode = CONDRED
  if length(ARGS) > 1 
    analmode = eval(parse(ARGS[2]))
  end

  attackmode::AttackMode = KLEMSA
  if length(ARGS) > 2 
    attackmode = eval(parse(ARGS[3]))
  end

  analysis::Analysis = CPA()
  if analmode == INCCPA
    analysis = IncrementalCPA()
  end

  maxNumberOfTraces = 200
  if length(ARGS) > 3
    maxNumberOfTraces = parse(ARGS[4])
  end

  maxColsPost = 5000
  if length(ARGS) > 4
    maxColsPost = parse(ARGS[5])
  end

  if contains(filename, "wyseur") || contains(filename, "sstic")
    params = getParameters(filename, BACKWARD)
    if attackmode == DESSBOX
      params.attack = DesSboxAttack()
      params.attack.direction = BACKWARD
    end
      
    params.analysis = analysis
    params.analysis.leakages = [Bit(i) for i in 0:3]
        
    # params.outputkka = @sprintf("%s.%s.%s", filename, string(string(params.targetType)), string(analmode))
    # condredstats = @sprintf("%s.%s.red.csv", filename, string(params.targetType))

  else
    if(contains(filename, "plaid"))
      params = getParameters(filename, BACKWARD)
      # params.mode = INVCIPHER
      # params.direction = BACKWARD
      params.dataOffset = 17
    else
      autoparam = getParameters(filename, FORWARD)
      if autoparam != nothing
        params = autoparam
      else
        params = DpaAttack(AesSboxAttack(),CPA())
        params.attack.keyLength = KL128
      end
    end

    params.analysis = analysis
    
    if attackmode == KLEMSA
      # the leakage function to attack dual AESes
      params.attack.sbox = map(Aes.gf8_inv, collect(UInt8, 0:255))
      params.attack.invsbox = Aes.myinv(params.attack.sbox)
      params.analysis.leakages = [Klemsa(UInt8(y)) for y in 1:255]
    elseif attackmode == INVMUL
      # to get what's called AES INVMUL SBOX in Daredevil
      params.attack.sbox = map(Aes.gf8_inv, collect(UInt8, 0:255))
      params.attack.invsbox = Aes.myinv(params.attack.sbox)
      params.analysis.leakages = [Bit(i) for i in 0:7]
    else
      params.analysis.leakages = [Bit(i) for i in 0:7]
    end

    params.targetOffsets = collect(1:16)

    # params.outputkka = @sprintf("%s.%s.%s", filename, string(attackmode), string(analmode))
    # condredstats = @sprintf("%s.red.csv", filename)
  end

  # params.updateInterval = 10
  params.maxCols = 20000000
  params.maxColsPost = maxColsPost

  toBitsEfficient = true
  trs = InspectorTrace(filename, toBitsEfficient)
  addSamplePass(trs, tobits)

  if analmode == CONDRED
    setPostProcessor(trs, CondReduce())

    numberOfTraces = min(maxNumberOfTraces, length(trs))

    rankData = sca(trs, params, 1, numberOfTraces)
  elseif analmode == INCCPA
      state = BitCompress(length(trs[1][2]))
      for idx in 1:length(trs)
        bitcompress(state, trs[idx][2])
      end
      mask = toMask(state)

      @printf("Reduced to %d bits per row\n", countnz(mask))

      toBitsEfficient = true
      trs = InspectorTrace(filename, toBitsEfficient)
      addSamplePass(trs, tobits)

      addSamplePass(trs, x -> x[$mask])

      setPostProcessor(trs, IncrementalCorrelation())

      numberOfTraces = min(maxNumberOfTraces, length(trs))

      rankData = sca(trs, params, 1, numberOfTraces)
  end

  # for phase in getPhases(rankData)
  #   targets = getTargets(rankData,phase)
  #   print("#traces,#total cols,")
  #   for target in targets
  #     print("#reduced cols target $target")
  #     if target == targets[end]
  #       print("\n")
  #     else
  #       print(",")
  #     end
  #   end
  #   nrConsumedRows = getNrConsumedRowsEvolution(rankData, phase)
  #   nrConsumedCols = getNrConsumedColsEvolution(rankData, phase)
  #   for interval in getIntervals(rankData)
  #     print("$(nrConsumedRows[interval]),$(nrConsumedCols[interval]),")
  #     for target in targets
  #       nrCols = getNrColsEvolution(rankData,phase,target)
  #       print("$(nrCols[interval])")
  #       if target == targets[end]
  #         print("\n")
  #       else
  #         print(",")
  #       end
  #     end
  #   end
  # end
 
end

@time gofaster()
