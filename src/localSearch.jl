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
            for prisioner in shuffle(prision)
                allocatePrision!(newSolution, prisioner, instance)
            end


            if (newSolution.value < bestLocally.value)
                # maybe this can be removed
                bestLocally = deepcopy(newSolution)
                foundLocalMinimum = false
            end

            # Keep going for best improvement
        end
        solution = deepcopy(bestLocally)
    end
    return solution
end

function allocatePrision!(solution::Solution, prisioner::Prisioner, instance::Instance)
    needsNewPrision = true

    for currentPrision in shuffle(solution.prisionsStructure)
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
end
