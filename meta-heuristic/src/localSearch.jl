include("instance.jl")

function localSearch(solution::Solution, instance::Instance)::Solution
    foundLocalMinimum = false
    while !foundLocalMinimum
        # Assume we are at a local minimum until we find a better solution
        foundLocalMinimum = true
        bestLocally = deepcopy(solution)

        # Explode a prision and try to place the prisioners somewhere else
        for (prisionIndex, prision) in enumerate(solution.prisionsStructure)

            newSolution = deepcopy(solution)

            deleteat!(newSolution.prisionsStructure, prisionIndex)

            # Hope all prisioners can be reallocated into already existing prisions
            newSolution.value -= 1

            # Reallocate the prisioners
            neededNewPrision = false # Assume all the prisioners can fit pre-existing prisions
            for prisioner in shuffle(prision)
                neededNewPrision = allocatePrision!(newSolution, prisioner, instance)
                if (neededNewPrision)
                    # If even one of the prisioners could not fit into one of the existing prisions,
                    # there is no need to check the others, since it will never make for a better solution.
                    break
                end
            end

            # equivalent to looking at: newSolution.value < bestLocally.value, since if a new prision was not needed, the solution value decereased by one
            if (!neededNewPrision)
                bestLocally = deepcopy(newSolution)
                foundLocalMinimum = false
                # Since the best improvement possible will always just be 1, we can stop looking after that.
                break
            end
        end
        solution = deepcopy(bestLocally)
    end
    return solution
end

function allocatePrision!(solution::Solution, prisioner::Prisioner, instance::Instance)
    needsNewPrision = true

    for currentPrision in solution.prisionsStructure
        fitsInCurrentPrision = true
        # Look throught the inmates and try to find a restriction
        for inmate in currentPrision
            if (instance.alliances[prisioner, inmate] == 1)
                fitsInCurrentPrision = false
                break
            end
        end

        # If possible, put him into that prision and stop the search
        if (fitsInCurrentPrision)
            push!(currentPrision, prisioner)
            needsNewPrision = false
            break
        end
    end

    # If the prisioner can't be placed into an already existing prision, allocate a new one
    if (needsNewPrision)
        push!(solution.prisionsStructure, [prisioner])

        # Worsen solution value since another prision is needed
        solution.value += 1
    end

    return needsNewPrision
end
