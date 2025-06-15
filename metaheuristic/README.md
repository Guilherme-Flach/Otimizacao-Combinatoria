# GRASP-Based Prisoner Assignment Solver (Julia)

This project implements a metaheuristic optimization algorithm to solve a constrained assignment problem involving prisoners. It uses the **GRASP** metaheuristic combined with **local search**.

## ▶️ Running the Program

To run the algorithm, use the following command in your terminal:

```bash
julia --threads auto main.jl <filepath> <iterations> <seed> [alpha] [showRestrictions] [reverse]
```

### Required Arguments:

`<filepath>`: Path to the input instance file (e.g., instances/01.txt)

`<iterations>`: Number of iterations of the GRASP metaheuristic

`<seed>`: Random seed for reproducibility

### Optional Arguments:

`[alpha]`: Alpha parameter for the greedy randomization (default: 0.15)

`[showRestrictions]`: Whether to print instance restrictions (true or false, default: false)

`[reverse]`: Whether to reverse greedy logic (true or false, default: false)

### Run Example:

```bash
julia --threads auto main.jl instances/01.txt 10000 42 0.1 true false
```

## 📊 Batch Testing with solution_benchmark

The script solution_benchmark.jl runs multiple instances with different parameter settings and prints results in a CSV-friendly format, for later analysis.

### Usage:

```bash
julia solution_benchmark.jl > results.csv
```