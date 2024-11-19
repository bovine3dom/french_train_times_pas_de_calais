using CSV, TimeSeries, Plots, Dates, DataFrames

bethune = CSV.read("bethune", DataFrame)
tournai = CSV.read("tournai", DataFrame)

function window(df, window_size, probes)
    map(time -> begin
            (time=time, df=withinrange(df, (time-window_size):Second(1):(time+window_size-Second(1))))
    end, probes)
end

function withinrange(df, range)
    @view df[in.(df.time,Ref(range)), :]
end

bethune_per_hour = map(timetrains -> (time=timetrains.time, trains=size(timetrains.df,1)), window(bethune,Hour(1),Time(0):Minute(30):Time(23,59))) |> DataFrame
tournai_per_hour = map(timetrains -> (time=timetrains.time, trains=size(timetrains.df,1)), window(tournai,Hour(1),Time(0):Minute(30):Time(23,59))) |> DataFrame
plot(bethune_per_hour.time, bethune_per_hour.trains, label="Bethune, France", xticks=Time(0):Hour(2):Time(23,59), xrotation=45, margin=5*Plots.Measures.mm, legend=:bottomright, ylabel="Trains per hour")
plot!(tournai_per_hour.time, tournai_per_hour.trains, label="Tournai, Belgium")

# basically the same but about an hour less work
# could do it even quicker with ecdf probably
# stephist(bethune.time, nbins=30) 
# stephist!(tournai.time, nbins=30)
