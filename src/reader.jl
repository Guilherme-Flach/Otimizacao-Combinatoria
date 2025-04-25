include("instance.jl")

function reader(filepath::String)::Instance
    n = 0 # Prsioners
    m = 0 # Alliances
    alliances = zeros(Int, n, n)
    alliancesAdjacency = Vector{Set{Prisioner}}()

    open(filepath, "r") do f
        # First line is "n m"
        line = readline(f)
        n, m = parse.(Int, split(line))
        alliances = zeros(Int, n, n)

        for i = 1:n
            push!(alliancesAdjacency, Set{Prisioner}())
        end

        # The next m lines should just be restrictions in the format "prisoner1 prisioner2"
        for line in eachline(f)
            p1, p2 = parse.(Int, split(line))
            alliances[p1, p2] = 1
            alliances[p2, p1] = 1

            push!(alliancesAdjacency[p1], p2)
            push!(alliancesAdjacency[p2], p1)
        end
    end
    return Instance(n, m, alliances, alliancesAdjacency)
end