msg = char(5,2000);
clc;

for i=1:9
    agentFile = 'c7';
    agentFile = strcat(agentFile,num2str(i));
    load(agentFile);
    msgIn = strcat('c7',num2str(i),' :',messageOut);
    
    msg (i,1:size(msgIn,2)) =msgIn;
end
disp(msg)