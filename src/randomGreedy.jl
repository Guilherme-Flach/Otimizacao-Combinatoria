include("instance.jl")

struct PartialSolution
    restrictionsCount::Int
    prisioner::Prisioner
    prision::Int
    newPrisionRestrictions::Set{Prisioner}
end


function randomGreedy(instance::Instance, alpha::Float64, rev::Bool)::Solution
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
            for prisionIndex in 1:totalPrisions
                if !(prisioner in currentRestrictions[prisionIndex])
                    push!(partialSolutions, makePartialSolutions(prisioner, prisionIndex, currentRestrictions[prisionIndex], instance))
                end
            end
            push!(partialSolutions, makeEmptyPartialSolution(prisioner, totalPrisions, instance))
        end

        sort!(partialSolutions, by=s -> s.restrictionsCount, rev=rev)

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

function makePartialSolutions(prisioner::Prisioner, prisionIndex::Int, prisionRestrictions::Set{Prisioner}, instance::Instance)
    restrictionsCount = 0
    newPrisionRestrictions = copy(prisionRestrictions)

    newPrisionRestrictions = union(prisionRestrictions, instance.alliancesAdjacency[prisioner])
    restrictionsCount = length(newPrisionRestrictions)

    return PartialSolution(restrictionsCount, prisioner, prisionIndex, newPrisionRestrictions)
end

function makeEmptyPartialSolution(prisioner, totalPrisions, instance)

    restrictionsCount = length(instance.alliancesAdjacency[prisioner]) + instance.n

    return PartialSolution(restrictionsCount, prisioner, totalPrisions + 1, instance.alliancesAdjacency[prisioner])
end