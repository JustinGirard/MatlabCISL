classdef ParticleFilter < handle
    %PARTICLEFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numParticles = 10;
        numSpawnedParticles = 5;
        %noiseLevel = 0;
        standardDeviation = 0;

        actionArray = 0;
        particles = [0];
        dimension = 0;
        weights = [];
        % [Upper bound(dimension); Lower bound(dimension)]
        bounds = [];
        pruneThreshold = 10;
        dimensionSizes = [];
        pastSample = [];
        uninitalized = 1;
        numVeocityPoints = 30;
        noiseFactor = 0;
        
        controlType = 0;
        resampleType = 0;
        weightType = 0;
        borderControlType = 0;
        resampleSortingType = 0;
        pastWeightAmount = 0;
         
    end
    
    
    methods
        
        % Generic Particle Filter Class
        % Ensures we know what is going in in our environment
        function this = ParticleFilter()
            this.uninitalized  = 1;
        end
        
        function Initalize(this,boundsIn, c,initialReading)
            
            numParticlesIn = c.particle_Number;
            pruneNumber= c.particle_PruneNumber;
            this.controlType = c.particle_controlType;
            this.resampleType = c.particle_resampleType;
            this.weightType = c.particle_weightType;
            this.resampleSortingType = c.particle_resampleSortingType;
            
            this.borderControlType = c.particle_borderControlType;
            this.pastWeightAmount = c.particle_pastWeightAmount;
            
            
            this.pruneThreshold=pruneNumber;
            this.uninitalized  = 0;
            this.numParticles = numParticlesIn;
            dimVector = size(boundsIn);
            this.bounds = boundsIn;
            this.dimensionSizes = boundsIn(1,:) - boundsIn(2,:);
            this.dimension = dimVector(2);
            this.particles =  zeros(1,this.dimension);
            %this.noiseLevel = c.particle_ResampleNoiseMean;
            this.standardDeviation = c.particle_ResampleNoiseSTD;
            this.noiseFactor = sqrt( this.standardDeviation ) ;
            %First we bring the population up to par, if it's under
            % using random uniform beliefs            
            particleSize = size(this.particles);
            if(~isnan(initialReading))
                if(particleSize(1) < this.numParticles)
                    for i= 1:particleSize(2)
                        randCol = randn(this.numParticles ,1 )*this.noiseFactor;
                        randVals(:,i)= randCol;
                    end
                    this.particles = bsxfun(@plus,randVals,initialReading);
                end
            else
                if(particleSize(1) < this.numParticles)
                    start = particleSize(1)+1;
                    for i=start:this.numParticles
                        this.particles(i,:) = rand(1,this.dimension).*this.dimensionSizes  + this.bounds(2,:);
                    end
                end
            end
            this.weights = ones(this.numParticles,1);
            
        end
        
        
        
        function ControlSignal(this,controlVector)
            if(this.controlType == 1)
                partsMoved = bsxfun(@plus,this.particles,controlVector);
                this.particles = [this.particles ;  partsMoved ];
                this.weights = [this.weights;this.weights];
            else
                this.particles = bsxfun(@plus,this.particles,controlVector);
            end
            
            if (this.borderControlType ==1)
                sz = size(this.particles );
                for j=1:sz(2)
                    outside1 = (this.particles(:,j) > this.bounds(1,j));
                    outside2 = (this.particles(:,j) < this.bounds(2,j));
                    inside = outside1 + outside2;
                    inside = (inside > 0);
                    inside = 1 - inside;
                    this.particles(:,j) = outside1.*this.bounds(1,j) + outside2.*this.bounds(2,j) + inside.*this.particles(:,j) ;
                end
                
                %for i=1:sz(1)
                %    for j=1:sz(2)
                %        if(this.particles(i,j) > this.bounds(1,j))
                %            this.particles(i,j) = this.bounds(1,j);
                %        end
                %        if(this.particles(i,j) < this.bounds(2,j))
                %            this.particles(i,j) = this.bounds(2,j);
                %        end
                %    end
                %end
            
            end
            
            
            %don't allow partices out of the boundry
        end
        
        function Resample(this)
            %First, using weights, we prune samples that seem to be kinda
            %bad.
            %grp2 = sum(this.velocityPoints(this.numVeocityPoints/2:this.numVeocityPoints,:),1)/(this.numVeocityPoints/2);
            
            %drift = norm(grp1 - grp2)/this.noiseLevel;
            %noise = this.noiseLevel;
            %drift
            %if(drift > 10)
               % noise = this.noiseLevel *(1+ (drift)/40);
            %else
            %    clc;
            %end
            %drift = grp1- grp2; %looks like we are moving somewhere maybe?
            %we can use that slope to push the particles along...
            
            
            %delete from biggest to smallest index
            
            % this.numParticles - 
            [sortedWeights,index] = sort(this.weights);
            pruneAmount =0;
            if(size(this.particles,1) > this.numParticles )
                pruneAmount = size(this.particles,1) -  this.numParticles ;
            end
            
            pruneAmount = pruneAmount + this.pruneThreshold;
            %index = index(1:pruneAmount );
            %index = sort(index,'descend');
            %this.particles(index(1:this.pruneThreshold),:) = [];
            %this.weights(index(1:this.pruneThreshold),:) = [];

            index = index(pruneAmount:size(this.particles,1));
            this.particles = this.particles(index ,:);
            this.weights=this.weights(index ,:);

            %for i=1:this.pruneThreshold
            %    this.particles(index(i),:) = [];
            %    this.weights(index(i),:) = [];
            %end
            
            %{
            keepAmount = this.numParticles - this.pruneThreshold;
            index = index(1:keepAmount  );
            index = sort(index,'ascend');
            this.particles = this.particles (index(1:keepAmount),:) ;
            this.weights = this.weights (index(1:keepAmount),:) ;
            %}
            
            %Second, we bring the population up to par, if it's under
            % using random uniform beliefs            
            particleSize = size(this.particles);
            particleSize 
            %newParts = this.particles + rand(particleSize(1),particleSize(2))*noise  - 0.5*noise  ;
            randVals = zeros(particleSize(1),particleSize(2));

            
            
            for i= 1:particleSize(2)
                randCol = randn(particleSize(1) ,1 )*this.noiseFactor   ;
                randVals(:,i)= randCol;
            end
            
            newParts = this.particles + randVals;
            newWeights = this.weights;
            if(this.resampleSortingType ==1)
                [sortedWeights,index] = sort(this.weights,'descend');
                newParts = newParts(index,:); 
            end
            
            j = 1;
            if(particleSize(1) < this.numParticles)
                start = particleSize(1)+1;
                %include random particles, branched from our current
                %beliefs randomly
                this.particles = [this.particles; zeros(this.numParticles-particleSize(1),particleSize(2))];
                this.weights = [this.weights; zeros(this.numParticles-particleSize(1),1)];
                    
                for i=start:this.numParticles
                    j = mod(j,size(newParts,1));
                    if(j == 0); j =1; end;
                    this.particles(i,:) = newParts(j,:);
                    this.weights(i,:) =  newWeights(j,:);
                    j = j+1;
                end
                
                %Include one purely random particle, just to help handle
                %teleportation (if it happens ever)
               % this.particles(i,:) = rand(1,this.dimension).*this.dimensionSizes + this.bounds(2,:);
            end            
            
            
            
            particleSize = size(this.particles);
            randVals = zeros(particleSize(1),particleSize(2));
            %this.particles = this.particles + rand(particleSize(1),particleSize(2))*noise - 0.5*noise;
            for i= 1:particleSize(2)
                randCol = randn(particleSize(1) ,1 )*this.noiseFactor    ;
                randVals(:,i)= randCol ;
            end
            this.particles  = this.particles + randVals;
            %this.particles = bsxfun(@plus,this.particles,drift*0.1);
            %this.velocityPoints = bsxfun(@plus,this.velocityPoints,drift*0.1);

            
        end

        function UpdateBeliefs(this,reading)
           
           %include a new particle that represents current belief
           if(this.resampleSortingType ==1)
               this.particles(size(this.particles,1)+1,: ) = reading;
               this.weights(size(this.weights,1)+1,: ) = 0;
           end
           lastWeights = this.weights;
           
           this.weights = bsxfun(@minus, this.particles, reading);
           this.weights = abs(this.weights);
           
           if(this.weightType == 0)
                this.weights = 1./(abs(this.weights(:,1).^2+this.weights(:,2).^2)+10);
           elseif (this.weightType == 1)
                this.weights = 1./(sqrt(this.weights(:,1).^2+this.weights(:,2).^2)+10);
           end
           
           this.weights = lastWeights.*this.pastWeightAmount+ (1-this.pastWeightAmount).*this.weights;
           %this.weights = this.weights / sum(this.weights);
           %this.weights 
           %this.particles
        end
        
        function UpdateBeliefsBlind(this)
           this.weights = this.weights / sum(this.weights);
           %this.weights 
           %this.particles
        end
        

        
        function data = Sample(this)
            this.weights = this.weights / sum(this.weights);
            
            data = bsxfun(@times,this.particles, this.weights);
            data = sum(data);

            
            %keep track of our values
            
        end
        
        
        %just a little method used to visulize results and usage
        function UnitTest(this)
                clc;
                clear all;
                
                p = ParticleFilter();
                bounds = [10 10; -10 -10];
                sensorNoise = 0.1;
                controlNoise = 0.3;
                sensorFreq = 20;
                
                p.Initalize(bounds, 10,0.2 );
                i = 1;
                data = [];
                sensorRead = [];
                pos = [-7 2];
                controlSignal = [-0.01 0.01];
                
                %Particle Filter Usage
                while i < 300
                    latestRead = 0;
                    p.Resample();
                    errControl = controlSignal+ rand(1,2)* controlNoise - controlNoise*0.5;
                    p.ControlSignal(controlSignal);

                    pos = pos + controlSignal;
                    errPos = pos+ rand(1,2)*sensorNoise - 0.5*sensorNoise;
                    
                    if(mod(i,sensorFreq) == 0 || i == 1)
                        p.UpdateBeliefs( errPos);
                        latestRead = 1;
                    else
                        p.UpdateBeliefsBlind();
                    end
                        data = [data;pos p.Sample() errControl+errPos latestRead];


                    i = i+1;
                end

                plot(data);        
        end
        
    end
    
end

