classdef DisjointHashtable < handle
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
        function this = DisjointHashtable(sizeIn)
                
                this.arrSize = 2^sizeIn;
                this.bits = log(this.arrSize) / log(2);
                %this.data = sparse(this.arrSize,2,0);
                this.data = zeros(this.arrSize,2);
                
                this.keySize = 0;
        end
        
        %reset the array
        function Reset(this)
            this.data = zeros(this.arrSize,2);
        end
        
        
        % Get the array index for a certain key vector
        function keyInt = GetKey(this,keyVector)
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
        end
        
        
        function  Put(this,keyVector,valueInt)
            
            key = this.GetKey(keyVector);
            
            experience = this.data(key,2) + 1;
            this.data(key,1:2) = [valueInt experience];
            
        end
        
        function [valueInt] = Get(this,keyVector)
            key = this.GetKey(keyVector);
            if key == 0
                key = 1;
            end
            value = this.data(key,1);
            experience = this.data(key,2);
            valueInt = [value experience];
        end
        
        function val =GetElements(this)
            val = this.data(:,1);
        end
        
    end
    
end


