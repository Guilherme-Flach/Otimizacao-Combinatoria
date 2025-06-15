using Dates
using .Threads
using Random

# Test cases to run
const TEST_CASE = "instances/09.txt"
const computationBudget = 160000

println("## $TEST_CASE - $computationBudget")
for random_seed = 1:10
    # Run the actual command
    cmd = `julia metaheuristic/main.jl $TEST_CASE $computationBudget $random_seed`
    output = read(cmd, String)

    println("\n######### $random_seed #########\n\n$output")
    println("------------------------------------------")
end
