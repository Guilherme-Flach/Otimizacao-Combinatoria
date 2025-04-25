import Dates
include("src/reader.jl")
include("src/instance.jl")
include("src/randomGreedy.jl")
include("src/localSearch.jl")

using Random

function main()
    programStartTime = Dates.now()


    function displaySolution(solution::Solution, isFirstSolution=false)
        elapsedTime = convert(Dates.DateTime, Dates.now() - programStartTime)
        if (isFirstSolution)
            println("Generated first solution at $(Dates.format(elapsedTime, "MM:SS.sss")) with value $(solution.value):")
        else
            println("Found better solution at $(Dates.format(elapsedTime, "MM:SS.sss")) with value $(solution.value):")
        end
        # display(solution.prisionsStructure)
    end

    # Variables to be extracted as command line params
    if (size(ARGS)[1] <= 3)
        println("Error reading args. Usage: `main.jl filepath iterations randomSeed`")
        return
    end

    filePath = ARGS[1]
    iterationsNum = parse(Int, ARGS[2])
    randomSeed = parse(Int, ARGS[3])

    alpha = 0.15
    if (size(ARGS)[1] >= 4)
        alpha = parse(Float64, ARGS[4])
    end

    showRestrictions = false
    if (size(ARGS)[1] >= 5)
        showRestrictions = parse(Bool, ARGS[5])
    end


    Random.seed!(randomSeed)

    instance::Instance = reader(filePath)

    println("Number of prisioners: $(instance.n)")
    println("Number of restrictions: $(instance.m)")
    if (showRestrictions)
        println("Restrictions:")
        display(instance.alliances)
    end

    # Initialize a trivial valid solution (each prisioner in its own prision)
    function generateTrivialSolution()
        solution = Vector{Prision}()
        for i in 1:instance.n
            push!(solution, [i])
        end
        return Solution(solution, instance.n)
    end

    # GRASP it
    globalBest = randomGreedy(instance, 1.0) # Run a deterministic greedy for the base solution
    globalBest = localSearch(globalBest, instance)
    displaySolution(globalBest, true)
    for i = 1:iterationsNum
        println("GREEDY: $(@elapsed initialSolution = randomGreedy(instance, alpha))")
        println("LOCAL SEARCH: $(@elapsed solution = localSearch(initialSolution, instance))")
        println("######################")
        if solution.value < globalBest.value
            globalBest = deepcopy(solution)
            displaySolution(globalBest)
        end
    end

    println("\n")
    println("######### END #########")
    println("Finished in: $(Dates.format(convert(Dates.DateTime, Dates.now() - programStartTime), "MM:SS.sss"))")
    println("Solution is: $globalBest")
end

main()