

%hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
label ='C7';
commandPending = [1 0 0 0 0 0 0 0 1];
shutdownPending = [1 0 0 0 0 0 0 0 0];

%shutdown -t 0 -r -f



%turn on 2 simulations
for i=1:9
    fileName = strcat(label,sim2str(i));
    SimulationsPending =commandPending(i);
    ShutdownPending =shutdownPending(i);
    save(strcat('',fileName), 'SimulationsPending','-append');
end

SimulationsPending =1;
ShutdownPending = 1;
hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
save(strcat('',hostname), 'SimulationsPending');

commandPending = zeros(9,1)
shutdownPending = zeros(9,1)



%turn on 2 simulations
%for i=1:9
%    fileName = strcat(label,sim2str(9));
%    SimulationsPending =0;
%    save(strcat('',hostname), 'SimulationsPending');
%end

for i=1:9
    fileName = strcat(label,sim2str(i));
    load(strcat('',fileName), 'SimulationsPending','ShutdownPending');
    commandPending(i) = SimulationsPending;
    shutdownPending(i) = ShutdownPending;
end

commandPending= commandPending
shutdownPending= shutdownPending
