

const uSL = Union{String, LaTeXString}

# SampledFunction
struct SampledFunction{T}
    xv::Vector{Float64}
    yv::Vector{T}
end
function selectxrange(sf::SampledFunction, r::Tuple)
    filt = r[1] .< sf.xv .< r[2]
    return SampledFunction(sf.xv[filt], sf.yv[filt])
end

# LabeledSampledFunction
struct LabeledSampledFunction{T}
    sf::SampledFunction{T}
    title::uSL
end
LabeledSampledFunction(xv,yv,title) = LabeledSampledFunction(SampledFunction(xv,yv),title)
selectxrange(lsf::LabeledSampledFunction, r::Tuple) = LabeledSampledFunction(selectxrange(lsf.sf, r), lsf.title)

SampledFunction(t::Matrix{Float64}) = SampledFunction{Float64}(t[:,1], t[:,2])
function interpolation(sf::SampledFunction)
    itp = interpolate((sf.xv,), sf.yv, Gridded(Linear()))
    return x-> sf.xv[1]<x<sf.xv[end] ? itp(x) : 0.0
end
# 
const CompassData = LabeledSampledFunction{Measurement{Float64}}
compassdata(t::Matrix, title::uSL) = LabeledSampledFunction(t[:,1], t[:,2] .± t[:,3], title)
# 
const SampledAmplitude = SampledFunction{Complex{Float64}}
sampledamplitude(t::Matrix{Float64}) = SampledFunction(t[:,1], t[:,2] + 1im .* t[:,3])
values(sa::SampledAmplitude) = sa.yv
#
function squaredAtimesPhaseSpace(a::SampledAmplitude, ph::SampledFunction)
    itp = interpolation(ph)
    yv = abs2.(a.yv) .* itp.(a.xv)
    return a.xv, yv
end
#
function relativephase(a1::SampledAmplitude, a2::SampledAmplitude)
    a1a2′ = values(a1) .* conj.(values(a2))
    SampledFunction(a1.xv, argdeg.(a1a2′))
end
#
adjust(x,y,x0=1.4,y0=110) = (x<x0 && y>y0) ? -360 : 0.0
adjust(sf::SampledFunction) = SampledFunction(sf.xv, sf.yv+adjust.(sf.xv, sf.yv))
adjust(lsf::LabeledSampledFunction) = LabeledSampledFunction(adjust(lsf.sf), lsf.title)
# 

@with_kw struct Model{N,T}
    components::SVector{N,SampledFunction{Complex{Float64}}}
    labels::SVector{N,T}
    phasespace::SampledFunction{Float64}
end
selectxrange(mc::Model, r) = Model(selectxrange.(mc.components, Ref(r)), mc.phasespace)
modelintensity(mc::Model, ind::Int) = LabeledSampledFunction(squaredAtimesPhaseSpace(mc.components[ind], mc.phasespace)..., mc.labels[ind])

