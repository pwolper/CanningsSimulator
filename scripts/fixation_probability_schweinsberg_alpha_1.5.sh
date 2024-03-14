julia simulator.jl -N 1000 -t viability_constant -s 0 -m Schweinsberg -p 1.5  --type probability -c constant -o fixation_probability #--nb_simulations 500000
echo "Finished simulation for s = 0"
julia simulator.jl -N 1000 -t viability_constant -s 0.01 -m Schweinsberg -p 1.5  --type probability -c constant -o fixation_probability #--nb_simulations 500000
echo "Finished simulation for s = 0.01"
julia simulator.jl -N 1000 -t viability_constant -s 0.05 -m Schweinsberg -p 1.5  --type probability -c constant -o fixation_probability #--nb_simulations 500000
echo "Finished simulation for s = 0.05"
julia simulator.jl -N 1000 -t viability_constant -s 0.1 -m Schweinsberg -p 1.5  --type probability -c constant -o fixation_probability #--nb_simulations 500000
echo "Finished simulation for s = 0.1"
julia simulator.jl -N 1000 -t viability_constant -s 0.2 -m Schweinsberg -p 1.5  --type probability -c constant -o fixation_probability #--nb_simulations 500000
echo "Finished simulation for s = 0.2"
julia simulator.jl -N 1000 -t viability_constant -s -0.01 -m Schweinsberg -p 1.5  --type probability -c constant -o fixation_probability #--nb_simulations 500000
echo "Finished simulation for s = -0.01"
julia simulator.jl -N 1000 -t viability_constant -s -0.05 -m Schweinsberg -p 1.5  --type probability -c constant -o fixation_probability #--nb_simulations 500000
echo "Finished simulation for s = -0.05"
julia simulator.jl -N 1000 -t viability_constant -s -0.1 -m Schweinsberg -p 1.5  --type probability -c constant -o fixation_probability #--nb_simulations 500000
echo "Finished simulation for s = -0.1"
julia simulator.jl -N 1000 -t viability_constant -s -0.2 -m Schweinsberg -p 1.5  --type probability -c constant -o fixation_probability #--nb_simulations 500000
echo "Finished simulation for s = -0.2"
