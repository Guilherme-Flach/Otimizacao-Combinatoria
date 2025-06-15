using Dates
using Random
using Statistics

# Test cases to run
const TEST_CASES = [
    "instances/01.txt",
]

# CSV header
println("instance,n,m,seed,value,time")

time_limit = 300

# Store results per instance
results = Dict{String, Vector{Tuple{Float64, Float64}}}()

for filepath in TEST_CASES
    # Read n and m from the first line of the instance file
    first_line = open(filepath) do f
        readline(f)
    end
    n, m = split(first_line)

    instance_results = Tuple{Float64, Float64}[]  # (value, time)

    for random_seed in 1:10
        start_time = now()

        # Run the actual command
        cmd = `julia linear-form/main.jl $filepath $time_limit $random_seed`
        output = read(cmd, String)
        elapsed = now() - start_time

        # Format time as MM:SS.sss
        zero_time = DateTime(0)
        formatted_time = Dates.format(zero_time + elapsed, "MM:SS.sss")

        # Extract values
        m_val = match(r"objective_value\(model\)\s=\s(\d+\.\d+)", output)
        value = isnothing(m_val) ? NaN : parse(Float64, m_val.captures[1])

        time_secs = Dates.value(elapsed) / 1000.0  # Convert milliseconds to seconds

        # Store valid runs for summary
        if !isnan(value)
            push!(instance_results, (value, time_secs))
        end

        # Output CSV row
        println("$filepath,$n,$m,$random_seed,$value,$formatted_time")
    end

    results[filepath] = instance_results
end

println()  # Blank line before summary
println("instance,best,mean,worst,min_time,mean_time,max_time")

for (filepath, runs) in results
    values = [r[1] for r in runs]
    times = [r[2] for r in runs]

    best = minimum(values)
    mean_val = mean(values)
    worst = maximum(values)

    min_time = minimum(times)
    mean_time = mean(times)
    max_time = maximum(times)

    println("$(filepath),$(round(best, digits=3)),$(round(mean_val, digits=3)),$(round(worst, digits=3))," *
            "$(min_time),$(mean_time),$(max_time)")
end
