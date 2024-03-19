include("./CanningsSimulator.jl")
using .CanningsSimulator
using DataFrames
using ArgParse
using CSV
using Printf


function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin

        "--selection_coefficient", "-s"
             help="selection coefficient"
             arg_type = Float64
             required = true

        "--population_size", "-N"
            arg_type=Int
            required=true

        "--selection_type", "-t"
            help="type of selection ∈ {fecundity_constant, fecundity_sinus viability_constant, viability_sinus, both}"
            arg_type=String
            required = false
            default="viability_constant"

        "--selection_coefficient2"
             help="selection coefficient2; used for fecundity only if selection type is both"
             arg_type = Float64
             required = false
             default=0.0

        "--initial_count", "-i"
            help="initial count of mutation in the population. Integer for count of mutations"
            arg_type=Int64
            required=false
            default=1

        "--initial_frequency", "-I"
            help="x between [0 , 1] for initial population frequency."
            arg_type=Float64
            required=false
            default=nothing

        "--selection_period"
             help="period for variable selection"
             arg_type = Float64
             required = false
             default=0.06283 # 100 generations or 500 (0.01256)

        "--offspring_model", "-m"
            arg_type = String
            default="Schweinsberg"

        "--parameter", "-p"
            arg_type=Float64
            default=2.0

        "--population_size_model", "-c"
            help="type of population size model ∈ {constant, sinus}"
            arg_type=String
            required=false
            default="constant"

        "--output_name", "-o"
            arg_type=String
            help="first part of output file name"
            required=false
            default="simulation"

        "--output_off", "-O"
            arg_type=Int
            help="set as 1 to silence file output. stdout only."
            required=false
            default=0

        "--type"
            arg_type=String
            help="type of simulation ∈ {time, probability}"
            required=false
            default="probability"

        "--shiftsinusby"
            arg_type=Float64
            help="shifting sinus function by x"
            required=false
            default=0.0


        "--nb_simulations", "-n"
            arg_type=Int
            help="Number of simulations"
            default=250000

    end
    return parse_args(s)
