julia simulator.jl -N 1000 -s 0 -i 1 -m Poisson -p 1.2 -o sim --nb_simulations 500000
julia simulator.jl -N 1000 -s 0.001 -i 1 -m Poisson -p 1.2 -o sim --nb_simulations 500000
julia simulator.jl -N 1000 -s 0.005 -i 1 -m Poisson -p 1.2 -o sim --nb_simulations 500000
julia simulator.jl -N 1000 -s 0.01 -i 1 -m Poisson -p 1.2 -o sim --nb_simulations 500000
julia simulator.jl -N 1000 -s 0.05 -i 1 -m Poisson -p 1.2 -o sim --nb_simulations 500000
julia simulator.jl -N 1000 -s 0.1 -i 1 -m Poisson -p 1.2 -o sim --nb_simulations 500000

julia simulator.jl -N 1000 -s 0 -i 999 -m Poisson -p 1.2 -o sim --nb_simulations 500000
julia simulator.jl -N 1000 -s -0.001 -i 999 -m Poisson -p 1.2 -o sim --nb_simulations 500000
julia simulator.jl -N 1000 -s -0.005 -i 999 -m Poisson -p 1.2 -o sim --nb_simulations 500000
julia simulator.jl -N 1000 -s -0.01 -i 999 -m Poisson -p 1.2 -o sim --nb_simulations 500000
julia simulator.jl -N 1000 -s -0.05 -i 999 -m Poisson -p 1.2 -o sim --nb_simulations 500000
julia simulator.jl -N 1000 -s -0.1 -i 999 -m Poisson -p 1.2 -o sim --nb_simulations 500000
