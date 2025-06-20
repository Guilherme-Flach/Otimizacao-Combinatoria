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
    if (size(ARGS)[1] < 3)
        println("Error reading args. Usage: `main.jl filepath computationBudget randomSeed`")
        return
    end

    filePath = ARGS[1]
    computationBudget = parse(Int, ARGS[2])
    randomSeed = parse(Int, ARGS[3])

    alpha = 0.15
    if (size(ARGS)[1] >= 4)
        alpha = parse(Float64, ARGS[4])
    end

    showRestrictions = false
    if (size(ARGS)[1] >= 5)
        showRestrictions = parse(Bool, ARGS[5])
    end

    rev = false
    if (size(ARGS)[1] >= 6)
        rev = parse(Bool, ARGS[6])
    end

    Random.seed!(randomSeed)

    instance::Instance = reader(filePath)

    println("Number of prisioners: $(instance.n)")
    println("Number of restrictions: $(instance.m)")
    if (showRestrictions)
        println("Restrictions:")
        display(instance.alliances)
    end

    iterationsNum = Int32(floor(1000 * computationBudget / (instance.m * instance.n)))

    # GRASP it
    globalBest = randomGreedy(instance, 0.0, rev) # Run a deterministic greedy for the base solution
    globalBest = localSearch(globalBest, instance)

    println("Executing $(iterationsNum) iterations (consuming $(instance.m * instance.n) per iteration).")

    displaySolution(globalBest, true)
    for i = 1:iterationsNum
        # println("GREEDY: $(@elapsed initialSolution = randomGreedy(instance, alpha))")
        initialSolution = randomGreedy(instance, alpha, rev)
        # println("LOCAL SEARCH: $(@elapsed solution = localSearch(initialSolution, instance))")
        solution = localSearch(initialSolution, instance)
        # println("######################")

        if solution.value < globalBest.value
            globalBest = deepcopy(solution)
            displaySolution(globalBest)
        end
    end

    println("\n")
    println("######### END #########")
    println("Finished in: $(Dates.format(convert(Dates.DateTime, Dates.now() - programStartTime), "MM:SS.sss"))")
    println("Best solution value: ", globalBest.value)
end

main()