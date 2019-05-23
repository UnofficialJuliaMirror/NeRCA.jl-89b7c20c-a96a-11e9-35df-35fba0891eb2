"""
    function triggered(hits::Vector{T}) where {T<:Hit}

Return a `Vector` of triggered hits.
"""
triggered(hits::Vector{T}) where {T<:DAQHit} = filter(h->h.triggered, hits)


"""
    function nfoldhits(hits::Vector{T}, Δt, n) where {T<:Hit}

Create a `Vector` with hits contributing to `n`-fold coincidences within a time
window of Δt.
"""
function nfoldhits(hits::Vector{T}, Δt, n) where {T<:DAQHit}
    hit_map = DefaultDict{Integer}{Vector{T}}(() -> T[])
    for hit ∈ sort(hits)
        push!(hit_map[hit.dom_id], hit)
    end
    chits = Vector{T}()
    for (dom_id, dom_hits) ∈ hit_map
        bag = Vector{T}()
        push!(bag, dom_hits[1])
        t0 = dom_hits[1].time
        for hit in dom_hits[2:end]
            if hit.time - t0 > Δt
                if length(bag) >= n
                    append!(chits, bag)
                end
                bag = Vector{T}()
            end
            push!(bag, hit)
            t0 = hit.time
        end
    end
    return chits
end


"""
    function multiplicities(hits::Vector{T}, tmax=20) where {T<:AbstractHit}

Calculate the multiplicities for a given time window. Two arrays are
are returned, one contains the multiplicities, the second one the IDs
of the coincidence groups.
"""
function multiplicities(hits::Vector{T}, tmax=20) where {T<:AbstractHit}
    n = length(hits)
    mtp = ones(Int32, n)
    cid = zeros(Int32, n)
    idx0 = 1
    _mtp = 1
    _cid = idx0
    t0 = hits[idx0].t
    for i in 2:n
        Δt = hits[i].t - t0
        if Δt > tmax
            mtp[idx0:i] .= _mtp
            cid[idx0:i] .= _cid
            _mtp = 0
            _cid += 1
            idx0 = i
            t0 = hits[i].t
        end
        _mtp += 1
        if i == n - 1
            mtp[idx0:end] .= _mtp
            cid[idx0:end] .= _cid
            break
        end
    end
    mtp, cid
end


"""
    function domhits(hits::Vector{T}) where {T<:Hit}

Sort hits by DOM ID and put them into a dictionary.
"""
function domhits(hits::Vector{T}) where {T<:DAQHit}
    hit_map = DefaultDict{Integer}{Vector{T}}(() -> T[])
    for hit ∈ hits
        push!(hit_map[hit.dom_id], hit)
    end
    hit_map
end


"""
    function duhits(hits::Vector{T}) where {T<:CalibratedHit}

Sort hits by DU and put them into a dictionary.
"""
function duhits(hits::Vector{T}) where {T<:CalibratedHit}
    hit_map = DefaultDict{Integer}{Vector{T}}(() -> T[])
    for hit ∈ hits
        push!(hit_map[hit.du], hit)
    end
    hit_map
end


"""
    function totcut(hits::Vector{T}, tot) where {T<:DAQHit}

Return a vector of hits with ToT >= `tot`.
"""
function totcut(hits::Vector{T}, tot) where {T<:DAQHit}
    return filter(h->h.tot >= tot, hits)
end
