__precompile__()
module AutoDiffSource

export @δ, checkdiff

export δplus, δminus, δtimes, δdivide, δabs, δsum, δsqrt, δexp, δlog, δpower
export δdotplus, δdotminus, δdottimes, δdotdivide, δdotabs, δdotsqrt, δdotexp, δdotlog, δdotpower

include("parse.jl")
include("diff.jl")
include("func.jl")
include("checkdiff.jl")

end