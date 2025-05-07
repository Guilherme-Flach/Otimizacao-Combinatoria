using Dates
using Random

# Test cases to run
const TEST_CASES = [
    ("instances/01.txt", 100, 42, 0.2),
    ("instances/01.txt", 200, 1337, 0.3),
    ("instances/01.txt", 150, 99, 0.1),
    ("instances/01.txt", 120, 2024, 0.5),
    ("instances/01.txt", 300, 17, 0.0),
]

# CSV header
println("instance,n,m,iterations,seed,alpha,value,time")

for (filepath, iterations, seed, alpha) in TEST_CASES
    # Read n and m from the first line of the instance file
    first_line = open(filepath) do f
        readline(f)
    end
    n, m = parse.(Int, split(first_line))

    # Run the actual command
    start_time = now()
    cmd = `julia --threads auto main.jl $filepath $iterations $seed $alpha`
    output = read(cmd, String)
    elapsed = now() - start_time

    # Format time as MM:SS.sss
    zero_time = DateTime(0)
    formatted_time = Dates.format(zero_time + elapsed, "MM:SS.sss")

    # Extract best solution value
    m_val = match(r"Best solution value:\s*(\d+)", output)
    value = isnothing(m_val) ? "N/A" : m_val.captures[1]

    # Output CSV row
    println("$filepath,$n,$m,$iterations,$seed,$alpha,$value,$formatted_time")
end
