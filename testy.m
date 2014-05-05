
%te = 0;


%fdsgdsgsdgsdf
load('knnData')

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
cNumber = 9;
datDimension = 6;

gmmCentroids = [];
gmmWeights = [];
gmmDirections = [];
gmmCovariance = [];

for i=st:ed
    x = cos(i/2);
    y = sin(i/2);
    refData = [itemXY(direction == i,:) obsXY(direction == i,:) goalXY(direction == i,:)];
    [Wt,M,Cov] = GMmodel(refData,cNumber );
    gmmCentroids=[gmmCentroids;M]
    gmmWeights=[gmmWeights;Wt];
    gmmDirections =[gmmDirections; ones(cNumber,1).*x ones(cNumber,1).*y];
    stInd = (i-st)*cNumber;
    
    gmmCovariance (:,:,stInd +1:stInd+cNumber) = Cov;
    
    for cen=1:size(M,1)
        hold on;
        plot([M(cen,1);M(cen,1) + x*3],[M(cen,2);M(cen,2) + y*3]);
        plot([M(cen,1);M(cen,1) + x*0.5],[M(cen,2);M(cen,2) + y*0.5],'LineWidth',3);
    end
    drawnow;
end

save('gmmData','gmmCentroids');
save('gmmData','gmmWeights','-append');
save('gmmData','gmmDirections','-append');
save('gmmData','gmmCovariance','-append');



