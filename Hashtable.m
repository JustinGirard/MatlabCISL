classdef Hashtable < handle
    %HASHTABLE (multidimensional)
    %   Hash a vector of any dimension into a real numbered key-value pair
    %   probably does not work very as much data loss can occour.
    
    
    properties
        
        arrSize = 100;
        data = [];
        bits = log(100) / log(2);
        collisions = 0;
        updates = 0;
        assignments = 0;
        keySize = 0;
    end
    
    methods
        %create a hashtable with a certain size
        function this = Hashtable(sizeIn)
                
                this.arrSize = 2^sizeIn;
                this.bits = log(this.arrSize) / log(2);
                %this.data = sparse(this.arrSize,2,0);
                %this.data = sparse(this.arrSize,4);                 
                this.data = zeros(this.arrSize,4);
                this.keySize = 0;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function Reset(this)
            this.data = zeros(this.arrSize,4);
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        % Get the array index for a certain key vector
        function [keyInt,keyInt2] = GetKey(this,keyVector)
            %bitsSize = [0 0];
            %keyInt = keyVector(1)*1000 + keyVector(2)*100 + keyVector(3)*10 + keyVector(3)*1;
            %return;
            
            
            if(this.keySize ==0)
                [bitsSize ] = size(keyVector);
                this.keySize = max(bitsSize);
            end
                
            bitsPerNumber = floor(this.bits / this.keySize);
            maxInt = 2^bitsPerNumber;
            numbers = mod(keyVector,maxInt);
            i = 1;
            key = 0;
            while i <= this.keySize 
                key = key + numbers(i)*(i^bitsPerNumber);
                i = i +1;
            end
            
            arrKey= key;
            if(arrKey >= this.arrSize)
                arrKey = this.arrSize-1;
            end
            if arrKey == 0
                arrKey =1;
            end
            
            keyInt = arrKey;
            sz = size(arrKey);
            arrKey(sz(2)) = 1;
            keyInt2 = arrKey;
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function  Put(this,keyVector,valueInt)
            
            [key,key2] = this.GetKey(keyVector);
            
            experience = this.data(key,2) + 1;
            experience2 = this.data(key2,4) + 1;
            
            this.data(key,1:2) = [valueInt experience];
            this.data(key2,3:4) = [valueInt experience2];
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function valueInt = Get(this,keyVector)
            [key,key2] = this.GetKey(keyVector);
            if key == 0
                key = 1;
            end
            experience = [this.data(key,2)  this.data(key2,4)]; 
            if(experience(1) > 100)
                experience(1) = 100;
            end
            if(experience(2) > 10)
                experience(2) = 10;
            end
            experience = experience / sum(experience);
            valueInt = this.data(key,1)*experience(1) + this.data(key2,3)*experience(1);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function value = OccupancyPercentage(this)
            spread = this.data ~= 0;
            spread = sum(spread);
            value = spread/ this.arrSize;

        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function val =GetElements(this)
            val = this.data(:,1);
        end
        
    end
    
end


