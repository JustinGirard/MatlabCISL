
%
% First we see if we need to do a simulation.
%
%
%one, we copy the latest version to a new directory... jesus christ
%%%%dos('delete C:\justin\RunLocal\*.m')

%%%%dos('mkdir C:\justin\RunLocal\')
%%%%dos('mkdir C:\justin\RunLocal\results\')

%%%%dos('copy C:\justin\Dropbox\CISL\CISL_Run\*.m C:\justin\RunLocal\*.*')
%dos('copy C:\justin\Dropbox\CISL\CISL_v11_01\*.m C:\justin\RunLocal\*.*')
%%%%cd('C:\justin\RunLocal')
%runLoop
clear all;
c = clock;
%yeah, all this for seeding the random number generator. annoying.



%All that above, is to make sure NONE of the files are shared between
%matlab insstances... so this should be an isolated experiment!
s = SimulationManager();
%s.RunTrial('newn');
agentId = s.AgentId();

%every three computers does a different test
configid = mod(agentId,3)+1;
%configid=configid+3; %If this line is uncommented, we are doing a short run!
if(configid == 1)
    configid = 3;
elseif (configid == 2)
    configid = 6;
else 
    configid = 9;
end


label = strcat('v13_r1_confg',num2str(configid),'_');

s.RunTrial(label,configid );
exit



%{
clear all;

hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
load(strcat('instructions\',hostname), 'SimulationsPending');

if(SimulationsPending <= 0)
    'No Simulation'
    exit;
    %SimulationsPending = SimulationsPending -1;
    %save(strcat('',fileName), 'SimulationsPending');
end



numMax = 1;

hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
messageOut =strcat('Starting Test ',num2str(SimulationsPending));
save(strcat('status\',hostname), 'messageOut');

%3 - particle filter
%2 - noise only
%1 - basic
num = SimulationsPending;
try
    number = strcat('Total Test ',num2str(num));
    disp(number);
    configList = [1];
%[year month day hour minute seconds]
%this script will run all day. It checks to see if a task needs to be run.
%If so:
    c = clock;
    ts = c(2)+c(3)+c(4)+c(5);
    %profile on;
    %profile clear;

    simulation = Simulation(configList);
    simulation.Run('test1');

    name = 'FB_12_Robot_15000_iter_300Run_';
    name = strcat(name,hostname,'_');
    filenameITER = strcat('results\iter_',name,num2str( num),num2str(ts));
    filenameITER_TARG = strcat('results\iter_targ_',name,num2str( num),num2str(ts));
    filenameLD = strcat('results\learndat_',name,num2str( num),num2str(ts));
    
    
    
    %[simulationIterations sum(simulationRunActions) sum(simulationRunLearns) sum(simulationRewardObtained)]
    iterDat = simulation.runActionsAmount;
    iterDatTarg = simulation.runActionsAmountTarget;
    %alpha,gamma,expereince,quality(Q) , iteration,rewd
    learnDat = simulation.learningDataAverages;
    
    save (filenameITER, 'iterDat');
    save (filenameITER_TARG, 'iterDatTarg');
    save (filenameLD, 'learnDat');
catch err
    %
    % Save that we failed the trial...
    %
    hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
    load(strcat('instructions\',hostname), 'SimulationsPending');
    messageOut = strcat('ErrorWithLastTrial: ',num2str(SimulationsPending),':',err.message); 
    save(strcat('status\',hostname), 'messageOut');
    exit;
end

hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
load(strcat('instructions\',hostname), 'SimulationsPending');

%
% Save that we are finished this trial!
%

messageOut =strcat('Finished Test ',num2str(SimulationsPending));
save(strcat('status\',hostname), 'messageOut');


%
% Decrement the tests we have to do and quit
%
if(SimulationsPending > 0)
    SimulationsPending = SimulationsPending -1;
    save(strcat('instructions\',hostname), 'SimulationsPending');
end
%exit;
%}
