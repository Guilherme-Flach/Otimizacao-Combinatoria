include("src/reader.jl")
include("src/instance.jl")
include("src/randomGreedy.jl")
include("src/localSearch.jl")

using Random

function main()
    # Variables to be extracted as command line params
    if (size(ARGS)[1] !== 3)
        println("Error reading args. Usage: `main.jl filepath iterations randomSeed`")
        return
    end

    filePath = ARGS[1]
    iterationsNum = parse(Int, ARGS[2])
    randomSeed = parse(Int, ARGS[3])


    Random.seed!(randomSeed)

    instance::Instance = reader(filePath)

    println("Number of prisioners: $(instance.n)")
    println("Number of restrictions: $(instance.m)")
    println("Restrictions:")
    display(instance.alliances)


    # Initialize a trivial valid solution (each prisioner in its own prision)
    function generateTrivialSolution()
        solution = Vector{Prision}()
        for i in 1:instance.n
            push!(solution, [i])
        end
        return Solution(solution, instance.n)
    end

    # GRASP it
    globalBest = generateTrivialSolution()
    for i = 1:iterationsNum
        initialSolution = randomGreedy(instance, 0.1)
        solution = localSearch(initialSolution, instance)
        if solution.value < globalBest.value
            globalBest = deepcopy(solution)
        end
    end

    println("\n\n")
    println("######### END #########")
    println("Solution is: $globalBest")
end

main()