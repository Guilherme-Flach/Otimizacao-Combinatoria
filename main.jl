# include("src/reader.jl")
include("src/reader.jl")
include("src/instance.jl")

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


# WIP stuff used for testing
initialSolution = Vector{Vector{Int}}()

# Initialize a trivial valid solution (each prisioner in its own prision)
for i in 1:instance.n
    push!(initialSolution, [i])
end

println(initialSolution)

# This simply counts the amount of prisions with 0 prisioners
function badEval(solution::Vector{Vector{Int}})
    return size(solution)[1] - count(i -> (i[1] == 0), size.(solution))
end

function canMoveTo(prisioner::Int, prision::Vector{Int}, restrictions)
    for inmate in prision
        if inmate == prisioner
            return false
        end
        if restrictions[inmate, prisioner] == 1
            return false
        end
    end
    return true
end

badEval(initialSolution)

# No differential evanl, just check them all
function badCheckPossibleMoves(solution::Vector{Vector{Int}}, instance::Instance)
    possibleMoves = Vector{Vector{Int}}()
    for i = 1:instance.n
        push!(possibleMoves, [])

        for (prisionIndex, prision) in enumerate(solution)
            if canMoveTo(i, prision, instance.alliances)
                push!(possibleMoves[i], prisionIndex)
            end
        end
    end

    return possibleMoves
end

function movePrisioner(originPrision, newPrision, prisioner)
    deleteat!(originPrision, originPrision .== prisioner)
    push!(newPrision, prisioner)
end


globalBest = deepcopy(initialSolution)
currentSolution = initialSolution
shouldStop = false

for iteration in 1:10
    shouldStop = false
    possibleMoves = badCheckPossibleMoves(currentSolution, instance)

    newSolution = deepcopy(currentSolution)

    println("--------------------")
    println("Iteration: $iteration")
    println("Current Solution: $currentSolution")

    # Iterate over prisioners and try to move them somewhere else
    for (prisionIndex, prision) in enumerate(currentSolution)
        for prisioner in prision
            # Try to move him to another prision
            for newPrisionIndex in shuffle(possibleMoves[prisioner])

                originPrision = newSolution[prisionIndex]
                newPrision = newSolution[newPrisionIndex]

                movePrisioner(originPrision, newPrision, prisioner)

                # If it makes a worse solution, undo the stuff
                if (badEval(newSolution) > badEval(currentSolution))
                    movePrisioner(newPrision, originPrision, prisioner)
                else
                    # Otherwise keep it with first improvement
                    if (badEval(newSolution) <= badEval(globalBest))
                        global globalBest = deepcopy(newSolution)
                        global currentSolution = deepcopy(newSolution)
                    end
                    shouldStop = true
                    break
                end

            end
            if (shouldStop)
                break
            end
        end
        if (shouldStop)
            break
        end
    end

end

println("\n\n")
println("######### END #########")
println("Moves = $(badCheckPossibleMoves(globalBest, instance))")
println("Solution is: $globalBest")
println("With value: $(badEval(globalBest))")

# restrictionLookup[0] = "foobar"

# print(restrictionLookup[0])

# There is a significantly more efficient way of doing this:
#   Initially, compute which prisions any prisioner can go to,
#   Put him into one of those, eval that solution and then update his partners' possible prisions

