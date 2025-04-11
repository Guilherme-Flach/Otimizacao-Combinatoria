include("instance.jl")

function localSearch(initialSolution::Solution, instance::Instance)::Solution
    currentSolution = deepcopy(initialSolution)
    foundLocalMinimum = false
    while !foundLocalMinimum
        # Assume we are at a local minimum until we find a better solution
        foundLocalMinimum = true
        possibleMoves = badCheckPossibleMoves(currentSolution, instance)
        newSolution = deepcopy(currentSolution)

        # Iterate over prisioners and try to move them somewhere else
        for (prisionIndex, prision) in enumerate(currentSolution)
            for prisioner in prision
                # Try to move him to another prision
                for newPrisionIndex in shuffle(possibleMoves[prisioner])

                    originPrision = newSolution[prisionIndex]
                    newPrision = newSolution[newPrisionIndex]

                    movePrisioner!(originPrision, newPrision, prisioner)
                    # If it makes for a better solution, we should keep it
                    if (badEval(newSolution) < badEval(currentSolution))
                        currentSolution = deepcopy(newSolution)
                        foundLocalMinimum = false
                    else
                        # Otherwise, keep searching
                        movePrisioner!(newPrision, originPrision, prisioner)
                    end
                end
            end
        end
    end
    return currentSolution
end

# This simply counts the amount of prisions with 0 prisioners
function badEval(solution::Solution)::Int
    return count(i -> (i[1] != 0), size.(solution))
end

function canMoveTo(prisioner::Int, prision::Prision, restrictions)::Bool
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

# No differential eval, just check them all
function badCheckPossibleMoves(solution::Solution, instance::Instance)::Vector{Prision}
    possibleMoves = Vector{Prision}()
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

function movePrisioner!(originPrision, newPrision, prisioner)
    deleteat!(originPrision, originPrision .== prisioner)
    push!(newPrision, prisioner)
end