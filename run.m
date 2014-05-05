%{
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    %   Class Name
    %   
    %   Description 
    %   
    %   
    %   
    % x Save LAlliance Taus in a file
    % x Compare LAlliance with LAllianceMvAv (and merge) [same pretty much!]
    % 
    % 
    %***** New Particle Filter accroding to notes
    %
    %   Things to add
     - Comment the files
     - Create and design Simulation Dialog
     - configuration setup stored in mat files

            % Noise Level         0.00   0.06   0.10   0.20   0.30   0.40   
            % QAL &  CISL         1      2      5      8      10     12     
            % QAL & RCISL         x      3      6      9      11     13     
            % QAQ & RCISL & RCLA  x      14     15     16     (23)   (24)   
            % QAQ &  pf=1         17     18     19     (25)   (26)   (27)   
            % QAQ &  pf=0         20     21     22     (28)   (29)   (30)   
%}

clc;
clear all;
clear classes;

s = SimulationManager();
comps = s.AgentId();
s.SetProperty(comps ,'SimulationsPending',1);
s.SetProperty(comps ,'ShutdownPending',0);
s.SetProperty(comps ,'RunningSimulation',0);
s.SetStatus(comps ,'!!!');

%3 - particle filter
%2 - noise only
%1 - basic
%profile off;

     
% 10 PF setup
profile off;

t = cputime;

%s.RunTrial('newn');

%decrease robots
%c = Configuration.Instance(17);
%c.numRobots = 3;
%c.numTargets = 3;
%c.numTest = 3;
%c.numIterations = 30;
%Configuration.SetConfiguration(17,c);

%c = Configuration.Instance(1);
%c.numRobots = 3;
%c.numTargets = 3;
%c.numTest = 3;
%c.numIterations = 5000;

%Configuration.SetConfiguration(1,c);

%if(mod(comps,2)==1)
%    configs = [17 1];
%else
%    configs = [18];
%end

%c = Configuration.Instance(15);
%c.numRobots = 3;
%c.numTargets = 3;
%c.numTest = 3;
%c.numIterations = 30;
%Configuration.SetConfiguration(15,c);
%  (update matrix after each assignment)

configs = [ 1001 1002 1005 1008 1010 1012];
innerLabel = 'valid5';

for test=1:size(configs,2)

    configid = configs(test);
    s = SimulationManager();
    s.SetProperty(comps ,'SimulationsPending',1);
    s.SetProperty(comps ,'ShutdownPending',0);
    s.SetProperty(comps ,'RunningSimulation',0);
    s.SetStatus(comps ,'!!!');
    label = strcat('v19_',num2str(test),'_',innerLabel,num2str(s.AgentId()),'_confgv2_',num2str(configid),'_');
    c = Configuration.Instance(configid);
    s.RunTrial(label,configid );
    
end

tf = cputime- t







