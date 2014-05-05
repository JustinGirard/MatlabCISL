%c = clock returns a six-element date vector containing the current date and time in decimal form:

%[year month day hour minute seconds]
%this script will run all day. It checks to see if a task needs to be run.
%If so:

s = SimulationManager();
s.RunAgent();

%{
c = clock;
dayStart = c(3);
dayNow = c(3);
delay = 20*60;

%{
mcc -o RunTrial -W WinMain:RunTrial -T link:exe -d C:\JustinData\Dropbox\CISL\CISL_Run\RunTrial\src -w enable:specified_file_mismatch -w enable:repeated_file -w enable:switch_ignored -w enable:missing_lib_sentinel -w enable:demo_license -v C:\JustinData\Dropbox\CISL\CISL_Run\runTrial.m
%}

while (dayStart == dayNow)
    dos('matlab -r runTrial -nodesktop -nosplash')
    pause(delay);
end

exit
%}