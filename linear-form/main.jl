# Para tornar mais rápida a execução:
# * Executar os comandos antes de `m = Model(...)` em um terminal,
#   comentar o `main()` no final do arquivo. Então executar
#   `Revise.includet("q1.jl")`, daí se pode só editar o arquivo e chamar
#   `main()` para executar novamente.
import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()


using JuMP
using HiGHS
using Revise

function main()
    if (size(ARGS)[1] < 3)
        println("Error reading args. Usage: `main.jl filepath time_seconds random_seed")
        return 1
    end

    filepath = ARGS[1]
    time_limit = parse(Int, ARGS[2])
    random_seed = parse(Int, ARGS[3])

    filepath = ARGS[1]
    print(filepath)

    model = Model(HiGHS.Optimizer)

    set_time_limit_sec(model, time_limit)
    set_attribute(model, "random_seed", random_seed)

    n = 0
    m = 0

    open(filepath, "r") do f
        # First line is "n m"
        line = readline(f)
        # GRASP it
        n, m = parse.(Int, split(line))

        # Since the maximum number of possible prisions required in an optimal solution is n,
        # we can define a n x n matrix to represent the assignment of prisioners to prisions.
        # In this representation, prisions[i,j] means that prisioner i will be in the prision with index j.
        @variable(model, prisions[i=1:n, j=1:n], Bin)

        # Prisioners must be assigned into exactly one prision
        @constraint(model, [i = 1:n], sum(prisions[i, :]) == 1)


        for line in eachline(f)
            p1, p2 = parse.(Int, split(line))

            # For the restriction modelling, we can define that p2 and p1 can't both be assigned to the same prision
            @constraint(model, [j = 1:n], prisions[p1, j] + prisions[p2, j] <= 1)

        end

        # We want to minimize the amount of used prisions
        # We can represent those with helper variables, indicating which prisions are in use
        @variable(model, is_used[j=1:n], Bin)

        # If there are any prisioners in the j prision, then is_used[j] is forced into 1, otherwise it can be set to 0
        @constraint(model, [j = 1:n], sum(prisions[:, j]) <= is_used[j] * n)

        # Extra restrictions to reduce the number of simetries
        # Essentially, make sure that, in order for a new prision to be used, all prisions with a smaller index must have been used first.
        @variable(model, all_prisions_occupied[j=1:n], Bin)
        @constraint(model, [j = 1:n], sum(is_used[1:j]) >= all_prisions_occupied[j] * j)
        @constraint(model, [j = 2:n], is_used[j] <= all_prisions_occupied[j-1])

        # We want to minimize the total amount of used prisions
        @objective(model, Min, sum(is_used[:]))

        optimize!(model)
        # display(value.(prisions))
        display_solution(value.(prisions))
        @show objective_value(model)
        @show sum(value.(is_used))
    end

end

function display_solution(solution)
    readableSolution = ""

    for prisioner in eachrow(solution)
        prision_index = argmax(prisioner)
        readableSolution = readableSolution * " " * string(prision_index)
    end

    println("Solution: [$(readableSolution) ]")
end

main()

