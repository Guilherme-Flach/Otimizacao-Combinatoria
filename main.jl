# include("src/reader.jl")
include("src/reader.jl")
include("src/instace.jl")

using Random

# Variables to be extracted as command line params
randomSeed = 7
filePath = "instances/01.txt"
iterationsNum = 100

Random.seed!(randomSeed)

instance::Instance = reader(filePath)

println("Number of prisioners: $(instance.n)")
println("Number of restrictions: $(instance.m)")
println("Restriction matrix:")
display(instance.alliances)





