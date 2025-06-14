using Dates
using Random

# Test cases to run
const TEST_CASES = [
    "instances/01.txt",
    "instances/02.txt",
    "instances/03.txt",
    "instances/04.txt",
    "instances/05.txt",
    "instances/06.txt",
    "instances/07.txt",
    "instances/08.txt",
    "instances/09.txt",
    "instances/10.txt",
]

# CSV header
println("instance,n,m,iterations,seed,alpha,value,time")

time_limit = 300
for filepath in TEST_CASES
    # Read n and m from the first line of the instance file
    first_line = open(filepath) do f
        readline(f)
    end

    println("## $filepath")
    for random_seed = 1:10
        start_time = now()
        # Run the actual command
        cmd = `julia linear-form/main.jl $filepath $time_limit $random_seed`
        output = read(cmd, String)
        elapsed = now() - start_time

        # Format time as MM:SS.sss
        zero_time = DateTime(0)
        formatted_time = Dates.format(zero_time + elapsed, "MM:SS.sss")

        # Extract best solution value
        m_val = match(r"objective_value\(model\)\s=\s(\d+\.\d+)", output)
        value = isnothing(m_val) ? "N/A" : m_val.captures[1]

        # Output CSV row
        println("$filepath,$random_seed,$value,$formatted_time")
    end

end
