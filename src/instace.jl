# Struct representing anstance of the problem
struct Instance
    n :: Int # prisioners
    m :: Int # alliances
    # Alliance matrix (n x n)
    # alliances[i,j] == 1 represesents if an alliace exists between prisioners i and j
    alliances :: Matrix{Int}
end