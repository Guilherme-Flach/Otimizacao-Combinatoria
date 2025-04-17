
Prisioner = Int
Prision = Vector{Prisioner}
mutable struct Solution
    prisionsStructure::Vector{Prision}
    value::Int
end

# Struct representing an instance of the problem
struct Instance
    n::Int # prisioners
    m::Int # alliances
    # Alliance matrix (n x n)
    # alliances[i,j] == 1 represesents if an alliace exists between prisioners i and j
    alliances::Matrix{Prisioner}
end
