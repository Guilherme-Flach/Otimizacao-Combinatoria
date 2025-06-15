using Dates
using .Threads
using Random

# Test cases to run
const TEST_CASE = "instances/01.txt"
const computationBudget = 1200000

println("## $TEST_CASE - $computationBudget")
@threads for random_seed = 1:10
    # Run the actual command
    cmd = `julia meta-heuristic/main.jl $TEST_CASE $computationBudget $random_seed`
    output = read(cmd, String)

    # Output CSV row
    println("######### $random_seed #########\n$output")
    println("------------------------------------------")
end
