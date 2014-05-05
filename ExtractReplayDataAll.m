file = 'March4v25b_a_1_51_confgv2_21123313_AER-DEV24';
fileTypeString = '_iter_targ_';
forceUpdate = 1;
dp = DataProcessor();
dp.UpdateFileWithCoopData(file,forceUpdate);



fadfaaggagda %poor man's "stop here"

cd('results');
files = dir(strcat('*',fileTypeString,'*.mat'));
cd('..');

for i=1:size(files,1)
    fileName = files(i).name;
    index = findstr('_iter_targ_',fileName);
    file = fileName(1: index -1);
    dp = DataProcessor();
    %dp.UpdateFileWithCoopData(file,forceUpdate);
    
    dp.ResultsCopy(file);
end



   