module CompassPlots

using Interpolations
using RecipesBase
using LaTeXStrings
using Parameters
using Measurements
using StaticArrays

# types
export SampledFunction
export LabeledSampledFunction
export Model
# aliases
export CompassData
export SampledAmplitude
# constructors
export compassdata
export sampledamplitude
export relativephase
export modelintensity
# methods
export selectxrange
export interpolation
export squaredAtimesPhaseSpace
export adjust
# utils
export argdeg
# 
include("structures.jl")


export TwoRanges
include("recipes.jl")

export argdeg
export merge_pdfs
include("utils.jl")

end # module
