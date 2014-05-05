%{

****** VERSION 9 Build 002
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

numMax = 15;



%clc;
%clear all;
%clear classes;

%3 - particle filter
%2 - noise only
%1 - basic
for num=1:10
    number = strcat('Total Test ',num2str(num));
    disp(number);
    configList = [1];

    %profile on;
    %profile clear;

    simulation = Simulation(configList);
    simulation.Run('test1');
    label = 'test1';
    %save(strcat(label,'millis'), 'runMillisecondsAverages');      
    %save(strcat(label,'reward'), 'runTotalRewardAverages');      

    %configId = 3;
    %showid = 3;
    %createNewRobots = 0;
    %simulation.RunSimulation(configId,showid,createNewRobots );
    filenameMS = strcat('ms_single_103_',num2str( num));
    filenameRD = strcat('rd_single_103_',num2str( num));
    rms = simulation.runMillisecondsAverages;
    rwd = simulation.runTotalRewardAverages;
    save (filenameMS, 'rms');
    save (filenameRD, 'rwd');
    
end



%{
%Print results from a test
clc;
clear all;
clear classes;
data = zeros(135,1);

num =1;
for num=1:7
    filename = strcat('config135_',num2str(num));
    load(filename);
    data = data + simulation.runTotalRewardAverages;
    
end
plot(data./num);

%}







