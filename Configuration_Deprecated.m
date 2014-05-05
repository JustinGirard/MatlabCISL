classdef Configuration_Deprecated < handle
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
    %Configuration
    %singleton class that holds all the configuration information for
    %a running simulation
    %it is globally accessible and guarnteed to be singular
    
    properties
        configRun = [];
        configLabels = [];
    end
    
    
    properties (Constant)
        % singleton instance
        s_instance = Configuration();
        
        % CISL / learning parameters
        cisl_MaxGridSize = 11;
        
        
        % robots
        % [rot speed  %mass(strength) %stepSize   %id]  
        robot_Type =[ 4*pi/18        3             0.30        1; ... %strong-slow
                      4*pi/18        2             0.40        2; ... %weak-fast
                      4*pi/18        2             0.30        3; ... %weak-slow
                      4*pi/18        3             0.40        4];    %strong-fast
        robot_sameStrength = [1; 2; 2; 1;]; %comparative Ids for strength
                  
                  
        robot_Reach = 2.5;
                    %size     %weight          %id
        target_Type =[ 0.5        1                1; ...
                       0.2        2                2];
        
        
        robot_NoiseLevel = 0;        
        particle_Used = 0;
        %v12 values
        %particle_ResampleNoiseMean = 0.05;
        %particle_ResampleNoiseSTD = 0.1;

        %v13 values - experementally found
        particle_ResampleNoiseSTD = 0.0015;
        particle_ControlStd = 0.001;
        particle_SensorStd  = 1;
        %0 - basic filter
        %1 - forward forcasts guess control failure
        particle_controlType = 0;

        %0- default resample, right after control, but before sensor update
        %1- resample, before everything
        %2- resample, after everything, just before reading (good for
        %pruning)
        particle_resampleType = 0;

        %0 - default - exponental drop off with distance
        %1 - linear drop off (more venrable to outliers?)
        particle_weightType = 0;
        
        
        %0 - do nothing
        %1 - stop particles from drifting outside the world
        particle_borderControlType = 0;
        
        
        %0 - do nothing
        %1 - resample particles based on best weighted previous particle
        particle_resampleSortingType = 0;
        
        %0 - do nothing
        %[0,1] - percentage weight of past particle bias
        particle_pastWeightAmount = 0;
        
        particle_Number = 20;
        particle_PruneNumber = floor(20/3);
        
        %Some general configuration parameters!
        numRobots = 12;
        numObstacles = 2;
        numTargets = 12;
        
        numTest = 300;
        numRun = 1;
        numIterations = 15000;
        
        simulation_NewWorldEveryTest = 0;
        simulation_NewWorldEveryRun = 1;
        simulation_NewRobotsEveryTest = 0;
        simulation_NewRobotsEveryRun = 0;
        
        
        % update motivation every X iterations
        % it doesn't need to be updated every iteration
        lalliance_motiv_freq = 15;
        
        qlearning_gammamin = 0.3;
        qlearning_gammamax = 0.3;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % cisl_learningFrequency 
        %
        % Execute learning after every [X] actions
        % drastically slows convergence, but speeds simulation time
        % after convergence, this speeds simulation time immensely
        %
        cisl_learningFrequency = 1;
        
        I_POS = 1:3;
        I_ORIENT = 4:6;
        %XY pos and Z orientation
        I_PXY_OZ = [1 2 6];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % simulation_Realism
        %
        % 0 realism means grid based moves and "picking up" boxes
        % 1 means robots have to 'slide' the box across the floor
        % (but! with 1 they can cooperate!)
        %
        simulation_Realism = 0;

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % world_Continuity
        %
        % 0 zero means that the world will be gridded, and actions will
        % 'snap' objects to specific places in the grid
        % 1 the world is continuous
        world_Continuity = 0;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % world_Height world_Width world_Depth
        %
        % The dimensions of this wonderful world
        % 
        % 
        world_Height = 14;
        world_Width = 14;
        world_Depth = 0;

        
        world_randomPaddingSize = 0.5;
        world_randomBorderSize = 1;
        world_robotSize = 0.5;
        world_obstacleSize = 0.5;
        world_targetSize = 0.5;
        world_goalSize = 1.0;
        world_robotMass = 1;
        world_targetMass = 1;
        world_obstacleMass = 0; 
        
    end
    
    methods (Static)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function inst = Instance(id)
            %singleton implementation
            c = Configuration.s_instance;
            inst = c.configRun(id);

        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function labels = InstanceLabels()
            c = Configuration.s_instance;
            labels = c.configLabels;
        
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function SetConfiguration(id,configObj)
            this = Configuration.s_instance;
            this.configRun(id) = configObj;
        end
    end
    
    methods
        
        function this = Configuration()
            
            % main configurations for actual testing
            % QAL - Q-learning, Advice Exchange, L-Alliance  
            config1  = ConfigurationRun();
            config2  = ConfigurationRun();
            config3  = ConfigurationRun();
            config5  = ConfigurationRun();
            config4  = ConfigurationRun();
            
            config6  = ConfigurationRun();
            config7  = ConfigurationRun();
            config8  = ConfigurationRun();
            config9  = ConfigurationRun();
            config10 = ConfigurationRun();
            config11 = ConfigurationRun();
            config12 = ConfigurationRun();
            config13 = ConfigurationRun();
            config14 = ConfigurationRun();
            config15 = ConfigurationRun();
            config16 = ConfigurationRun();

            config2.robot_NoiseLevel = 0.06;
            config3.robot_NoiseLevel = 0.06;
            config3.particle_Used = 1;
            config14.robot_NoiseLevel = 0.06;
            config14.particle_Used = 1;

            config5.robot_NoiseLevel = 0.1;
            config6.robot_NoiseLevel = 0.1;
            config6.particle_Used = 1;
            config15.robot_NoiseLevel = 0.1;
            config15.particle_Used = 1;
            
            config8.robot_NoiseLevel = 0.2;
            config9.robot_NoiseLevel = 0.2;
            config9.particle_Used = 1;
            config16.robot_NoiseLevel = 0.2;
            config16.particle_Used = 1;

            config10.robot_NoiseLevel = 0.3;
            config11.robot_NoiseLevel = 0.3;
            config11.particle_Used = 1;
            
            config12.robot_NoiseLevel = 0.4;
            config13.robot_NoiseLevel = 0.4;
            config13.particle_Used = 1;

            %QAQ - Q-learning, Advice Exchange, Q-Learning (team)
            config17 = ConfigurationRun(); % Baseline
            config18 = ConfigurationRun();  % 0.06 noise
            config19 = ConfigurationRun(); % 0.1 noise

            config20 = ConfigurationRun(); % Baseline & PF
            config21= ConfigurationRun();  % 0.06 noise & Pf
            config22 = ConfigurationRun(); % 0.1 noise & PF
            
            config17.robot_NoiseLevel = 0;
            config18.robot_NoiseLevel = 0.06;
            config19.robot_NoiseLevel = 0.1;

            config20.robot_NoiseLevel = 0;
            config21.robot_NoiseLevel = 0.06;
            config22.robot_NoiseLevel = 0.1;
            
            config17.cisl_type= 2;
            config18.cisl_type= 2;
            config19.cisl_type= 2;
            
            config20.cisl_type= 2;
            config21.cisl_type= 2;
            config22.cisl_type= 2;
            
            for i=1:7
                if(i == 1)
                    config = config14; %CISL - QAL
                elseif (i==2)
                    config = config15; %CISL - QAL
                elseif (i==3)
                    config = config16; %CISL - QAL 
                elseif (i==4)
                    config = config20; %CISL - QAQ *
                elseif (i==5)
                    config = config21; %CISL - QAQ *
                elseif (i==6)
                    config = config22; %CISL - QAQ *
                else
                    config = config16; %CISL - QAL
                end
                
                %{
                    v14 Particle and L-Alliance configuration
                    config.particle_controlType = 1; %better control
                    config.particle_resampleType = 2; %pruning resample
                    config.particle_weightType = 1; %exponential weight
                    config.particle_borderControlType = 1;   %keep particles in  
                    config.particle_resampleSortingType = 1; %resample based on best particles
                    config.particle_pastWeightAmount =0.95;                
                    config.particle_Number = 20;
                    config.particle_PruneNumber = floor(config.particle_Number/3) ;
                %}
                
                %v15 Particle and L-Alliance configuration
                config.particle_Used = 1;
                config.particle_ResampleNoiseSTD = 0.1;
                config.particle_ControlStd = 0.01;
                config.particle_SensorStd  = config4.robot_NoiseLevel + 0.05;
                config.particle_Number = 35;
                config.particle_PruneNumber = 7;
                config.lalliance_doStochasticLearning = 1;
                %end v15 Particle and L-Alliance configuration
                
            end
            
            this.configRun=[config1 config2 config3 config4 config5 config6 config7 config8 config9 ...
                 config10 config11 config12 config13 config14 config15 config16 ...
                 config17 config18 config19 config20 config21 config22 ...                
                 ];
            this. configLabels=['Basic           '; 'Noise=0.01      ';  'PF && Noise=0.01'];
        end
    end
    
end

