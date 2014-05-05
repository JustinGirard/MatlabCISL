name = 'orig';
fileTypeString = '_graph_data';
fdgsgdgsssggsgds CRASH
files = dir(strcat('*',fileTypeString,'*.mat'));
for j=1:size(files,1)
    name = files(j).name;
     

    load(name);

    dat2 = dat;

    for i=1:size(dat2,1)
        dat2{i,62}=dat2{i,17};
        dat2{i,17} = '';
        dat2{i,63}=dat2{i,18};
        dat2{i,18} = '';
    end
    dat = dat2;
    clear dat2
    strcat(name,fileTypeString)    

    save(strcat(name,fileTypeString),'name');
    save(strcat(name,fileTypeString),'dat','-append');
    save(strcat(name,fileTypeString),'XAxisLabel','-append');
    save(strcat(name,fileTypeString),'YAxisLabel','-append');
    save(strcat(name,fileTypeString),'graphLabel','-append');
    save(strcat(name,fileTypeString),'XLimit','-append');
    save(strcat(name,fileTypeString),'YLimit','-append');
    save(strcat(name,fileTypeString),'RunLimit','-append');

end
