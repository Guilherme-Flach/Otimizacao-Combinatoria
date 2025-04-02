# Struct representing anstance of the problem
struct Instance
    n::Int # prisioners
    m::Int # alliances
    # Alliance ajacency list
    # alliances[p1] = {p2, p4} means p1 has an alliance with p2 and with p2
    alliances::Vector{Vector{Int}}
end