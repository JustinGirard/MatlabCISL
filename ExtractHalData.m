clc;
cd('haldata')
fileList = dir('playDat*.mat');
cNumber = 5;
datDimension = 4;

beforeXY = [];
afterXY = [];
beforeOrient = [];
afterOrient = [];
itemXY = [];
goalXY = [];
obsXY = [];

for f = 1:size(fileList,1)
    fileName = fileList(f).name;
    load(fileName);
    disp(fileName)
    for d = 1:size(simDat,1)
        dataRow = simDat(d);
        dataRow.beforePos;
        dataRow.afterPos;
        if(dataRow.beforePos ~= dataRow.afterPos)
            beforeXY = [beforeXY;  dataRow.beforePos(1) dataRow.beforePos(3)];
            afterXY = [afterXY;  dataRow.afterPos(1) dataRow.afterPos(3)];
            goalXY = [goalXY; dataRow.goal(1) dataRow.goal(3)];
            itemXY = [itemXY; dataRow.item(1) dataRow.item(3)];
            obsXY = [obsXY; dataRow.obstacle(1) dataRow.obstacle(3)];
            beforeOrient = [beforeOrient ;  dataRow.beforeOrient];
            afterOrient = [afterOrient ;  dataRow.afterOrient];
        end
    end
end

cd('..')

displacementXY = afterXY - beforeXY; 
directionXY = bsxfun(@rdivide,displacementXY,sqrt(sum(displacementXY.^2,2)));
itemXY = itemXY - beforeXY;
goalXY = goalXY - beforeXY;
angXY = afterOrient - beforeOrient;
obsXY = obsXY -beforeXY;



%hold on
%scatter(displacementXY (:,1),displacementXY (:,2) ,'x');
%scatter(itemXY (:,1),itemXY (:,2) ,'o');
%scatter(goalXY (:,1),goalXY (:,2) ,'.');
%scatter(obsXY (:,1),obsXY (:,2) ,'.');


sd = sqrt(sum(displacementXY.^2,2)); %Filter out low displacement
sd = sd > 0.1;

itemXY=itemXY(sd,:);
directionXY=directionXY(sd,:);
displacementXY=displacementXY(sd,:);
obsXY=obsXY(sd,:);
goalXY=goalXY(sd,:);
%Filter End

sd = sqrt(sum(itemXY.^2,2)); %Filter out 'HasItem' moments
sd = sd > 0.3;

itemXY=itemXY(sd,:);
directionXY=directionXY(sd,:);
displacementXY=displacementXY(sd,:);
obsXY=obsXY(sd,:);
goalXY=goalXY(sd,:);
%Filter End


len = 37;


itemXYn = zeros(len*size(itemXY,1),2);
directionXYn = zeros(len*size(itemXY,1),2);
displacementXYn = zeros(len*size(itemXY,1),2);
obsXYn = zeros(len*size(itemXY,1),2);
goalXYn = zeros(len*size(itemXY,1),2);

for ang = 0:(len-1)
    %diff = [1 0]*r;
    te = (ang)*pi/18;
    r = [cos(te) sin(te); ...
        -sin(te) cos(te)]; 
    for in=1:size(itemXY,1)
        i=ang*size(itemXY,1);
        i = i+in;
        itemXYn(i,:)=itemXY(in,:)*r;
        directionXYn(i,:)=directionXY(in,:)*r;
        displacementXYn(i,:)=displacementXY(in,:)*r;
        obsXYn(i,:)=obsXY(in,:)*r;
        goalXYn(i,:)=goalXY(in,:)*r;   
    end
    ang
end




itemXY = itemXYn;
directionXY = directionXYn;
displacementXY = displacementXYn ;
obsXY = obsXYn;
goalXY = goalXYn;




%%%%%%%Zero Filter
sd = sqrt(sum(itemXY.^2,2)); %Filter out zeros (just being careful)
sd = (sd ==0);

itemXY=itemXY(sd,:);
directionXY=directionXY(sd,:);
displacementXY=displacementXY(sd,:);
obsXY=obsXY(sd,:);
goalXY=goalXY(sd,:);
%%%%%%%Zero Filter


disp('trans 1')
itemXYn(:,1) = itemXYn(:,1).*(-1);
directionXYn(:,1) = directionXYn(:,1).*(-1);
displacementXYn(:,1) = displacementXYn(:,1).*(-1);
obsXYn(:,1) = obsXYn(:,1).*(-1);
goalXYn(:,1) = goalXYn(:,1).*(-1);

itemXY = [itemXY;itemXYn];
directionXY = [directionXY ;directionXYn];
displacementXY = [displacementXY; displacementXYn];
obsXY =[obsXY; obsXYn];
goalXY =[goalXY; goalXYn];


disp('trans 2')
itemXYn(:,2) = itemXYn(:,2).*(-1);
directionXYn(:,2) = directionXYn(:,2).*(-1);
displacementXYn(:,2) = displacementXYn(:,2).*(-1);
obsXYn(:,2) = obsXYn(:,2).*(-1);
goalXYn(:,2) = goalXYn(:,2).*(-1);

itemXY = [itemXY;itemXYn];
directionXY = [directionXY ;directionXYn];
displacementXY = [displacementXY; displacementXYn];
obsXY =[obsXY; obsXYn];
goalXY =[goalXY; goalXYn];

