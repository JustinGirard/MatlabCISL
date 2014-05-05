clc;
clear all;
minTime =10000;
%options
trace=0;
traceRobot = 3;
fileName = 'MidMarch14v25b_a_1_25_confgv2_22123413_c95_replay_';



%for it = 1:300
    
%    file = strcat(fileName,num2str(it));

%    load(strcat('results\replay\',file));
%    time = size(posData,3);
%    minTime = min([minTime time]);
%    if(minTime ==time)
%        iteration = it
%    end
%end
iteration = 45;
iteration = 213;

file = strcat(fileName,num2str(iteration));
load(strcat('results\replay\',file))
h1 = figure();

time = size(posData,3);
traceX = [];
traceY = [];
%whitebg('w')
set(h1,'color','w');
begin = 1;
%set(gcf,'DoubleBuffer','on');
%time = 1900;
for ta=1:floor(time/1)
            t=ta*1;
            numRobots = size(posData,1);
            numTargets = size(targData,1);
            numObstacles = size(obsData,1);
            %axis([0 14 0 14]);
            %clf(h1);
            
            if(trace ==0)
                cla(h1);
                text(1,13,num2str(t));
            end
            %axis([0 14 0 14]);

           % Output Robot Tracks

           for i=1:numRobots
                hold all; 
               % plot(reshape(posData(i,1,1:t),1,[]),reshape(posData(i,2,1:t),1,[]),'b');
                %drawnow;
           end
           
           % Output Target Tracks
           for i=1:numTargets
                %hold all 
                %plot(reshape(targData(i,1,1:t),1,[]),reshape(targData(i,2,1:t),1,[]),'g');
                %drawnow;

           end           

           % Output Robot Representation
           for i=1:numRobots
               if(trace == 0) 
                   point = posData(i,:,t);

                   boxPoints = GetBox(point,0.17);
                   %hold all
                   if(trace == 0) 
                       lbl = strcat(num2str(i),' ','rbt');
                       text(point(1)+0.2,point(2)+0.2,lbl); 
                   end
                   fill(boxPoints(1,:),boxPoints(2,:),'k');
                   if(rpropData(i,1,t) > 0)
                       tid = rpropData(i,1,t);
                       X = [posData(i,1,t) targData(tid,1,t)];
                       Y = [posData(i,2,t) targData(tid,2,t)];
                       plot(X,Y,'r');
                       %drawnow;
                   end

                   if(rpropData(i,7,t) > 0) %advisor
                       rid = rpropData(i,7,t);
                       X = [posData(i,1,t) posData(rid,1,t)];
                       Y = [posData(i,2,t) posData(rid,2,t)];
                       plot(X,Y,'y');
                       %drawnow;
                   end
               end
               %tracing a line
               if(trace ==1 && t>1 && i==traceRobot)
                   traceX = [posData(i,1,t-1) posData(i,1,t)] ;
                   traceY = [posData(i,2,t-1) posData(i,2,t)] ;
                   if(rpropData(i,1,t) >0 && rpropData(i,1,t)==3)
                       if(begin ==1 )
                           begin = 0;
                           point = posData(i,:,t)';
                           boxPoints = GetBox(point,0.17);
                           fill(boxPoints(1,:),boxPoints(2,:),'k');                   
                       end
                       tid = rpropData(i,1,t);
                       if(tpropData(tid,4,t) == i || tpropData(tid,7,t) == i  )
                            plot(traceX,traceY,'.-','color','k','LineWidth',2);  
                           finalPoint = posData(i,:,t);
                       else
                            plot(traceX,traceY,'.-','color','k','LineWidth',0.5);  
                           finalPoint = posData(i,:,t);
                       end
                   end
               end
               
           end


           % Output Obstacle Locations
           for i=1:numObstacles
               point = obsData(i,:,t);
               boxPoints = GetBox(point,0.5);
               %hold all
               fill(boxPoints(1,:),boxPoints(2,:),'k');
           end


           % Output Target Locations
           if(trace == 0) || (t==1)
               for i=1:numTargets
                   point = targData(i,:,t);
                   boxPoints = GetBox(point,0.25);
                   %hold all
                   if(trace == 0)                    
                       lbl = strcat(num2str(i),' ','tsk');
                       text(point(1)+0.2,point(2)+0.2,lbl); 
                   end

                   fill(boxPoints(1,:),boxPoints(2,:),[0.5 0.5 0.5]);
               end
           end
           % Output Goal Location
               point = goalData(1,:,t);
               boxPoints = GetBox(point,1);
               hold all
               plot(boxPoints(1,:),boxPoints(2,:),'k');
               %drawnow; 
           t
           %pause(0.05)
          %imagesc(h1,'Parent',h2);
           %drawnow;           
end

if(trace ==1)
    boxPoints = GetBox(finalPoint,0.17);
    fill(boxPoints(1,:),boxPoints(2,:),'k');                   
end

axis([0 10 0 10]);

set(h1,'color','w');
