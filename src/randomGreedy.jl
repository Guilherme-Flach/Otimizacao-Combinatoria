include("instance.jl")

struct PartialSolution
    restrictionsCount::Int
    prisioner::Prisioner
    prision::Int
    newPrisionRestrictions::Set{Prisioner}
end


function randomGreedy(instance::Instance, alpha::Float64)::Solution
    remainingPrisioners = Set{Prisioner}()
    for i = 1:instance.n
        push!(remainingPrisioners, i)
    end

    # Matrix showing which prisioners can still fit into each prision
    currentRestrictions = Vector{Set{Prisioner}}()
    # For the greedy algorithm, we'll pick the one that creates the least number of restrictions
    prisionAllocations = Vector{Vector{Int}}()

    totalPrisions = 0

    # Figure out an assignment for each prisioner
    for i = 1:instance.n
        partialSolutions = Vector{PartialSolution}()

        for prisioner in remainingPrisioners
            for (prisionIndex, prision) in enumerate(prisionAllocations)
                if !(prisioner in currentRestrictions[prisionIndex])
                    push!(partialSolutions, makePartialSolutions(prisioner, prision, prisionIndex, currentRestrictions[prisionIndex], instance))
                end
            end
            push!(partialSolutions, makePartialSolutions(prisioner, Vector{Int}(), totalPrisions + 1, Set{Int}(), instance))
        end

        sort!(partialSolutions, by=s -> s.restrictionsCount)

        selectedSolution::PartialSolution = pickRandom(partialSolutions, alpha)

        # Update current prision layout
        # Need to add another prision
        if (selectedSolution.prision > totalPrisions)
            push!(prisionAllocations, [selectedSolution.prisioner])
            push!(currentRestrictions, selectedSolution.newPrisionRestrictions)
            totalPrisions += 1
        else
            push!(prisionAllocations[selectedSolution.prision], selectedSolution.prisioner)
            currentRestrictions[selectedSolution.prision] = selectedSolution.newPrisionRestrictions
        end

        # Remove the prisioner from the unallocated ones
        delete!(remainingPrisioners, selectedSolution.prisioner)
    end



    return Solution(prisionAllocations, totalPrisions)
end


function pickRandom(array, top_percent)
    sliceIndex = Int(round(size(array)[1] * top_percent))

    return rand(array[1:max(1, sliceIndex)])


end

function makePartialSolutions(prisioner::Prisioner, prision::Prision, prisionIndex::Int, prisionRestrictions::Set{Prisioner}, instance::Instance)
    restrictionsCount = 0
    newPrisionRestrictions = deepcopy(prisionRestrictions)
    newPrision = deepcopy(prision)

    for criminal in 1:instance.n
        # Don't recount current prisioner
        if (criminal == prisioner)
            continue
        end

        if (instance.alliances[prisioner, criminal] == 1 && !(criminal in prisionRestrictions))
            push!(newPrisionRestrictions, criminal)
            restrictionsCount += 1
        end
    end

    return PartialSolution(restrictionsCount, prisioner, prisionIndex, newPrisionRestrictions)
end