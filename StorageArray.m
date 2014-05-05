classdef StorageArray < handle
    %HASHTABLE (multidimensional)
    %   Hash a vector of any dimension into a real numbered key-value pair
    %   probably does not work very as much data loss can occour.
    
    
    properties
        
        arrSize = 100;
        data = [];
        collisions = 0;
        updates = 0;
        assignments = 0;
        dimension = 1;
    end
    
    methods
        %create a hashtable with a certain size
        function this = StorageArray(sizeIn,dimensionality)
            this.arrSize = 2^sizeIn;

            if dimensionality == 1
                this.data = zeros(this.arrSize, dimensionality);
            elseif dimensionality == 2
                this.data = zeros(this.arrSize, this.arrSize);
            elseif dimensionality == 3
                this.data = zeros(this.arrSize, this.arrSize,this.arrSize);
            else %dimensionality == 4
                this.data = zeros(this.arrSize, this.arrSize,this.arrSize,this.arrSize);
            end
            
            this.dimension = dimensionality;
        end
        
        
        
        function  Put(this,keyVector,valueInt)
            if this.dimension == 1
                this.data(keyVector(1)) = valueInt;
            elseif this.dimension == 2
                this.data(keyVector(1),keyVector(2)) = valueInt;
            elseif this.dimension == 3
                this.data(keyVector(1),keyVector(2),keyVector(3)) = valueInt;
            else %this.dimension == 4
                this.data(keyVector(1),keyVector(2),keyVector(3),keyVector(4)) = valueInt;
            end
            
        end
        
        function valueInt = Get(this,keyVector)
            if this.dimension == 1
                valueInt = this.data(keyVector(1));
            elseif this.dimension == 2
                valueInt = this.data(keyVector(1),keyVector(2));
            elseif this.dimension == 3
                valueInt = this.data(keyVector(1),keyVector(2),keyVector(3));
            else %this.dimension == 4
                valueInt = this.data(keyVector(1),keyVector(2),keyVector(3),keyVector(4));
            end
            
        end
        
        function value = OccupancyPercentage(this)
            value = 0;
        end
        
        
        function val =GetElements(this)
            val = this.data(1);
        end
        
        function val = GetCollisions(this)
            val = this.collisions;
        end
        function val = GetAssignments(this)
            val = this.assignments;
        end
        function val = GetUpdates(this)
            val = this.updates;
        end
        
    end
    
end


