%{

****** VERSION 10 Build 003
*****************************

Things to add
- Clustering for state! Why didn't I think of that earlier.
- PCA for state. ALSO why didn't I think of that earlier. GOD!
- Should be able to reduce dimensionality significantly.


Next Steps:
L-Alliance Task:
XXX Add box type into config
XXX have 4 robot types
XXX robot types are displayed in simulation
XXX weak robot cant push heavy box
XXX box and robot type part of q-learning space
XXX L-Alliance mechanism resets properly
XXX L-Alliance mechanism works

wbn - fix so sizes work properly from config->simulation
wbn - uses proper probabilistic action select
wbn - world state / robot state has better arguments returned
wbn - remove constants (should follow merger of WS into one array)


Next Steps
- Refactor world state to use single matrix
- refactor learning to all store data through world state
- make noise object, instead of routine
- make PF object, instead of routine

- finish Q values
- Make better utility storage mechanism
- finish motivation, so it works more sensibly
- Add in advice exchange mechanism
- speed profile and speed up

%}

clc;
clear all;
clear classes;

comps = [50:51 ]; %

s = SimulationManager();
s.SetProperty(comps ,'SimulationsPending',1);
s.SetProperty(comps ,'ShutdownPending',0);
s.SetProperty(comps ,'RunningSimulation',0);
s.SetStatus(comps ,'!!!');

%3 - particle filter
%2 - noise only
%1 - basic
%profile off;
profile on -memory;
profile clear;

t = cputime;

config4  = ConfigurationRun();
config4.numIterations = 1000;
config4.numTest = 1;
config4.particle_Used = 0;
config4.numRobots = 12;
config4.numTargets = 12;
config4.particle_ResampleNoiseSTD = 0.02;
config4.robot_NoiseLevel = 0.1;

config4.robot_NoiseLevel = 0.1;
config4.particle_ResampleNoiseSTD = 0.05;
config4.particle_ControlStd = 0.01;
config4.particle_SensorStd  = config4.robot_NoiseLevel + 0.05;
config4.particle_Number = 35;
config4.particle_PruneNumber = 7;

%testPfStd = [0 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010 0.011 0.012 0.013 0.014 0.015 0.016 0.017 0.018 0.019 0.020];
testPfStd = [0 0.001 0.01 0.05 0.1 0.15 0.2 0.4];


testNoise = [0 ...
   0.060000000000000 ...
   0.100000000000000 ...
   0.200000000000000 ...
   0.400000000000000 ...
   0.550000000000000 ];

%{
testPfStd = [      0.00015 ...
   0.000100000000000 ...
   0.000200000000000 ...
   0.000300000000000 ...
   0.000400000000000 ...
   0.000500000000000 ...
   0.000600000000000 ...
   0.000700000000000 ...
   0.000800000000000 ...
   0.000900000000000 ...
   0.001000000000000 ...
   0.001100000000000 ...
   0.001200000000000 ...
   0.001300000000000 ...
   0.001400000000000 ...
   0.001500000000000 ...
   0.001600000000000 ...
   0.001700000000000 ...
   0.001800000000000 ...
   0.001900000000000 ...
   0.002000000000000];
%}

results = zeros(size(testNoise,2),size(testPfStd,2));

for iNoise=1:size(testNoise,2)
    for iPf=1:size(testPfStd,2)
        ns = testNoise(iNoise)
        pf = testPfStd (iPf)
        if(testPfStd (iPf) == 0)
            config4.particle_Used = 0;
        else
            config4.particle_Used = 1;
        end

        config4.particle_ResampleNoiseSTD = testPfStd (iPf);
        config4.robot_NoiseLevel = testNoise(iNoise);
        config4.particle_SensorStd  = config4.robot_NoiseLevel + 0.05;

        Configuration.SetConfiguration(4,config4);

        s = SimulationManager();
        %s.RunTrial('newn');
        configid = 4;
        label = 'TestTime3';
        doSave = 0;
        s.RunTrial(label,configid,doSave  );
        distance = sum(s.simulation.learningDataAverages(:,7))/4;
        results(iNoise,iPf) = distance; 
        s.SetProperty(comps ,'SimulationsPending',1);
        s.SetProperty(comps ,'ShutdownPending',0);
        s.SetProperty(comps ,'RunningSimulation',0);
    end

    save('PF35v15Full6','results')
    save('PF35v15Full6','testNoise','-append')
    save('PF35v15Full6','testPfStd','-append')
    %save('PF35v15Full5','testPfType','-append')

end
    %rows - noise
%cols - particle filter level



%tf = cputime- t