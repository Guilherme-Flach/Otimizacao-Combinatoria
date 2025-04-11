include("instance.jl")

function randomGreedy(instance::Instance, alpha::Float64)::Solution
    solution = Solution()

    prisioners = 1:instance.n

    # Dumb grasp, perfectly deterministic using restriction count
    prisioners = sort(prisioners, rev=true, by=x -> countRestrictions(x, instance))

    for prisioner in prisioners
        allocatePrision!(solution, prisioner, instance)
    end

    return solution
end


function countRestrictions(prisioner::Prisioner, instance::Instance)::Prisioner
    # Count the number of alliances a given prisioner has (amount of 1s in his line or column)
    return sum(instance.alliances[prisioner, :])
end

function allocatePrision!(prisions::Solution, prisioner::Prisioner, instance::Instance)
    needsNewPrision = true
    for currentPrision in prisions
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
        push!(prisions, [prisioner])
    end
end