clear all;
clc;
sr = SimResults();


graphType = 'AverageSimulationIterations';
profile = '3RobotTest';

doNewVersion = 0;
                
if(strcmp(graphType, 'AverageSimulationIterations')==1)
    graphtype = 1;
    axisType = [0,300,0,16000];    
    if(strcmp(profile, '3RobotTest')==1)
        axisType = [0,100,0,5000];
    end

elseif(strcmp(graphType, 'TotalAgentActions')==1)
    graphtype = 2;
    axisType = [0,300,0,160000];    
    if(strcmp(profile, '3RobotTest')==1)
        axisType = [0,100,0,5000];
    end

elseif(strcmp(graphType, 'AverageMaximumSimulationIterations')==1)
    graphtype = 3;
    axisType = [0,300,0,160000];    
    if(strcmp(profile, '3RobotTest')==1)
        axisType = [0,100,0,5000];
    end

elseif(strcmp(graphType, 'MaximumAndMinimumAverageSimulationIterations')==1)        
    graphtype = 4;
    axisType = [0,300,0,160000];
    if(strcmp(profile, '3RobotTest')==1)
        axisType = [0,100,0,5000];
    end

elseif(strcmp(graphType, 'MaximumAndMinimumTotalAverageIndividualActions')==1)        
    graphtype = 5;
    axisType = [0,300,0,160000];

    if(strcmp(profile, '3RobotTest')==1)
        axisType = [0,100,0,2000];
    end
    
elseif(strcmp(graphType, 'IncorrectActions')==1)        
    graphtype = 6;
    axisType = [0,100,0,0.00005];

elseif(strcmp(graphType, 'ExpectedFalseReward')==1)        
    graphtype = 7;
    axisType = [0,100,0,1];
    
elseif(strcmp(graphType, 'ExpectedChangedReward')==1)        
    graphtype = 8;
    axisType = [0,100,0,1];
    
elseif(strcmp(graphType, 'ExpectedTrueReward')==1)        
    graphtype = 9;
    axisType = [0,100,0,1];
    
elseif(strcmp(graphType, 'ExpectedChangedTrueReward')==1)        
    graphtype = 10;
    axisType = [0,100,0,10];

elseif(strcmp(graphType, 'AverageRewardPerAction')==1)        
    graphtype = 11;
    axisType = [0,100,0,5];
    
elseif(strcmp(graphType, 'AverageQualityPerAction')==1)        
    graphtype = 12;
    axisType = [0,100,0,5];
        
end

if(strcmp(profile, '3RobotTest')==1)
    runs = 100;

    list = [10 11; ... 
            10 12; ... 
            10 13; ... 
            10 14; ... 
            10 15]; 
else
    runs = 300;
    list = [1 2; ... 
            1 3; ... 
            1 4; ... 
            1 5; ... 
            1 6]; 
end
if(doNewVersion ==1)
    list = list+15;
end

for i=1:size(list,1)
    figure();
    sr.GraphResults(graphtype,runs,axisType,list(i,:));
end