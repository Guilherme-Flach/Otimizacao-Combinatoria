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
    prisioners = 1
    model = Model(HiGHS.Optimizer)

    # Nodes must send a non negative amount of tons
    @variable(model, x[i=1:8, j=1:8] >= 0)

    # The amount of tons arriving at H must be at least 6
    @constraint(model, sum(x[:, 8]) == 6)

    # Arcs must respect their capacities
    @constraint(model, [i = 1:8, j = 1:8], x[i, j] <= routes[i, j, 2])

    # The amount of tons coming in from a node must match the amount coming out
    # in other words, the sum of each line must be equal to the sum of each column
    # (except for stuff coming from node 1 (first line) and 8 (last line))
    @constraint(model, [i = 2:7], sum(x[i, :]) == sum(x[:, i]))

    # Minimize the amount of tons sent via an arc times the per ton of that arc
    @objective(model, Min, sum(x .* routes[:, :, 1]))

    optimize!(model)
    @show objective_value(model)
    @show value.(x)

end

main() # comentar aqui se for executar no terminal Julia

