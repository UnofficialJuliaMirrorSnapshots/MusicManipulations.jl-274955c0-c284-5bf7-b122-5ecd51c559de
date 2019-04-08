using Statistics

@testset "Velocity timeseries" begin

    # test object: onbeat notes with velocity ascending from 0 to 159
    notes = Notes{MoreVelNote}(Vector{MoreVelNote}(), 960)
    for i = 0:159
        push!(notes.notes, MoreVelNote(1, i, 960*i, 2))
    end

    #simple time series
    tvec, tseries = timeseries(notes, :velocity, maximum, 0:1)
    @test tvec == collect(0:960:159*960)
    @test tseries == collect(0:159)

    # time series for eights with zeros
    grid = 0:1//2:1
    tvec, tseries = timeseries(notes, :velocity, maximum, grid)

    @test tvec == collect(0:480:159*960+480)
    @test [tseries[i] for i in 1:2:159*2+1] == collect(Float64, 0:159)
    @test [tseries[i] for i in 2:2:159*2+2] == zeros(160)

    # add notes which have been quantized to same bin
    for i = 0:159
        push!(notes.notes, MoreVelNote(1, i+1, 960*i, 2))
    end
    sort!(notes.notes, lt=((x, y)->x.position<y.position))

    # simple time series choosing maximum in bin
    tvec, tseries = timeseries(notes, :velocity, maximum, 0:1)

    @test tvec == collect(Float64, 0:960:159*960)
    @test tseries == collect(Float64, 1:160)


    # simple time series choosing mean value in bin
    tvec, tseries = timeseries(notes, :velocity, mean, 0:1)

    @test tvec == collect(Float64, 0:960:159*960)
    @test tseries == collect(Float64, 1:160) .- 0.5

    # time series for eights with zeros and average for bins
    grid = 0:1//2:1
    tvec, tseries = timeseries(notes, :velocity, mean, grid)

    @test tvec == collect(Float64, 0:480:159*960+480)
    @test [tseries[i] for i in 1:2:159*2+1] == collect(Float64, 0:159) .+ 0.5
    @test [tseries[i] for i in 2:2:159*2+2] == zeros(Int,160)

end

@testset "Pitch timeseries" begin
    # test object: onbeat (quarter) notes with pitch ascending
    notes = Notes{Note}(Vector{Note}(), 960)
    vals = 10:20
    L = length(vals)
    for (i, val) in enumerate(vals)
        push!(notes.notes, Note(val, 5, 960*(i-1), 2))
    end

    #simple time series
    tvec, tseries = timeseries(notes, :pitch, maximum, 0:1)
    @test tvec == collect(0:960:(L-1)*960)
    @test tseries == collect(vals)


    # add notes which have been quantized to same bin
    for  (i, val) in enumerate(vals)
        push!(notes.notes, Note(5, 5, 960*(i-1), 2))
    end
    sort!(notes.notes, lt=((x, y)->x.position<y.position))

    # time series for eights with zeros and average for bins
    grid = 0:1//2:1
    tvec, tseries = timeseries(notes, :pitch, mean, grid)

    @test tvec == collect(0:480:(L)*960-480)
    @test [tseries[i] for i in 1:2:(L-1)*2+1] == (collect(Float64, vals) .+ 5)./2
    @test [tseries[i] for i in 2:2:(L-1)*2+2] == zeros(Int,L)
end
