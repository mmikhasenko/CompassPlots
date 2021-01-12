

@recipe function f(intensity::CompassData; fontsize=8)
    dx = (intensity.sf.xv[2]-intensity.sf.xv[1])/4
    # 
    seriestype --> :scatter
    xerror := dx
    markersize --> 1.3
    markerstrokewidth --> 0.6
    title --> intensity.title
    titlefontsize := fontsize+1
    markercolor --> :black
    markerstrokecolor --> :black
    #
    if haskey(plotattributes, :label)
        @series begin
            seriestype := :scatter
            label := L"\textrm{mass-ind.\,fit}"
            markersize := 4
            markershape := :+
            ([-1e3], [0.0])
        end
    end
    label := ""
    # 
    (intensity.sf.xv, map(y->iszero(y) ? NaN ± NaN : y, intensity.sf.yv))
end

@recipe function f(sf::SampledFunction)
    (sf.xv, sf.yv)
end
@recipe function f(intensity::LabeledSampledFunction{Float64}; fontsize=8)
    label --> intensity.title
    titlefontsize := fontsize+1
    # 
    (intensity.sf,)
end
#

# canva settings
@userplot SpinDensityElementPlot
@userplot IntensityPlot
@userplot PhaseDifferencePlot

@recipe function f(obj::SpinDensityElementPlot; fontsize=8)
    size --> (320,305)
    xguide --> L"m_{3\pi}\,(\mathrm{GeV}/c^2)"
    legendfontsize --> fontsize
    guidefontsize --> fontsize
    xlims --> (1.1,2.0)
    framestyle --> :box
    label --> ""
    ()
end
@recipe function f(obj::IntensityPlot; fontsize=8)
    yguide --> L"\textrm{Number of events}/(20\,\mathrm{MeV}/c^2)"
    legend --> :topright
    # ylims --> (-60,3450)
    (SpinDensityElementPlot([]), )
end
@recipe function f(obj::PhaseDifferencePlot; fontsize=8)
    yguide --> "Relative phase (deg)"
    legend --> :bottomright
    ylims --> (-250,190)
    (SpinDensityElementPlot([]), )
end

# gray full range
struct TwoRanges
    rWide::Tuple
    rNarrow::Tuple
end

@recipe function f(ranges::TwoRanges, obj::LabeledSampledFunction{Float64})
    @unpack rWide, rNarrow = ranges
    dx = 0.01
    @series begin
        label := ""
        linealpha := 0.5
        (selectxrange(obj,(rWide[1],rNarrow[1]+dx)), )
    end
    @series begin
        label := ""
        linealpha := 0.5
        (selectxrange(obj,(rNarrow[2]-dx, rWide[2])), )
    end
    (selectxrange(obj,rNarrow), )
end

@recipe function f(ranges::TwoRanges, obj::LabeledSampledFunction{Measurement{Float64}})
    @unpack rWide, rNarrow = ranges
    @series begin
        delete!(plotattributes, :label)
        markercolor := :gray
        markerstrokecolor := :gray
        (selectxrange(obj,(rWide[1],rNarrow[1])), )
    end
    @series begin
        delete!(plotattributes, :label)
        markercolor := :gray
        markerstrokecolor := :gray
        (selectxrange(obj,(rNarrow[2], rWide[2])), )
    end
    (selectxrange(obj,rNarrow), )
end
