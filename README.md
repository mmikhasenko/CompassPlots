# CompassPlots
Collection of generic structures, method and recipes to plot compass data nicely.

Three main containers for the data are
 - `SampledFunction{T}` - array of x values (`xv`) and y-values (`yv`), the type is parametrized by the type of `y`.
 - `LabeledSampledFunction{T}` constains a sampled function (`sf`) and a label (`title`)
 - `Model{N,T}` contains `N` sampled amplitude (called `components`, `Complex{Float64}`), that are components of the amplitude, and sampled phase space (`phasespace`) as well as an array of labels (``).

Here is an example from the a1(1420) project of loading the data to the structures:
```julia
function load_data_and_model(folder, t′slice, modellabel)
    # data
    # intenisty
    dataI = compassdata(
        readdlm(joinpath("tgraphs",folder,"$(folder)_pssym_chi2sym_t$(t′slice)_graph_f0piP_data.dat")),
        L"\mathrm{Intensity\,\,of\,\,the\,\,}1^{++}0^{+}\,f_0\pi\,\,P\textrm{-}\mathrm{wave}"
    )
    # phase
    dataϕ = compassdata(
        readdlm(joinpath("tgraphs",folder,"$(folder)_pssym_chi2sym_t$(t′slice)_graph_rhopiS_f0piP_data.dat")),
        L"\mathrm{Interference\,\,of\,\,}1^{++}0^{+}\,(f_0\pi\,\,P-\rho\pi\,\,S)"
    )

    # model
    model_f0pi_bgd  = sampledamplitude(readdlm(joinpath("amp_values",folder,"$(folder)_pssym_chi2sym_amp_f0piP_t$(t′slice)_bgd")))
    model_f0pi_sig  = sampledamplitude(readdlm(joinpath("amp_values",folder,"$(folder)_pssym_chi2sym_amp_f0piP_t$(t′slice)_signal")))
    model_f0pi_sum  = sampledamplitude(readdlm(joinpath("amp_values",folder,"$(folder)_pssym_chi2sym_amp_f0piP_t$(t′slice)_sum")))
    # intensity components
    modelI = Model(;
        components = SVector(model_f0pi_bgd, model_f0pi_sig, model_f0pi_sum),
        labels = SVector("background", "signal", modellabel),
        phasespace = SampledFunction(readdlm(joinpath("triangle_superposition", "QTBPSf0.dat")))
    )

    # phase difference
    model_rhopi_sum = sampledamplitude(readdlm(joinpath("amp_values",folder,"$(folder)_pssym_chi2sym_amp_rhopiS_t$(t′slice)_sum")))
    modelϕ = LabeledSampledFunction(relativephase(model_f0pi_sum, model_rhopi_sum), modellabel)
    # 
    return (dataI = dataI, dataϕ = dataϕ,
            modelI = modelI, modelϕ = modelϕ)
end
```

The returned tuple contains data and the model wrapped in the convenient structures.
```julia
DandM_spin = load_data_and_model("spin", 1, "TS model")
DandM_bw   = load_data_and_model("bw",   1, "BW model")
```

Recipes allow to plot the structures directly. 
```julia
let tslicename = 1
    # settings
    tr = TwoRanges(full_range, fit_range)
    # dtr = TwoRanges((1.17, full_range[2]), fit_range)
    #
    @unpack dataI, modelI = DandM_spin
    # 
    p = intensityplot()
    # spin
    for (i,c) in Iterators.reverse(enumerate([:green, :blue, :red]))
        plot!(tr, selectxrange(modelintensity(modelI,i), full_range), lc=c)
    end
    # bw
    for (i,c) in Iterators.reverse(enumerate([:green, :blue, :red]))
        plot!(tr, modelintensity(DandM_bw.modelI,i); lc=c, ls=:dash, (i!=3 ? (lab="", ) : NamedTuple())...)
    end
    # data
    plot!(tr, dataI,  lab=L"\textrm{mass-ind.\,fit}")
    #
    ymax = max(extrema(modelintensity(DandM_spin.modelI,2).sf.yv)[2],
               extrema(modelintensity(DandM_spin.modelI,3).sf.yv)[2])
    plot!(ylim = (0, 1.17*ymax))
    # 
    annotate!(relative(p[1], 0.02, 0.98)...,
        text("COMPASS 2008\n"*tslicename, fontsize, :left,:top))
end
```
where function `relative` is used for the labels:
```julia
function relative(p::Plots.Subplot, rx, ry)
    xlims = Plots.xlims(p)
    ylims = Plots.ylims(p)
    return xlims[1] + rx * (xlims[2]-xlims[1]), ylims[1] + ry * (ylims[2] - ylims[1])
end
```