end


    function main()
        parsed_args = parse_commandline()


        selection_type::String = parsed_args["selection_type"]
        selection_coefficient::Float64 = parsed_args["selection_coefficient"]
        selection_coefficient2::Float64 = parsed_args["selection_coefficient2"]
        initial_count::Int = parsed_args["initial_count"]
        initial_frequency = parsed_args["initial_frequency"]
        offspring_model::String = parsed_args["offspring_model"]
        parameter::Float64 = parsed_args["parameter"]
        population_size::Int = parsed_args["population_size"]
        population_size_model::String = parsed_args["population_size_model"]
        output_name::String = parsed_args["output_name"]
        output_off::Int = parsed_args["output_off"]
        nb_simulations::Int = parsed_args["nb_simulations"]
        simulation_type::String = parsed_args["type"]
        shiftsinusby::Float64 = parsed_args["shiftsinusby"]
        selection_period::Float64 = parsed_args["selection_period"]



        #println(selection_period)


        #println(selection_type, " " ,selection_coefficient, " ", offspring_model, " ", parameter, " ", population_size_model, " ", population_size, " ", " nb_simulations ", nb_simulations)
        #println("Output-Prefix ", output_name)
        #println("Number of simulations ", nb_simulations)

        @assert selection_type == "fecundity_constant" || selection_type == "viability_constant" || selection_type == "fecundity_sinus" || selection_type == "viability_sinus" || selection_type == "both" "selection_type has to be fecundity or viability or both"
        @assert population_size_model == "constant" || population_size_model == "sinus" "population size model has to be constant or sinus"
        
        if selection_type == "fecundity_constant"
            # set the other one constant
            viability = CanningsSimulator.ConstantModifier(0.0)
            fecundity = CanningsSimulator.ConstantModifier(selection_coefficient)
        elseif selection_type == "viability_constant"
            viability = CanningsSimulator.ConstantModifier(selection_coefficient)
            fecundity = CanningsSimulator.ConstantModifier(0.0)
        end


        #if selection_type == "fecundity_sinus"
        #    # set the other one constant
        #    viability = CanningsSimulator.ConstantModifier(0.0)
        #    #fecundity = CanningsSimulator.SinusModifier(selection_coefficient-1, 0.05, selection_coefficient*0.5, shiftsinusby)
        #    fecundity = CanningsSimulator.SinusModifier(selection_coefficient-1, 0.1, selection_coefficient*0.1, shiftsinusby)
        #elseif selection_type == "viability_sinus"
        #    #viability = CanningsSimulator.SinusModifier(selection_coefficient-1, 0.05, selection_coefficient*0.5, shiftsinusby)
        #    viability = CanningsSimulator.SinusModifier(selection_coefficient-1, 0.1, selection_coefficient*0.1, shiftsinusby)
        #    fecundity = CanningsSimulator.ConstantModifier(0.0)
        #end

        if selection_type == "fecundity_sinus"
            # set the other one constant
            viability = CanningsSimulator.ConstantModifier(0.0)
            fecundity = CanningsSimulator.SinusModifier(0.0, selection_period, selection_coefficient, shiftsinusby)
        elseif selection_type == "viability_sinus"
            viability = CanningsSimulator.SinusModifier(0.0, selection_period, selection_coefficient, shiftsinusby)
            fecundity = CanningsSimulator.ConstantModifier(0.0)
        end

        if selection_type == "both"
            fecundity = CanningsSimulator.ConstantModifier(selection_coefficient2)
            viability = CanningsSimulator.ConstantModifier(selection_coefficient)
        end


        if population_size_model == "constant"
            population_size_mode = CanningsSimulator.ConstantModifier(population_size)
        elseif population_size_model == "sinus"
            population_size2::Float64 = population_size
            population_size_mode = CanningsSimulator.SinusModifier(population_size2, 0.05, population_size2*0.5, shiftsinusby)
        end
        
        if offspring_model == "Schweinsberg"
            @assert parameter >= 1.0 && parameter <= 2.0 "{α ∈ {1.0, ..., 2.0}}"
            offspring_sampler = CanningsSimulator.SchweinsbergSampler(parameter)
        elseif offspring_model == "fecundity_adapted_Schweinsberg"
            @assert parameter >= 1.19 && parameter <= 2.0 "{α ∈ {1.19, ..., 2.0}}"
            offspring_sampler = CanningsSimulator.SchweinsbergSampler(parameter)
            fecundity = CanningsSimulator.SchweinsbergSampler(parameter, selection_coefficient)
        elseif offspring_model == "Poisson"
            @assert parameter > 0 "{λ > 0 }"
            offspring_sampler = CanningsSimulator.PoissonSampler(parameter)
        end


        if parsed_args["initial_frequency"] != nothing
            @printf("Initial frequency supplied: %.1f", initial_frequency)
            initial_frequency::Float64 = parsed_args["initial_frequency"]

            nb_indiv_type_1 = floor(Int64, initial_frequency*population_size)
        else
            nb_indiv_type_1 = initial_count
        end

        @printf("\nSimulating %s population model (a = %g) with %d individuals\nSelection coefficient = %g and initial count of %d\n",
               offspring_model, parameter, population_size, selection_coefficient, nb_indiv_type_1)

        if output_off == 0
            println("Simulation will be saved to output file...")
        else
            println("No output file will be recorded!")
        end

        @assert simulation_type == "time" || simulation_type == "probability" "simulations typ should be {time, probability}"
        if simulation_type == "probability"
            ## For fixation probabilites only
            # fixation_probability = CanningsSimulator.bootstrap_fixation_probability(
            #             nb_indiv_type_1,
            #             population_size_mode,
            #             fecundity,
            #             viability,
            #             offspring_sampler,
            #             nb_simulations
            #         );

            fixation_probability, lost_probability = CanningsSimulator.bootstrap_fixation_and_lost_probabilities(
                        nb_indiv_type_1,
                        population_size_mode,
                        fecundity,
                        viability,
                        offspring_sampler,
                        nb_simulations
                    );

        @printf("Probability of fixation: P = %0.5f; Probability of loss: P = %0.5f\n", fixation_probability, lost_probability)


            if selection_type != "both"
                df = DataFrame(Dict("parameter"=>parameter, "population_size"=>population_size,
                "fixation_probability"=>fixation_probability,
                "lost_probability" =>lost_probability,
		"offspring_model"=>offspring_model,
		"initial_count" =>nb_indiv_type_1,
                "selection_type"=>selection_type, 
                "selection_coefficient"=>selection_coefficient,
                "selection_period"=>selection_period, 
                "population_size_model"=>population_size_model,
                "N_simulations"=>nb_simulations)
                )
            else
                df = DataFrame(Dict("parameter"=>parameter, "population_size"=>population_size,
                "fixation_probability"=>fixation_probability,
                "lost_probability" =>lost_probability,
                "selection_type"=>selection_type, 
                "selection_coefficient"=>selection_coefficient,
                "selection_coefficient2"=>selection_coefficient2,
                "population_size_model"=>population_size_model)
                )
            end
        end

        if simulation_type == "time"
            histories = CanningsSimulator.bootstrap_fixation_time(
                    nb_indiv_type_1,
                    population_size_mode,
                    fecundity,
                    viability,
                    offspring_sampler,
                    nb_simulations # counts number of fixation events
                );
            #append!(fixation_probabilities, [Dict("α"=>α, "n"=>n, "fixation_time"=>CanningsSimulator.average_fixation_time(histories), "standard_deviation"=>CanningsSimulator.std_fixation_time(histories))])

            #print(CanningsSimulator.average_fixation_time(histories), CanningsSimulator.std_fixation_time(histories))


            
            if selection_type != "both"
                df = DataFrame(Dict("parameter"=>parameter, "population_size"=>population_size,
                "fixation_time"=>CanningsSimulator.average_fixation_time(histories),
                "standard_deviation"=>CanningsSimulator.std_fixation_time(histories),
                "selection_type"=>selection_type, 
                "selection_coefficient"=>selection_coefficient,
                "selection_period"=>selection_period, 
                "population_size_model"=>population_size_model)
                )
            else
                df = DataFrame(Dict("parameter"=>parameter, "population_size"=>population_size,
                "fixation_time"=>CanningsSimulator.average_fixation_time(histories),
                "standard_deviation"=>CanningsSimulator.std_fixation_time(histories),
                "selection_type"=>selection_type, 
                "selection_coefficient"=>selection_coefficient,
                "selection_coefficient2"=>selection_coefficient2,
                "population_size_model"=>population_size_model)
                )
            end
        end


        #print(df)

        #fixation_time,parameter,population_size,population_size_model,selection_coefficient,selection_type,standard_deviation
        #fixation_probability,parameter,population_size,population_size_model,selection_coefficient,selection_type


#println("saving simulation to file...")
if output_off == 0
        if selection_type != "both"
            CSV.write(string("./simulations/",
            output_name,"_", "population_size_", population_size, "_", "size_model_",  population_size_model, "_",
            offspring_model,"_", parameter, "_", selection_type,
            "_selection_", selection_coefficient,		
	    "_initial_", nb_indiv_type_1,
            "_nb_simulations_", nb_simulations,
            ".csv"), df)
        else
            CSV.write(string("./simulations/",
            output_name,"_",
            "population_size_", population_size, "_",
            "size_model_",  population_size_model, "_",
            offspring_model,"_", parameter, "_",
            selection_type,
             "_selection_", selection_coefficient ,
             "_selection2_", selection_coefficient2 ,
             "_nb_simulations_", nb_simulations, "_shifted_", shiftsinusby,
            ".csv"), df)
        end
    else
       end
    @printf("Simulation of %s runs finished!\n", nb_simulations)
    end

main()
