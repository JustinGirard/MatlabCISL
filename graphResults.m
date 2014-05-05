
%Print results from a test
clc;
clear all;
clear classes;
numMax=1;
letter = ['a' 'b' 'c'];
runs = 80;


dataRms = zeros(runs ,1);
dataRwd = zeros(runs ,1);

for letterNum=1:size(letter,1)
    for num=1:numMax

        filename = strcat('ms_parr_',letter(letterNum),num2str(num));
        load(filename);
        filename = strcat('rd_parr_',letter(letterNum),num2str(num));
        load(filename);
        dataRms = dataRms + rms(1:runs);
        dataRwd = dataRwd + rwd(1:runs);

    end
end

avgRms=dataRms./num;
avgRwd=dataRwd./num;

rwdPerRms = avgRwd./avgRms;

y=moving(avgRms,10);
plot(y);
