classdef GAIHashtable < handle
    %HASHTABLE (multidimensional)
    %   Hash a vector of any dimension into a real numbered key-value pair
    %   probably does not work very as much data loss can occour.
    
    
    properties
        
        arrSize = 100;
        data = FastDisjointHashtable.empty(4,0);
        
        bits = log(100) / log(2);
        collisions = 0;
        updates = 0;
        assignments = 0;
        keySize = 0;
    end
    
    methods
        %create a hashtable with a certain size
        function this = GAIHashtable(sizeIn,vecSize)
                
                this.arrSize = 2^sizeIn;
                this.bits = log(this.arrSize) / log(2);
                %this.data = sparse(this.arrSize,2,0);
                this.data(1) = FastDisjointHashtable(15,2);    %relative obstacle
                this.data(2) = FastDisjointHashtable(15,3);   %relative target with obstacle
                this.data(3) = FastDisjointHashtable(15,3);   %relative target with goal
                this.data(4) = FastDisjointHashtable(15,2);    %relative border data
                
                this.keySize = 0;
        end
        
        %reset the array
        function Reset(this)
                %this.data1 = FastDisjointHashtable(5,1);    %relative target
                %this.data2 = FastDisjointHashtable(10,2);   %relative target with obstacle
                %this.data3 = FastDisjointHashtable(10,2);   %relative target with goal
                %this.data4 = FastDisjointHashtable(5,1);    %relative border data
            
                this.data(1) = FastDisjointHashtable(15,2);    %relative target
                this.data(2) = FastDisjointHashtable(15,3);   %relative target with obstacle
                this.data(3) = FastDisjointHashtable(15,3);   %relative target with goal
                this.data(4) = FastDisjointHashtable(15,2);    %relative border data
        end
        
        function  Put(this,keyVector,valueInt)
            %{
             id= [this.EncodePos(targetPosEnc,orient )...
             this.EncodePos(goalPosEnc,orient )...
             this.EncodePos(borderPosEnc ,orient )...
             this.EncodePos(closestObs,orient)...   
             targetType
             ];            
            %}
            dat = this.data;
            dat(1).Put(keyVector([1 5]),valueInt);
            dat(2).Put(keyVector([1 4 5]),valueInt);
            dat(3).Put(keyVector([1 2 5]),valueInt);
            dat(4).Put(keyVector([3 5]),valueInt);
            
            
        end
        
        function valueInt = GetNew(this,keyVector)
            %datObj = this.data;
            %dat1 = datObj(1).Get(keyVector([1 5]));  %relative target
            %dat2 = datObj(2).Get(keyVector([1 4 5])); %relative target with obstacle
            %dat3 = datObj(3).Get(keyVector([1 2 5]));  %relative target with goal
            %dat4 = datObj(4).Get(keyVector([3 5])); %relative border data
            
            keyVectors =   [keyVector([1 5]) 0;   ...  %relative target
                            keyVector([1 4 5]); ...    %relative target with obstacle
                            keyVector([1 2 5]); ...     %relative target with goal
                            keyVector([3 5]) 0]; %relative border data
            
            dat = FastDisjointHashtable.GetStatic(this.data,keyVectors);
            maxWeight = [10 100 50 10]';
            
            expGreaterMax = (dat(:,2) > maxWeight);
            expLower = 1 - expGreaterMax;
            dat(:,2) = dat(:,2).*expLower + maxWeight.*expGreaterMax;
            
            dat(:,2) = dat(:,2) / sum(dat(:,2));
            
            valueInt = sum(dat(:,1) .* dat(:,2));
            %this.GetOld(keyVector);
            
        end        
        
        
        function [valueInt,experienceInt] = Get(this,keyVector)
            datObj = this.data;
            
            
            dat1 = datObj(1).Get(keyVector([1 5]));  %relative target
            dat2 = datObj(2).Get(keyVector([1 4 5])); %relative target with obstacle
            dat3 = datObj(3).Get(keyVector([1 2 5]));  %relative target with goal
            dat4 = datObj(4).Get(keyVector([3 5])); %relative border data
            
            maxWeight = [10 100 50 10];

            experience = [dat1(2) dat2(2) dat3(2) dat4(2)];
            experienceInt = min(experience);
            for i=1:4
                if(experience(i) > maxWeight(i))
                    experience(i) = maxWeight(i);
                end
            end
            experience = experience / sum(experience);
            val = [dat1(1) dat2(1) dat3(1) dat4(1)];
            valueInt = sum(experience .* val);
            
        end
        

        
    end
    
end


