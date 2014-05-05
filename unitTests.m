clc;
clear all;
longTests  = 0;


c = Configuration.Instance(1001);
%rb = RobotCommunication(c);
la = [LAllianceAgent(c,1) LAllianceAgent(c,2) LAllianceAgent(c,3)];

disp('***L-Alliance Tau Concensus test ');

for h=1:300
    la(1).SetTau(1,500-h);
    la(1).Broadcast();

    la(2).SetTau(1,300-h);
    la(2).Broadcast();

    la(3).SetTau(1,400-h);
    la(3).Broadcast();
    
    %Lallaince Data
    %disp('Post Iteration Data');
    data1 = [la(1).data(1,1,la.ti) la(1).data(2,1,la.ti) la(1).data(3,1,la.ti)];
    data2 = [la(2).data(1,1,la.ti) la(2).data(2,1,la.ti) la(2).data(3,1,la.ti)];
    data3 = [la(3).data(1,1,la.ti) la(3).data(2,1,la.ti) la(3).data(3,1,la.ti)];
    
    %[data1 ; data2 ; data3;]
    
    %Make sure L-Alliance maintains concensus
    if(sum(abs(data1 - data2)) ~= 0)
        error('Robots not in concensus 1');
    end
    if(sum(abs(data3 - data2)) ~= 0)
        error('Robots not in concensus 2');
    end
    
end
disp('--- pass');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ***L-Alliance Motivation Test 

disp('***L-Alliance Motivation Test ');
%figure();
%hold on;
motivationAll = [];
la(1).useFast = 0;
la(2).useFast = 0;
la(3).useFast = 0;



for h=1:6
    
    la(1).Reset();
    la(1).SetTau(1,7-h);
    la(1).Broadcast();

    la(2).Reset();
    la(2).SetTau(1,3);
    la(2).Broadcast();

    la(3).Reset();
    la(3).SetTau(1,h);
    la(3).Broadcast();

    for i=1:10
        mdat = zeros(3,1);
        for r=1:3
            la(r).Update(1);
            mdat(r) = la(r).data(la(r).robotId,1,la(r).mi);
        end
        
        motivationAll = [motivationAll mdat];
    end
    %Lallaince Data
    
    %[data1 ; data2 ; data3;]
    
    %Make sure L-Alliance maintains concensus
    