disp('trans 3')
itemXYn(:,1) = itemXYn(:,1).*(-1);
directionXYn(:,1) = directionXYn(:,1).*(-1);
displacementXYn(:,1) = displacementXYn(:,1).*(-1);
obsXYn(:,1) = obsXYn(:,1).*(-1);
goalXYn(:,1) = goalXYn(:,1).*(-1);

itemXY = [itemXY;itemXYn];
directionXY = [directionXY ;directionXYn];
displacementXY = [displacementXY; displacementXYn];
obsXY =[obsXY; obsXYn];
goalXY =[goalXY; goalXYn];

%{

disp('scaling . . . ')
len = 4;
itemXYn = zeros(len*size(itemXY,1),2);
directionXYn = zeros(len*size(itemXY,1),2);
displacementXYn = zeros(len*size(itemXY,1),2);
obsXYn = zeros(len*size(itemXY,1),2);
goalXYn = zeros(len*size(itemXY,1),2);

for scl = 1:(len-1)
    sclFactor = scl-0.5;
    for in=1:size(itemXY,1)
        i=scl*size(itemXY,1);
        i = i+in;
        distO = sqrt(sum(obsXY(in,:).^2,2));
        %distG = sqrt(sum(goalXY(i,:).^2,2));
        distI = sqrt(sum(goalXY(in,:).^2,2));
        if(distI > distO+0.75)
            itemXYn(i,:)=itemXY(in,:).*sclFactor; %only scale item
            directionXYn(i,:)=directionXY(in,:);
            displacementXYn(i,:)=displacementXY(in,:);
            obsXYn(i,:)=obsXY(in,:);
            goalXYn(i,:)=goalXY(in,:); 
        end
        if(distO > distI+0.75)
            itemXYn(i,:)=itemXY(in,:); 
            directionXYn(i,:)=directionXY(in,:);
            displacementXYn(i,:)=displacementXY(in,:);
            obsXYn(i,:)=obsXY(in,:).*sclFactor;%only scale obstacle
            goalXYn(i,:)=goalXY(in,:); 
        end
        
    end
    disp('scaling . . . ')    
    sclFactor
end

itemXY = itemXYn;
directionXY = directionXYn;
displacementXY = displacementXYn ;
obsXY = obsXYn;
goalXY = goalXYn;

%itemXY DEBUG VIEW
%scatter(itemXY(:,1),itemXY(:,2),'X');
%}

%%%%%%%Zero Filter
sd = sqrt(sum(itemXY.^2,2)); %Filter out zeros (just being careful)
sd = (sd ==0);

itemXY=itemXY(sd,:);
directionXY=directionXY(sd,:);
displacementXY=displacementXY(sd,:);
obsXY=obsXY(sd,:);
goalXY=goalXY(sd,:);
%%%%%%%Zero Filter


disp('saving . . . ')

itemXY = itemXYn;
directionXY = directionXYn;
displacementXY = displacementXYn ;
obsXY = obsXYn;
goalXY = goalXYn;



save('knnData','itemXY');
save('knnData','goalXY','-append');
save('knnData','obsXY','-append');
save('knnData','directionXY','-append');
save('knnData','displacementXY','-append');

disp('complete')

direction = atan2(directionXY(:,2),directionXY(:,1));
direction = direction*2;
direction = round(direction); 



len = max(direction)-min(direction);
st = min(direction);
ed = max(direction);

%hold on
%scatter(UR(:,1),UR(:,2),'X');
%scatter(DR(:,1),DR(:,2),'.');
%scatter(UL(:,1),UL(:,2),'o');
%scatter(DL(:,1),DL(:,2));
%this.refData = [itemXY obsXY goalXY];
%scatter(itemXY(:,1),itemXY(:,2),'X');

gmmCentroids = [];
gmmWeights = [];
gmmDirections = [];
gmmCovariance = [];



for i=st:ed
    x = cos(i/2);
    y = sin(i/2);
    refData = [itemXY(direction == i,:) obsXY(direction == i,:)];% goalXY(direction == i,:)];
    cenWeightFactor = sum(direction == i,1)/size(itemXY,1);
    %refDataPart = [itemXY(direction == i,:) obsXY(direction == i,:) goalXY(direction == i,:)];
    [Wt,M,Cov] = GMmodel(refData,cNumber );
    gmmCentroids=[gmmCentroids;M]
    gmmWeights=[gmmWeights;Wt.*cenWeightFactor ]; %scale the weight to reflect the advice amount we got for this direction
    gmmDirAdd =[ones(cNumber,1).*x ones(cNumber,1).*y];
    gmmDirections =[gmmDirections; gmmDirAdd];
    stInd = (i-st)*cNumber;
    
    gmmCovariance (:,:,stInd +1:stInd+cNumber) = Cov;
    
    for cen=1:size(M,1)
        hold on;
        plot([M(cen,1);M(cen,1) + x*3],[M(cen,2);M(cen,2) + y*3]);
        plot([M(cen,1);M(cen,1) + x*0.5],[M(cen,2);M(cen,2) + y*0.5],'LineWidth',3);
    end
    drawnow;
    
    save('gmmData3','gmmCentroids');
    save('gmmData3','gmmWeights','-append');
    save('gmmData3','gmmDirections','-append');
    save('gmmData3','gmmCovariance','-append');
    gmmDirectionsNum = ed-st;
    gmmCenNum = cNumber ;    
    gmmDimension = datDimension;
    save('gmmData3','gmmDimension','-append');
    save('gmmData3','gmmDirectionsNum','-append');
    save('gmmData3','gmmCenNum','-append');
    
end






