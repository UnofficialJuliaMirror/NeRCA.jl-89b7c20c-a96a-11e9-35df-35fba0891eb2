"""
    function mc_run_id(fname::AbstractString)

Generate a (unique) run ID for a given filename.
"""
function mc_run_id(fname::AbstractString)
    bname = basename(fname)
    if contains(bname, "_muatm")
        s = split(split(bname, "_muatm")[2], ".")[1]
        energy_cut, run = split(s, "T")
        return parse(Int, energy_cut) * 10000 + parse(Int, run)
    end
    if contains(bname, "_numuCC_")
        run = split(split(bname, "_numuCC_")[2], ".")[1]
        return parse(Int, run)
    end
    error("Don't know how to generate a proper run ID for '$bname'.")
end


"""
    function make_mc_time_converter(event_info::MCEventInfo)

Returns a function which converts MC time to JTE time.
"""
function make_mc_time_converter(event_info::MCEventInfo)
    function time_converter(time)
        return time - (event_info.timestamp * 1e9 + event_info.nanoseconds) + event_info.mc_time
    end
    return time_converter
end
