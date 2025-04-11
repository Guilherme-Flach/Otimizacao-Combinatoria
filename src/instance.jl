
Prisioner = Int
Prision = Vector{Prisioner}
Solution = Vector{Prision}

# Struct representing an instance of the problem
struct Instance
    n::Int # prisioners
    m::Int # alliances
    # Alliance matrix (n x n)
    # alliances[i,j] == 1 represesents if an alliace exists between prisioners i and j
    alliances::Matrix{Prisioner}
end
