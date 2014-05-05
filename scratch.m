
x =[];
y=[];
z=[];

ts = 1000;
theta = 99.9;
k = log(theta) - log(100 - theta);

for i=1:1000
    x =[x i];

    yn = exp((i*k)/(ts))/(1+(exp((i*k)/(ts) )));
    %yn = exp(i/(ts*k))/(1+(exp(i/(ts*k) )));
    zn = 1/(100-(exp(-i/100 )));
    y = [y yn];
    z = [z zn];
end

plot(y)
%plot(z)

%x =[];
%y=[];
%z=[];

%for i=1:300
%    x =[x i];
%    yn= round(50*exp((i-45)/20 )/(100+(exp((i-45)/20 ))))
    %yn = round(50*exp(i/100 )/(100+(exp(i/100 ))));
%    zn = 1/(exp((i)/30));

%    y = [y yn];
%    z = [z zn];
%end

%plot([y; z*50]')


%simulation.lastSimTest.robotLists(1).CISL.lalliance.s_tau.Get([10 1])


%system('RunTrial.exe'); %run executable with content of fname as inputs

%clc
clear all
%'SimulationsPending'
%'ShutdownPending'
comps = [0:23 ]; %50:51
%comps = [50:51 ]; %
%comps = 15; 

s = SimulationManager();

%comps = s.AgentId();
%s.SetProperty(comps ,'SimulationsPending',1);
%s.SetProperty(comps ,'ShutdownPending',0);
%s.SetProperty(comps ,'RunningSimulation',0);
%s.SetStatus(comps ,'!!!');
%s.SetProperty([1] ,'SimulationsPending',1);

%s.SetProperty(s.AgentId(),'SimulationsPending',1);
%s.SetProperty(s.AgentId(),'ShutdownPending',0);XS
%s.SetProperty(s.AgentId(),'RunningSimulation',0);

        % SetProperty(this,agentIds,propertyLabel,value)
        %function [property] = GetProperty(this,agentIds,propertyLabel)
%s.SetProperty([10],'SimulationsPending',1);
%s.SetProperty([10],'RunningSimulation',0);

%[properties,messages] = s.GetProperties(comps);
%properties
%messages


%comps = find(1-properties(:,3)) -1

%s.SetProperty(comps ,'SimulationsPending',0);
%s.SetProperty(comps ,'ShutdownPending',0);
%s.SetProperty(comps ,'RunningSimulation',0);
%[properties,messages] = s.GetProperties(comps);
%properties






