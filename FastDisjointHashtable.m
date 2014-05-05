classdef FastDisjointHashtable < handle
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
        bitsPerNumber = 0;
        maxInt = 0;
        arrExp = [];
    end
    
    methods (Static)

        function [valueInt] = GetStatic(instList,keyVectors)
            keys = FastDisjointHashtable.GetKeyStatic(instList,keyVectors);
            
            dat = [instList.data];
            dat3d = dat(:,1:2);
            dat3d(:,:,2) = dat(:,3:4);
            dat3d(:,:,3) = dat(:,5:6);
            dat3d(:,:,4) = dat(:,7:8);
            size(dat3d)
            %value = instList.data(keys,1);
            %value
            %experience = instList.data(keys,2);
            %experience
            values = [ dat3d(keys(1),1,1) dat3d(keys(2),1,2) dat3d(keys(3),1,3) dat3d(keys(4),1,4)];
            experience = [ dat3d(keys(1),2,1) dat3d(keys(2),2,2) dat3d(keys(3),2,3) dat3d(keys(4),2,4)];
            valueInt = [values' experience'];
        end    

        % Get the array index for a certain key vector
        function keyInt = GetKeyStatic(instList,keyVector)
            maxInts = [instList.maxInt]';
            arraySize = [instList.arrSize]';  
            %arrExponential = [instList.arrExp]';    
            %hardcode
            arrExponential = [0 1 128; 1 32 243; 1 32 243; 0 1 128];
            numbers = bsxfun(@mod,keyVector,maxInts );
            
            
            
            key = bsxfun(@times,numbers,arrExponential  );
            key
            
            key = sum(key,2);
            arrKey= key;
            adjust = (arrKey >= arraySize );
            isZero =  (arrKey == 0);
            arrKey = arrKey - adjust + isZero;
            keyInt = arrKey;
            
        end
        
    end
    
    
    methods
        %create a hashtable with a certain size
        function this = FastDisjointHashtable (sizeIn,vectorSize)
            this.arrSize = 2^sizeIn;
            this.bits = log(this.arrSize) / log(2);
            %this.data = sparse(this.arrSize,2);
            this.data = zeros(this.arrSize,2);
            this.keySize = vectorSize;

            this.bitsPerNumber = floor(this.bits / this.keySize);
            this.maxInt = 2^this.bitsPerNumber;
            
            i = 1;
            while (i <= vectorSize)
                this.arrExp = [this.arrExp; i^this.bitsPerNumber;];
                i= i+1;
            end
                
        end
        
        %reset the array
        function Reset(this)
            %this.data = zeros(this.arrSize,2);
            this.data = sparse(this.arrSize,2);
        end
        
        
        % Get the array index for a certain key vector
        function keyInt = GetKey(this,keyVector)
            
            numbers = mod(keyVector,this.maxInt);
            
            key = numbers*this.arrExp;
            
            
            
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


