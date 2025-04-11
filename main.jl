include("src/reader.jl")
include("src/instance.jl")
include("src/randomGreedy.jl")
include("src/localSearch.jl")

using Random

# Variables to be extracted as command line params
randomSeed = 7
filePath = "instances/01.txt"
iterationsNum = 100

Random.seed!(randomSeed)

instance::Instance = reader(filePath)

println("Number of prisioners: $(instance.n)")
println("Number of restrictions: $(instance.m)")
println("Restrictions:")
display(instance.alliances)


# Initialize a trivial valid solution (each prisioner in its own prision)
function generateTrivialSolution()
    solution = Solution()
    for i in 1:instance.n
        push!(solution, [i])
    end
    return solution
end

# GRASP it
globalBest = generateTrivialSolution()
for i = 1:1
    initialSolution = randomGreedy(instance, 1.0)
    solution = localSearch(initialSolution, instance)
    display(solution)
    if badEval(solution) < badEval(globalBest)
        global globalBest = deepcopy(solution)
    end
end

println("\n\n")
println("######### END #########")
println("Moves = $(badCheckPossibleMoves(globalBest, instance))")
println("Solution is: $globalBest")
println("With value: $(badEval(globalBest))")
