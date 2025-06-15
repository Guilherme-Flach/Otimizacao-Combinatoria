using Dates
using .Threads
using Random

# Test cases to run
const TEST_CASE = "instances/10.txt"
const computationBudget = 12000000

println("## $TEST_CASE - $computationBudget")
@threads for random_seed = 1:10
    # Run the actual command
    cmd = `julia meta-heuristic/main.jl $TEST_CASE $computationBudget $random_seed`
    output = read(cmd, String)

    println("######### $random_seed #########\n\n$output\n")
    println("------------------------------------------")
end
