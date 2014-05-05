classdef HAL < handle
    %HAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lastAdvice = [];
        lastState = [];

        gmmSet = [];
        w = []; %weights 
        c = []; %covariance
        m = []; %means
        directions = []; %advice directions
        numDirections = 1;
        numCentroids = 1;
        
        %Some Behaviour Parameters
        adviceThresh = 1000;
        
    end
    
    methods
        function this = HAL()
            load('gmmData3')
            this.numDirections = gmmDirectionsNum;
            this.numCentroids = gmmCenNum;
            % *Thresh_* threshold: this.adviceThresh = 0.00001;
            % *Thresh2_* threshold: this.adviceThresh = 0.000001;
            % *Thresh3_* threshold: this.adviceThresh = 0.000015;            
            this.adviceThresh = 0.00001;

            this.gmmSet = [];
            
            for i=0:(this.numDirections-1)
                ind = [];
                for j=1:this.numCentroids
                    ind = [ind i*this.numCentroids+j];
                end
                this.gmmSet =[this.gmmSet; ind ];
            end
            
            this.w = gmmWeights;
            this.m = gmmCentroids;
            this.c = gmmCovariance;
            this.directions = gmmDirections;
        end
        
        function ForgetAdvisedVector(this)
            this.lastAdvice = [];
            this.lastState = [];
        end
        
        function [adviceP, direction] = GetAdvice(this,stateIn)
            stateIn = stateIn(1,1:4);
            adviceP = [];
            direction  = [];
            for i=1:size(this.gmmSet,1)
                a = GMMestimate( stateIn,this.m,this.c,this.w,this.gmmSet(i,:)' );
                adviceP(i,1)=a;
                direction(i,:) = this.directions(i*size(this.gmmSet,2),:);
            end
        end
        
        function vecXY = GetAdvisedVector(this,stateIn)
            [adviceP,directionsOut] = this.GetAdvice(stateIn);
            %adviceP
            [p_den,ind] = max(adviceP);
            vecXY =  directionsOut(ind,:);
            %vecXY
            this.lastState = stateIn;
            
            if(p_den > this.adviceThresh )
                vecXY =  directionsOut(ind,:);
                this.lastAdvice = vecXY;
            else
                vecXY =[0 0];
                this.lastAdvice = [0 0];
            end
        end
        
        function [vecXY,st] = GetLastAdvisedVector(this)
            vecXY = this.lastAdvice;
            st = this.lastState;
        end
        
    end
    
end