end
%figure();
%hold on;
%plot(motivationAll');
%    save('unit\motivAll_TestMotivation','motivationAll')
newMotivationAll = motivationAll;
motivationAll = [];
load('unit\motivAll_TestMotivation');
test1 = sum(sum(abs(motivationAll - newMotivationAll),1),2);
test = test1;

%plot(motivationAll');
%plot(assignmentAll');
if(test ~= 0)
    error('---FAIL')
end
disp('--- pass');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ***L-Alliance Task Assignment  Test 
clc;
disp('***L-Alliance Task Assignment Test ');
%figure();
%hold on;
motivationAll = [];
assignmentAll = [];

for h=1:6
    
    la(1).Reset();
    la(1).SetTau(1,7-h);
    la(1).Broadcast();

    la(2).Reset();
    la(2).SetTau(1,2.5);
    la(2).Broadcast();

    la(3).Reset();
    la(3).SetTau(1,h);
    la(3).Broadcast();

    %flag tasks 2 and 3 as finished
    la(3).BroadcastGeneral(1:3, 2:3, la(3).ui,1);
    
    for i=1:100
        mdat = zeros(3,1);
        adat = zeros(3,1);
        
        if(i == 80)
            % here we make sure motivation "crosses paths" to test
            % if robot 2 will erroniously steal a task
           la(2).data(la(2).robotId,:,la(2).mi) = la(2).data(la(2).robotId,:,la(2).mi ) + 200; 
        
        end
        for r=1:3
            la(r).Update(1); %update your motivation
            la(r).Broadcast(); % and tell others about it
            mdat(r) = la(r).data(la(r).robotId,1,la(r).mi);
        end
        for r=1:3
            la(r).ChooseTask();
            adat(r)  = la(r).data(la(r).robotId, 1, la(r).ji);
            la(r).Broadcast(); % and tell others about it
        end
        
        motivationAll = [motivationAll mdat];
        assignmentAll = [assignmentAll adat];
    end
    %Lallaince Data
    
    %[data1 ; data2 ; data3;]
    
    %Make sure L-Alliance maintains concensus
    
end
%figure();
%hold on;
%plot(motivationAll');

%assDisp = [assignmentAll(1,:)*10; assignmentAll(2,:)*11;assignmentAll(3,:)*12];
%plot(assDisp');
%    save('unit\assAll_TestAssignment','assignmentAll')
%    save('unit\motivAll_TestAssignment','motivationAll')
newMotivationAll = motivationAll;
newAssignmentAll = assignmentAll;
motivationAll = [];
assignmentAll = [];

load('unit\assAll_TestAssignment');
load('unit\motivAll_TestAssignment');

%figure();
%hold on;
%plot(motivationAll');
%plot(assignmentAll'*10);


test1 = sum(sum(abs(motivationAll - newMotivationAll),1),2);
test2 = sum(sum(abs(assignmentAll - newAssignmentAll),1),2);
test = test1 + test2;


if(test ~= 0)
    error('---FAIL')
end
disp('--- pass');


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** L-Alliance Task Finish Test

disp('***L-Alliance Task Finish Test ');

motivationAll = [];
assignmentAll = [];
la(1).useFast = 0;
la(2).useFast = 0;
la(3).useFast = 0;



for h=1:6
    
    la(1).Reset();
    la(1).SetTau(1,7-h);
    la(1).Broadcast();

    la(2).Reset();
    la(2).SetTau(1,2.5);
    la(2).Broadcast();

    la(3).Reset();
    la(3).SetTau(1,h);
    la(3).Broadcast();

    %flag tasks 2 and 3 as finished
    la(3).BroadcastGeneral(1:3, 2:3, la(3).ui,1);
        
    
    for i=1:100
        mdat = zeros(3,1);
        adat = zeros(3,1);
        
        for r=1:3
            la(r).Update(1); %update your motivation
            mdat(r) = la(r).data(la(r).robotId,1,la(r).mi);
            la(r).Broadcast(); % and tell others about it
        end
        
        for r=1:3
            la(r).ChooseTask();
            la(r).Broadcast(); % and tell others about it
            adat(r)  = la(r).data(la(r).robotId, 1, la(r).ji);
        end
        
        if(i == 30)
            %at iteration 30, the task is now finished
            la(3).BroadcastGeneral(1:3, 1, la(3).ui,1);
        end
        
        if(i == 70)
            %at iteration 70, the task is now free again, should get taken
            %again
            la(3).BroadcastGeneral(1:3, 1, la(3).ui,0);
        end
              
        motivationAll = [motivationAll mdat];
        assignmentAll = [assignmentAll adat];
        
    end
    %Lallaince Data
    
    %[data1 ; data2 ; data3;]
    
    %Make sure L-Alliance maintains concensus
    
end
%%figure();
%hold on;
%plot(motivationAll');
%assDisp = [assignmentAll(1,:)*10; assignmentAll(2,:)*11;assignmentAll(3,:)*12]
%plot(assDisp');
%assignmentAll = assignmentAll.*10;
%    save('unit\assAll_TestFinish','assignmentAll')
%    save('unit\motivAll_TestFinish','motivationAll')
newMotivationAll = motivationAll;
newAssignmentAll = assignmentAll;
motivationAll = [];
assignmentAll = [];


load('unit\assAll_TestFinish');
load('unit\motivAll_TestFinish');

%figure();
%hold on;
%plot(motivationAll');
%assDisp = [assignmentAll(1,:)*10; assignmentAll(2,:)*11;assignmentAll(3,:)*12]
%plot(assDisp');


test1 = sum(sum(abs(motivationAll - newMotivationAll),1),2);
test2 = sum(sum(abs(assignmentAll - newAssignmentAll),1),2);
test = test1 + test2;


if(test ~= 0)
    error('---FAIL')
end

%plot(motivationAll');
%plot(assignmentAll');
disp('--- pass');




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** L-Alliance Task Acquiescence Test

disp('***L-Alliance Task Acquiescence Test ');
%figure();
%hold on;
motivationAll = [];
assignmentAll = [];

for h=1:6
    
    la(1).Reset();
    la(1).SetTau(1,7-h);
    la(1).SetAcquiescence(30); 
    la(1).Broadcast();

    la(2).Reset();
    la(2).SetTau(1,2.5);
    la(2).SetAcquiescence(30); 
    la(2).Broadcast();

    la(3).Reset();
    la(3).SetTau(1,h);
    la(3).SetAcquiescence(30); 
    la(3).Broadcast();

    %flag tasks 2 and 3 as finished
    la(3).BroadcastGeneral(1:3, 2:3, la(3).ui,1);
    
    for i=1:100
        mdat = zeros(3,1);
        adat = zeros(3,1);
        
        for r=1:3
            la(r).Update(1); %update your motivation
            mdat(r) = la(r).data(la(r).robotId,1,la(r).mi);
            la(r).Broadcast(); % and tell others about it
        end
        
        for r=1:3
            la(r).ChooseTask();
            la(r).Broadcast(); % and tell others about it
            adat(r)  = la(r).data(la(r).robotId, 1, la(r).ji);
        end
        
        if(i == 60)
            %at iteration 30, the task is now finished
            la(3).BroadcastGeneral(1:3, 1, la(3).ui,1);
        end
        
        if(i == 80)
            %at iteration 70, the task is now free again, should get taken
            %again
            la(3).BroadcastGeneral(1:3, 1, la(3).ui,0);
        end
        
        motivationAll = [motivationAll mdat];
        assignmentAll = [assignmentAll adat];
        
    end
    %Lallaince Data
    
    %[data1 ; data2 ; data3;]
    
    %Make sure L-Alliance maintains concensus
    
end
%figure();
%hold on;
%plot(motivationAll');
%plot(assignmentAll'*10);

%assignmentAll = assignmentAll.*10;
%    save('unit\assAll_TestAcquiescence','assignmentAll')
%    save('unit\motivAll_TestAcquiescence','motivationAll')
newMotivationAll = motivationAll;
newAssignmentAll = assignmentAll;
motivationAll = [];
assignmentAll = [];

load('unit\assAll_TestAcquiescence');
load('unit\motivAll_TestAcquiescence');
test1 = sum(sum(abs(motivationAll - newMotivationAll),1),2);
test2 = sum(sum(abs(assignmentAll - newAssignmentAll),1),2);
test = test1 + test2;

%figure();
%hold on;
%plot(motivationAll');
%plot(assignmentAll');
%plot(motivationAll');
%plot(assignmentAll');
if(test ~= 0)
    error('---FAIL');
end

disp('--- pass');


if(longTests ==1)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** L-Alliance Task Tau Test

disp('***L-Alliance Task Tau Test (Task Starvation)');


tauRandom = zeros(3,100);
tauRandom(1,:) = [...
  -44.7994 -490.9340    5.2033  248.5162   65.3215 -572.7735 -161.0465  -90.6097  544.0746  274.4555  -17.1242...
  392.8086 -313.4208 -104.4800  423.7683  450.7149  219.1128  147.2257 -175.8378  223.4699 -248.4465  172.3562...
   84.5524  341.7919 -127.7604  190.8420  237.9534 -269.5131   46.8735  479.1762   33.7319  -92.5875  136.9979...
  -82.5302  132.9431  -40.4295   -5.4985  138.2368  408.6946  135.5624  494.5151 -608.5086 -134.7770   70.7980...
 -250.5519 -382.7865  185.1105  183.8105   86.8143  118.5948 -261.1689 -149.3065  -32.0015 -206.3487   99.5643...
  709.5674 -144.6692  194.2345 -310.3274  401.8664 -290.7421   62.6147 -185.5780  153.6047    3.4063  -13.1966...
  884.7278 -189.0139  -14.0638  804.9077 -344.0072  165.8996 -322.9375  309.1919   98.2589  195.6374  -83.6583...
   73.5575  441.7540 -682.5305 -489.9872  124.6407 -196.4307  -88.9045 -449.0757 -271.4503 -121.2545 -217.7394...
 -259.9455 -126.5540 -282.7999  402.5651 -296.5304  545.3828 -112.3310 -435.5222 -185.6045  280.3503  316.7788...
   48.0682];

tauRandom(2,:) = [...
  156.6053  119.1138 -144.8433  -69.4492  184.0156  504.8552  170.5181 -361.8088  129.9181  -27.6362  -73.2165  -65.7566 -263.9300  -96.2413 -235.3246 -109.4888   35.1812   52.3019 ...
  -64.6969  -45.7834   10.1065  137.4847  384.4894  186.0270  -86.0022  179.4047  -73.6598 -534.2212 -704.1718 -514.0786  -71.1382 -185.8877 -216.0481   12.1972 -197.6944 -189.1545 ...
  182.8875  234.7005  730.9753   90.7222   17.4960 -172.2402  -58.5637  -15.1594 -526.7325  -77.2073  224.8626 -171.2293  148.2700  297.4321  323.1420  233.0525 -677.9521 -169.3130 ...
  270.4474  118.4027    1.4563  131.0756  339.0218   46.1312 -227.5881  -54.0489  -62.3369  269.0236  123.6923  164.2559   44.3505 -108.6801   18.3424   65.0117 -419.4367   53.6611 ...
  278.2753  -33.0534  471.7194  168.1472 -126.1034  -46.1836  -82.5596   72.3361  226.4059  -87.5730  137.5336  526.5866  279.4472  247.5793 -244.4421 -160.2613   72.7655  -30.1944 ...
 -487.5145 -454.3269  307.8568 -227.4382  623.5034 -666.5960  134.6291    0.1878 -226.8718  121.2974...
];

tauRandom(3,:) = [...
 -238.1559  257.9350   20.0608 -491.8162 -727.4250  -85.1490  343.7419   54.3508   16.2751  206.3261 -418.0222  427.6097 -268.1553   11.3294 -109.0708   44.8669 -583.3554 ...
  457.1685  163.7431  602.9782  425.0012    3.4442 -281.7148 -521.6725    5.0913   65.7477  313.7462 -285.2948  238.4392   21.4289 -232.1061  232.2486   79.6964  -70.5317 ...
  563.1877  182.7718  -33.0822   83.2372   26.1138   52.0779  136.0773 -181.0554 -239.1072  108.1947  565.5275  -92.0465 -303.8172  -71.5637 -145.2044  -98.2034  142.6554 ...
  -39.0015 -178.3060 -133.1301 -396.7589 -257.8563 -423.9004 -154.7958 -325.5294 -212.1476  -90.4964 -360.1322   -5.8087  102.1112 -288.9693  334.1768 -475.8316 -117.5384 ...
 -445.4059 -103.3882 -397.1748 -172.4505 -222.2120 -355.5006 -619.4580  169.5179  600.0427  666.9983 -147.6533  -13.8009 -139.7241   22.7842 -275.6309 -575.8400  -10.9329 ...
 -367.5377 -570.7303  712.2746  -70.0037  121.1642  357.7406 -505.4277  123.9446  150.5236   24.9193   47.3394 -158.3828  216.9182 -254.9825 -238.9152     ...
];
tauRandom = [tauRandom(:,:) tauRandom(:,:) tauRandom(:,:)];

tauRandom = tauRandom.*2;

tauRandom(1,:) = tauRandom(1,:) + 4000;
tauRandom(2,:) = tauRandom(2,:) + 3000;
tauRandom(3,:) = tauRandom(3,:) + 2000;

tauRandom(1,1:50)= tauRandom(1,1:50)+1000;
tauRandom(2,1:50)= tauRandom(2,1:50)+4000;
tauRandom(3,1:50)= tauRandom(3,1:50)+6000;

motivationAll = [];
assignmentAll = [];
tauAll = [];

for h=1:300
    
    la(1).Reset();
    la(1).tauType = 1;
    la(1).theta = 1000;
    la(1).motivation_Threshold = 1;
    la(1).movingAvergaeDecay = 0.8;
    %la(1).SetAcquiescence(30); 
    la(1).Broadcast();

    la(2).Reset();
    la(2).theta = 1000;
    la(2).tauType = 1;
    la(2).motivation_Threshold = 1;
    la(2).movingAvergaeDecay = 0.8;
    %la(2).SetAcquiescence(30); 
    la(2).Broadcast();

    la(3).Reset();
    la(3).theta = 1000;
    la(3).tauType = 1;
    la(3).motivation_Threshold = 1;
    la(3).movingAvergaeDecay = 0.8;
    %la(3).SetAcquiescence(30); 
    la(3).Broadcast();

    %flag tasks 2 and 3 as finished
    la(3).BroadcastGeneral(1:3, 2:3, la(3).ui,1);
    la(3).BroadcastGeneral(1:3, 1, la(3).ui,0);

    for i=1:30
        mdat = zeros(3,1);
        adat = zeros(3,1);

        
        for r=1:3
            la(r).Update(1); %update your motivation
            mdat(r) = la(r).data(la(r).robotId,1,la(r).mi);
            la(r).ChooseTask();
            la(r).Broadcast(); % and tell others about it
            
            adat(r)  = la(r).data(la(r).robotId, 1, la(r).ji);

            
        end
        
        if(i == 7)
            %at iteration 30, the task is now finished
            la(3).BroadcastGeneral(1:3, 1, la(3).ui,1);
        end
        
        
        motivationAll = [motivationAll mdat];
        assignmentAll = [assignmentAll adat];
        
    end
    
    tdat = zeros(3,1);
    for r=1:3
        if(la(r).data(la(r).robotId,1,la(r).fi)>0)
            v = la(r).data(la(r).robotId,1,la(r).vi) + 1;
            la(r).UpdateTau(1,tauRandom(r,v));
            la(r).Broadcast(); % and tell others about it
        end
        tdat(r)  = la(r).data(la(r).robotId, 1, la(r).ti);
    end
    tauAll = [tauAll tdat];
    %Lallaince Data
    
    %[data1 ; data2 ; data3;]
    
    %Make sure L-Alliance maintains concensus
    
end

%assignmentAll = assignmentAll.*10;
%    save('unit\assAll_TestTauAverage','assignmentAll');
%    save('unit\motivAll_TestTauAverage','motivationAll');
%    save('unit\tauAll_TestTauAverage','tauAll');

%figure();
%hold on;
%plot(tauAll');
%visitationsAverage = la(r).data(:,1,la(r).vi)
%plot(assignmentAll');    
    
newTauAll = tauAll ;
tauAllAvg = newTauAll;

newMotivationAll = motivationAll;
newAssignmentAll = assignmentAll;
motivationAll = [];
assignmentAll = [];
tauAll = [];

load('unit\assAll_TestTauAverage');
load('unit\motivAll_TestTauAverage');
load('unit\motivAll_TestTauAverage');

test1 = sum(sum(abs(motivationAll - newMotivationAll),1),2);
test2 = sum(sum(abs(assignmentAll - newAssignmentAll),1),2);
test = test1 + test2;

if(test ~= 0)
    error('---FAIL');
end
disp('--- pass');


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** L-Alliance Task Converge Tau Test

disp('***L-Alliance Task Tau Test (RSLA Tau)');


motivationAll = [];
assignmentAll = [];
tauAll = [];
intrimTauAll = [];


    la(1).SetTau(1,0); 
    la(2).SetTau(1,0); 
    la(3).SetTau(1,0);     

    la(1).convergeAttempts = 30;
    la(1).convergeSlope = 0.2;
    la(2).convergeAttempts = 30;
    la(2).convergeSlope = 0.2;
    la(3).convergeAttempts = 30;
    la(3).convergeSlope = 0.2;

    la(3).BroadcastGeneral(1:3, 1, la(3).vi,0);


for h=1:300
    
    la(1).Reset();
    la(1).tauType = 2;
    la(1).theta = 1000;
    la(1).motivation_Threshold = 0.2;
    la(1).movingAvergaeDecay = 0.5;
    %la(1).SetAcquiescence(30); 
    la(1).Broadcast();

    la(2).Reset();
    la(2).theta = 1000;
    la(2).tauType = 2;
    la(2).motivation_Threshold = 0.2;
    la(2).movingAvergaeDecay = 0.5;
    %la(2).SetAcquiescence(30); 
    la(2).Broadcast();

    la(3).Reset();
    la(3).theta = 1000;
    la(3).tauType = 2;
    la(3).motivation_Threshold = 0.2;
    la(3).movingAvergaeDecay = 0.5;
    %la(3).SetAcquiescence(30); 
    la(3).Broadcast();

    %flag tasks 2 and 3 as finished
    la(3).BroadcastGeneral(1:3, 2:3, la(3).ui,1);
    la(3).BroadcastGeneral(1:3, 1, la(3).ui,0);

    for i=1:30
        mdat = zeros(3,1);
        adat = zeros(3,1);

        
        for r=1:3
            la(r).Update(1); %update your motivation
            mdat(r) = la(r).data(la(r).robotId,1,la(r).mi);
            la(r).Broadcast(); % and tell others about it
        end
        
        for r=1:3
            la(r).ChooseTask();
            la(r).Broadcast(); % and tell others about it
            adat(r)  = la(r).data(la(r).robotId, 1, la(r).ji);
        end
        
        if(i == 29)
            %at iteration 30, the task is now finished
            la(3).BroadcastGeneral(1:3, 1, la(3).ui,1);
        end
        
        motivationAll = [motivationAll mdat];
        assignmentAll = [assignmentAll adat];
    end
    
    tdat = zeros(3,1);
    for r=1:3
        if(la(r).data(la(r).robotId,1,la(r).fi)>0)
            v = la(r).data(la(r).robotId,1,la(r).vi) + 1;
            la(r).UpdateTau(1,tauRandom(r,v));
            la(r).Broadcast(); % and tell others about it
        end
        tdat(r)  = la(r).data(la(r).robotId, 1, la(r).ti);
    end
    tauAll = [tauAll tdat];
    %Lallaince Data
    %[data1 ; data2 ; data3;]
    %Make sure L-Alliance maintains concensus
    
end

%assignmentAll = assignmentAll.*10;
%    save('unit\assAll_TestTauConverge','assignmentAll');
%    save('unit\motivAll_TestTauConverge','motivationAll');
%    save('unit\tauAll_TestTauConverge','tauAll');

%figure();
%hold on;
%plot(tauAll');
%visitations = la(r).data(:,1,la(r).vi)
%plot(assignmentAll');    
    
newTauAll = tauAll ;
tauAllAvg = newTauAll;

newMotivationAll = motivationAll;
newAssignmentAll = assignmentAll;

load('unit\assAll_TestTauConverge');
load('unit\motivAll_TestTauConverge');
load('unit\tauAll_TestTauConverge');
%figure();
%hold on;
%plot(tauAll');

test1 = sum(sum(abs(motivationAll - newMotivationAll),1),2);
test2 = sum(sum(abs(assignmentAll - newAssignmentAll),1),2);
test = test1 + test2;

if(test ~= 0)
    error('---FAIL');
end
disp('--- pass');


end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** L-Alliance Task Impatience Types

disp('***L-Alliance Task Impatience Types');


motivationAll = [];
assignmentAll = [];
tauAll = [];
intrimTauAll = [];


    la(1).SetTau(1,0); 
    la(2).SetTau(1,0); 
    la(3).SetTau(1,0);   
    maxa = 7000;
    mina = 4000;
    
    la(1).tmax = maxa; 
    la(2).tmax = maxa; 
    la(3).tmax = maxa;
    
    la(1).tmin = mina; 
    la(2).tmin = mina; 
    la(3).tmin = mina;     

    la(1).convergeAttempts = 30;
    la(1).convergeSlope = 0.2;
    la(2).convergeAttempts = 30;
    la(2).convergeSlope = 0.2;
    la(3).convergeAttempts = 30;
    la(3).convergeSlope = 0.2;

    la(3).BroadcastGeneral(1:3, 1, la(3).vi,0);
    la(1).SetAcquiescence(0); 
    la(2).SetAcquiescence(0); 
    la(3).SetAcquiescence(0); 

for h=1:6
    
    la(1).Reset();
    la(1).tauType = 1;
    la(1).useFast = 1;
    la(1).SetTau (1, 8000 - h*1000);
    la(1).theta = 100;
    la(1).motivation_Threshold = 0.2;
    la(1).movingAvergaeDecay = 0.5;
    %la(1).SetAcquiescence(30); 
    la(1).Broadcast();

    la(2).Reset();
    la(2).SetTau (1, 3500);
    la(2).theta = 100;
    la(2).tauType = 1;
    la(2).useFast = 1;
    la(2).motivation_Threshold = 0.2;
    la(2).movingAvergaeDecay = 0.5;
    %la(2).SetAcquiescence(30); 
    la(2).Broadcast();

    la(3).Reset();
    la(3).SetTau (1, 1000 + h*1000 );
    la(3).theta = 100;
    la(3).tauType = 1;
    la(3).useFast = 1;
    la(3).motivation_Threshold = 0.2;
    la(3).movingAvergaeDecay = 0.5;
    %la(3).SetAcquiescence(30);
    la(3).Broadcast();
    
    
    %flag tasks 2 and 3 as finished
    la(3).BroadcastGeneral(1:3, 2:3, la(3).ui,1);
    la(3).BroadcastGeneral(1:3, 1, la(3).ui,0);

    for i=1:11
        mdat = zeros(3,1);
        adat = zeros(3,1);
        
        for r=1:3
            la(r).Update(1); %update your motivation
            mdat(r) = la(r).data(la(r).robotId,1,la(r).mi);
            la(r).Broadcast(); % and tell others about it
        end
        
        for r=1:3
            la(r).ChooseTask();
            la(r).Broadcast(); % and tell others about it
            adat(r)  = la(r).data(la(r).robotId, 1, la(r).ji);
        end
        
        if(i == 9)
            la(3).BroadcastGeneral(1:3, 1, la(3).ui,1);
        end
        
        motivationAll = [motivationAll mdat];
        assignmentAll = [assignmentAll adat];
    end
    
    %Lallaince Data
    %[data1 ; data2 ; data3;]
    %Make sure L-Alliance maintains concensus
    
end

%assignmentAll = assignmentAll.*10;
%    save('unit\assAll_TestTauImpatience','assignmentAll');
%    save('unit\motivAll_TestTauImpatience','motivationAll');
%    save('unit\tauAll_TestTauImpatience','tauAll');

%figure();
%hold on;
%plot(motivationAll');
%plot(assignmentAll'./2);
%plot(assignmentAll');    

newMotivationAll = motivationAll;
newAssignmentAll = assignmentAll;

load('unit\assAll_TestTauImpatience');
load('unit\motivAll_TestTauImpatience');
load('unit\motivAll_TestTauImpatience');

%figure();
%hold on;
%plot(motivationAll');
%plot(assignmentAll'./2);
%plot(assignmentAll');    


test1 = sum(sum(abs(motivationAll - newMotivationAll),1),2);
test2 = sum(sum(abs(assignmentAll - newAssignmentAll),1),2);
test = test1 + test2;

if(test ~= 0)
    error('---FAIL');
end
disp('--- pass');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** L-Alliance Task Multiple Assignments

disp('***L-Alliance Task Multiple Assignments');


motivationAll = [];
assignmentAll = [];
tauAll = [];
intrimTauAll = [];


    la(1).SetTau(1,0); 
    la(2).SetTau(1,0); 
    la(3).SetTau(1,0);     

    la(1).convergeAttempts = 30;
    la(1).convergeSlope = 0.2;
    la(2).convergeAttempts = 30;
    la(2).convergeSlope = 0.2;
    la(3).convergeAttempts = 30;
    la(3).convergeSlope = 0.2;

    la(3).BroadcastGeneral(1:3, 1, la(3).vi,0);
    la(1).SetAcquiescence(0); 
    la(2).SetAcquiescence(0); 
    la(3).SetAcquiescence(0); 

    la(1).useCooperation = 1; 
    la(2).useCooperation = 1; 
    la(3).useCooperation = 1; 
    

for h=1:6
    
    la(1).Reset();
    
    la(1).tauType = 1;
    la(1).useFast = 1;
    la(1).SetTau (1, 8000 - h*1000);
    
    la(1).theta = 100;
    la(1).motivation_Threshold = 0.1;
    la(1).movingAvergaeDecay = 0.5;
    %la(1).SetAcquiescence(30); 
    la(1).Broadcast();

    la(2).Reset();
    la(2).SetTau (1, 3500);
    la(2).theta = 100;
    la(2).tauType = 1;
    la(2).useFast = 1;
    
    la(2).motivation_Threshold = 0.1;
    la(2).movingAvergaeDecay = 0.5;
    %la(2).SetAcquiescence(30); 
    la(2).Broadcast();

    la(3).Reset();
    la(3).SetTau (1, 1000 + h*1000 );
    la(3).theta = 100;
    la(3).tauType = 1;
    la(3).useFast = 1;

    la(3).motivation_Threshold = 0.1;
    la(3).movingAvergaeDecay = 0.5;
    %la(3).SetAcquiescence(30); 
    la(3).Broadcast();

    %flag tasks 2 and 3 as finished
    la(3).BroadcastGeneral(1:3, 2:3, la(3).ui,1);
    la(3).BroadcastGeneral(1:3, 1, la(3).ui,0);

    for i=1:30
        mdat = zeros(3,1);
        adat = zeros(3,1);
        
        for r=1:3
            la(r).Update(1); %update your motivation
            mdat(r) = la(r).data(la(r).robotId,1,la(r).mi);
            la(r).Broadcast(); % and tell others about it
        end
        
        for r=1:3
            la(r).ChooseTask();
            la(r).Broadcast(); % and tell others about it
            adat(r)  = la(r).data(la(r).robotId, 1, la(r).ji);
        end
        
        if(i == 20)
            la(3).BroadcastGeneral(1:3, 1, la(3).ui,1);
        end
        
        motivationAll = [motivationAll mdat];
        assignmentAll = [assignmentAll adat];
    end
    
    %Lallaince Data
    %[data1 ; data2 ; data3;]
    %Make sure L-Alliance maintains concensus
    
end

%assignmentAll = assignmentAll.*10;
%    save('unit\assAll_TestTauMultiple','assignmentAll');
%    save('unit\motivAll_TestTauMultiple','motivationAll');
%    save('unit\tauAll_TestTauMultiple','tauAll');

%figure();
%hold on;
%plot(motivationAll');
%assAll = bsxfun(@times,assignmentAll,[1;1.2;1.3;]);
%plot(assAll'./6);
%plot(assignmentAll');    

newMotivationAll = motivationAll;
newAssignmentAll = assignmentAll;

load('unit\assAll_TestTauMultiple');
load('unit\motivAll_TestTauMultiple');
load('unit\motivAll_TestTauMultiple');

test1 = sum(sum(abs(motivationAll - newMotivationAll),1),2);
test2 = sum(sum(abs(assignmentAll - newAssignmentAll),1),2);
test = test1 + test2;

if(test ~= 0)
    error('---FAIL');
end
disp('--- pass');



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** L-Alliance Auto Tau Tracking

disp('***L-Alliance Task Auto Tau Tracking');


motivationAll = [];
assignmentAll = [];
impatienceAll = [];
tauAll = [];
intrimTauAll = [];


    la(1).SetTau(1,40); 
    la(2).SetTau(1,40); 
    la(3).SetTau(1,40);     

    la(1).convergeAttempts = 30;
    la(1).convergeSlope = 0.2;
    la(2).convergeAttempts = 30;
    la(2).convergeSlope = 0.2;
    la(3).convergeAttempts = 30;
    la(3).convergeSlope = 0.2;

    la(3).BroadcastGeneral(1:3, 1, la(3).vi,0);
    la(1).SetAcquiescence(0); 
    la(2).SetAcquiescence(0); 
    la(3).SetAcquiescence(0); 

    la(1).useCooperation = 0; 
    la(2).useCooperation = 0; 
    la(3).useCooperation = 0; 
    
    la(1).calculateTau = 1; 
    la(2).calculateTau = 1; 
    la(3).calculateTau = 1; 
    la(1).tauType = 1; 
    la(2).tauType = 1; 
    la(3).tauType = 1; 

    la(1).tmax = 100; 
    la(2).tmax= 100; 
    la(3).tmax = 100; 

    la(1).tmin = 10; 
    la(2).tmin = 10; 
    la(3).tmin = 10; 
    
    
for h=1:30
    
    la(1).Reset();
    la(1).tauType = 1;
    la(1).useFast = 1;
    la(1).theta = 100;
    la(1).motivation_Threshold = 0.01;
    la(1).movingAvergaeDecay = 0.5;
    %la(1).SetAcquiescence(30); 
    la(1).Broadcast();

    la(2).Reset();
    la(2).theta = 100;
    la(2).tauType = 1;
    la(2).useFast = 1;
    la(2).motivation_Threshold = 0.01;
    la(2).movingAvergaeDecay = 0.5;
    %la(2).SetAcquiescence(30); 
    la(2).Broadcast();

    la(3).Reset();
    la(3).theta = 100;
    la(3).tauType = 1;
    la(3).useFast = 1;
    la(3).motivation_Threshold = 0.01;
    la(3).movingAvergaeDecay = 0.5;
    %la(3).SetAcquiescence(30); 
    la(3).Broadcast();
    %flag tasks 2 and 3 as finished
    la(3).BroadcastGeneral(1:3, 2:3, la(3).ui,1);
    la(3).BroadcastGeneral(1:3, 1, la(3).ui,0);

    for i=1:100
        mdat = zeros(3,1);
        adat = zeros(3,1);
        tdat = zeros(3,1);
        pdat = zeros(3,1);
        
        for r=1:3
            la(r).Update(1); %update your motivation
            mdat(r) = la(r).data(la(r).robotId,1,la(r).mi);
            la(r).Broadcast(); % and tell others about it
        end
        
        for r=1:3
            la(r).ChooseTask();
            la(r).Broadcast(); % and tell others about it
            adat(r)  = la(r).data(la(r).robotId, 1, la(r).ji);
            tdat(r)  = la(r).data(la(r).robotId, 1, la(r).ti);
            pdat(r)  = la(r).data(la(r).robotId, 1, la(r).pi);
        end
        
        if(i == 90-h && la(1).GetCurrentTask() == 1)
            la(1).SetTaskFinished(1);
        elseif(i == 60+mod(h,10) && la(2).GetCurrentTask() == 1)
            la(2).SetTaskFinished(1);
        elseif(i == 70+mod(h*5,10) && la(3).GetCurrentTask() == 1)
            la(3).SetTaskFinished(1);
        end        
        
        motivationAll = [motivationAll mdat];
        assignmentAll = [assignmentAll adat];
        intrimTauAll = [intrimTauAll tdat];
        impatienceAll = [impatienceAll pdat];
    end

    %Lallaince Data
    %[data1 ; data2 ; data3;]
    %Make sure L-Alliance maintains concensus
    
end

%assignmentAll = assignmentAll.*10;
%    save('unit\assAll_TestTauAutoTau','assignmentAll');
%    save('unit\motivAll_TestTauAutoTau','motivationAll');
%    save('unit\tauAll_TestTauAutoTau','tauAll');

%figure();
%hold on;
%plot(motivationAll');
%assAll = bsxfun(@times,assignmentAll,[1;1.2;1.3;]);
%plot(assAll'*50);
%plot(intrimTauAll'./1000);    
%plot(impatienceAll'*100);    

newMotivationAll = motivationAll;
newAssignmentAll = assignmentAll;

load('unit\assAll_TestTauAutoTau');
load('unit\motivAll_TestTauAutoTau');
load('unit\motivAll_TestTauAutoTau');

test1 = sum(sum(abs(motivationAll - newMotivationAll),1),2);
test2 = sum(sum(abs(assignmentAll - newAssignmentAll),1),2);
test = test1 + test2;

if(test ~= 0)
    error('---FAIL');
end
disp('--- pass');




















