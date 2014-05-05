classdef LAllianceCoop < handle
    %LALLIANCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rstate;
        taskId;
        avgNum = 10;
        
        %TODO : refactor to look up number of task types
        numTaskTypes = [];
        
        ID_CURRENT = 1;
        ID_MAX = 2;
        ID_AVG = 3;
        configId = 0;

        
        taskTimesDefault = [1 1];
        % rows:  taskType   
        % cols:  1-min, 2-max 
        %taskTimes= [10000 0; 10000 0];
        taskTimes= [355 1000; 355 1000];

        taskTimesMv= [355 1000; 355 1000];
        doStochasticLearning = 0;
        visitations = [0 0; 0 0];
        
        taskType = 0;
        taskTicks = 0;
        taskTicksTotal = [];
        % rows:  task K value for this robot  
        taskK = [0;0];
        time_min = 200;
        time_max = 2000;
        
        theta = 0.7;
        freq = 1;
        
    end
    
    
    properties (Constant)
        %[motivation is stored as [robotId task# ]
        s_motivation = SparseHashtable(10);
        %[average performance is stored as [robotId task# ]
        s_tau = SparseHashtable(10);
        s_tauMaxMin = SparseHashtable(10);
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   GetDelta
        %   param - targetProperties - current properties of all targets
        %   (tasks)
        %  
        %   Get's the delta values for all foraging targets (delta is in
        %   l-alliance)
        %
        %
        % 1) update the min and max tau for all tasks
        function [maxTau, minTau] = UpdateMaxMin(this)
            
            min = 1; max=2;
            c = Configuration.Instance(this.configId );
            numRobots = c.numRobots;           

            for i = 1:this.numTaskTypes
                minTau = 0;
                maxTau =0;
                
                %loop through the robots, and find the current min and max
                %taus for all the robots on this task
                for robotId = 1:numRobots
                    [tau,temp] = this.s_tau.Get([robotId i]);
                    if(~isnan(tau))
                        if(tau < minTau)
                            minTau = tau;
                        elseif(minTau == 0)
                            minTau = tau;
                        end
                        if( tau > maxTau)
                            maxTau = tau;
                        end
                    end
                end
                
                this.s_tauMaxMin.Put([min i],minTau );
                this.s_tauMaxMin.Put([max i],maxTau );
            end        
            
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   GetDelta
        %   param - targetProperties - current properties of all targets
        %   (tasks)
        %  
        %   Get's the delta values for all foraging targets (delta is in
        %   l-alliance)
        %
        function delta = GetDelta(this,targetProperties,robotId,numRobots)
           tau = sum(this.taskTimes,2);
           tau = tau/2; %we find the average completion time
           
           %tauNeg = (tau -  this.taskTimes(:,1)<= 0);
           %tauPos = (tau -  this.taskTimes(:,1)> 0);
           %tau = tau.*tauPos + 3000.*ones(size(tau,1),1).*tauNeg;

           %tau is a column vector, each cell being an average completion time
           %for each task type
           %minimums = tauPos.*this.taskTimes(:,1) + tauNeg.*zeros(size(tau,1),1);
           minimums = zeros(this.numTaskTypes,1);
           for i=1:this.numTaskTypes
            minimums(i) = this.s_tauMaxMin.Get([1 i]);
            if(tau(i)< minimums(i))
                minimums(i) =  tau(i);
            end
           end
           
           %maximums = tauPos.*this.taskTimes(:,2) + tauNeg.*zeros(size(tau,1),1);
           %minimum and maximum completion times, corrected for unitialized
           %vals
           
           % Case I is for when robot i expects to perform task j better than other robots in the team; 
           deltaFastOne =  ((tau - minimums).*this.taskK)*(-1) ;
           deltaFastOne = bsxfun(@plus,deltaFastOne,this.time_max);
           deltaFastOne = this.theta./deltaFastOne;

           % otherwise Case II is used.
           deltaFastTwo =  ((tau  - minimums).*this.taskK)*(+1) ;
           deltaFastTwo = bsxfun(@plus,deltaFastTwo,this.time_min);
           deltaFastTwo = this.theta./deltaFastTwo;

           % The slow impatience rate is used if another robot has been on the task previously;
           deltaSlow = this.theta./tau;
           
           
           %now we assign the delta we calculated
           types = targetProperties(:,3);
           delta = zeros(size(types,1),1);
           
           for i = 1:size(types,1)
                %save our average performance in a shared sandbox
                this.s_tau.Put([robotId types(i)],tau(types(i)));
                
                % do we have the Best Tau for this task? (bestTau)
                myTau = tau(types(i));
                bestTau = 1;
                for r=1:numRobots
                    [tauTemp,temp] = this.s_tau.Get([robotId types(i)]);
                    if ~(isnan(tauTemp))
                        if tauTemp < myTau
                            bestTau = 0;
                            break;
                        end
                    end
                end
                
                %can't be the best, if we have never completed the task!
                if(this.taskTimesDefault(types(i)) == 1)
                    bestTau = 0;
                end
                
                % has another robot done this task? (otherDone )
                if(targetProperties(i,6) == robotId || targetProperties(i,6) == 0)
                    otherDone = 0;
                else
                    otherDone = 1;
                end
                
                
                %choose our rate based on our conditions
                if otherDone == 1
                    delta(i) = deltaSlow(types (i));
                elseif bestTau == 1
                    delta(i) = deltaFastOne(types (i));
                else
                    delta(i) = deltaFastTwo(types (i));
                end
                delta(i) = deltaSlow(types (i));


           end

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   GetLearningData()
        %   
        %   Return learning data for L-Alliance
        %   This is just task times
        %           
        function td= GetLearningData(this)
            td = [this.taskTimes(1,[1 2]) ...
            this.taskTimes(2,[1 2]) ];
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   GetGating
        %  
        %   Get the gating condition for the list of tasks. See the
        %   L-ALLIANCE description.
        %
        % a) whether task j is still incomplete, 
        % b) no other task is assigned to robot i, 
        % c) no other robot takes over the task j at time t, 
        % d) robot i has failed to perform task j in several previous attempts, and 
        % e) no other robot is present at time t that can accomplish task j better than robot i. 
        
        function gating = GetGating(this,targetProperties)

            gating = abs(targetProperties(:,1) -1); %ignore untaken tasks
            carriedBy = abs(targetProperties(:,4)); 
            
            carriedByMe = carriedBy-this.rstate.id;
            carriedByMe = carriedByMe == 0;
            
            carriedByOthers = carriedBy == 0;
            
            if(sum(carriedByMe ) == 1) %if we carry a box
                gating = gating.*carriedByMe;   %ignore all uncarried tasks
            else %if we don't carry a box
                gating = gating.*carriedByOthers; %ignore all carried tasks
            end
            
           
            
        end
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   UpdateTaskTimes
        %   
        %   After a task is completed, this is called:
        %   We note our minimum and maximum completion time
        %   for this kind of task. These minimums and maximums
        %   are used in L-ALLIANCE to calculate the impatience 
        %   factor
        %
        function UpdateTaskTimes(this)
            minId = 1;
            maxId = 2;
            %if this is our first time doing this task type,
            % set our mins and max numbers
            if(this.taskId > 0)
                if(this.taskTimesDefault(this.taskType) == 1)
                    this.taskTimesDefault(this.taskType) = 0;

                    this.taskTimes(this.taskType,minId) = this.taskTicksTotal(this.taskId);
                    this.taskTimes(this.taskType,maxId) = this.taskTicksTotal(this.taskId);

                else


                    if this.taskTicksTotal(this.taskId) < this.taskTimes(this.taskType,minId)
                        this.taskTimes(this.taskType,minId) = this.taskTicksTotal(this.taskId) ;
                    end

                    if this.taskTicksTotal(this.taskId) > this.taskTimes(this.taskType,maxId )
                        this.taskTimes(this.taskType,maxId ) = this.taskTicksTotal(this.taskId) ;
                    end
                end
            end
            this.UpdateKVals();
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   UpdateKVals
        %   
        %   Recalculate K values that are used in LALLIANCE formulations.
        %
        function UpdateKVals(this)
            %calculate K values for tasks
            %maxMin = this.time_max - this.time_min;
            %taskMaxMin = this.taskTimes(:,2) - this.taskTimes(:,1);
            %zeroTest = (taskMaxMin > 0);
            %taskMaxMin = taskMaxMin.*zeroTest;

            
            %this.taskK = maxMin./taskMaxMin;
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           %
           % 1) update the min and max tau for all tasks
           % Then we update our scaling factor
           % 2) update the scaleFactor used
           this.UpdateMaxMin();
           min = 1; max = 2;
           %now we calculate our scaling factors
           maxTau = zeros(this.numTaskTypes,1);
           minTau = zeros(this.numTaskTypes,1);
           
           for taskTypeId=1:this.numTaskTypes
               maxTau(taskTypeId) =  this.s_tauMaxMin.Get([max taskTypeId]);
               minTau(taskTypeId) =  this.s_tauMaxMin.Get([min taskTypeId]);
               if(isnan(maxTau(taskTypeId)))
                   maxTau(taskTypeId) = 0;
               end
               if(isnan(minTau(taskTypeId)))
                   minTau(taskTypeId) = 0;
               end
           end
           maxMin = this.time_max - this.time_min;
           
           taskMaxMin = maxTau - minTau;
           taskMaxMin = taskMaxMin + (taskMaxMin < 1)*0.5; 
           this.taskK = (this.time_max + (this.time_max- this.time_min))./(maxTau+ (maxTau-minTau)) ;
           %this.taskK = maxMin./taskMaxMin;
           
           
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   LAlliance(configId)
        %   
        %   Create the LAlliance object for a single robot, given a certain
        %   configuration class through the constructor. configId defines a
        %   specific 'ConfigurationRun' object.
        %
        function this = LAlliance(configId,robotId)
            this.configId = configId;
            
            c = Configuration.Instance(configId);
            this.doStochasticLearning  = c.lalliance_doStochasticLearning;
            
            this.freq = c.lalliance_motiv_freq;
            this.numTaskTypes = 2;
            
            this.taskId = 0;
            this.UpdateKVals();
            
            this.taskTicksTotal = zeros(c.numTargets,1);
            
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   UpdateMotivation(this,reward,rstate)
        %   
        %   Runs every iteration (tick). Given a robots current state,
        %   update it's motivation toward every single task. This function
        %   does little more than combine the delta, and gating condition,
        %   to find the new value of motivation toward each task.
        %        
        function UpdateMotivation(this,reward,rstate)
            %update counters
            this.taskTicks = this.taskTicks +1;
            if(this.taskId ~= 0)
                this.taskTicksTotal(this.taskId)=this.taskTicksTotal(this.taskId)+1;
            end
            if(mod(this.taskTicks,this.freq) ~= 0)
                return;
            end
            
            this.rstate = rstate;
            timeStep = this.freq;
            
            [robPos, robOrient, millis, obstaclePos,targetPos,goalPos,targetProperties,robotProperties ]  = rstate.GetSnapshot();
            [targetPosRelative,obstaclePosRelative,goalPosRelative,borderOfWorld,robot] = rstate.GetCurrentState();

            robotId = this.rstate.id;
            numTasks = size(targetPos);
            targetDistance = targetPosRelative(:,1);

            % Generate the impatience factor for each task (for simplicity we just use proximity)
            %impatience =  1+ (10./(targetDistance+1));
            impatience = timeStep * this.GetDelta(targetProperties,robotId,size(robPos,1));
            
            
            % Generate the gating conditions for each task
            gating = this.GetGating(targetProperties);
            % Update the motivation for this robot
            motivationCurrent = [];
	    
            for i=1:numTasks
                motivation = this.s_motivation.Get([robotId  i]);
                if( isnan(motivation))
                    motivation = 0;
                end
                
                
                motivationCurrent = [motivationCurrent; motivation];
            end
            
            motivationCurrent = (motivationCurrent + impatience).*gating;
            motivationCurrent = motivationCurrent* 0.70;
%            if(robotId == 1)
%                impatience
%                motivationCurrent
%            end
            for i=1:numTasks
                this.s_motivation.Put([robotId  i],motivationCurrent(i));
                %currMotivUpdate = motivationCurrent(i)
            end
            
        end
        
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Reset(this)
        %   
        %   Reset runs after a simulation, and gets the robots ready for a
        %   new simulation.
        %
        function Reset(this)
            this.s_motivation.Reset();
            this.taskId = 0;
            this.taskTicks = 0;
            this.taskTicksTotal = this.taskTicksTotal.*0;

            if(this.doStochasticLearning == 1)
                if(~isempty(this.rstate))
                    %track how many times we have attempted tasks
                    different = (this.taskTimes ~= this.taskTimesMv);
                    this.visitations = this.visitations + different ;
                    v = this.visitations;

                    %use a decay rate, to help ignore terrible performance
                    beta = (exp((v-2)./2)./(700+exp((v-2)./2)));
                    
                    %update out task times, and our averages
                    this.taskTimesMv = this.taskTimesMv + (different.*beta.*(1./(v./3)).*(this.taskTimes - this.taskTimesMv) + 0);
                    this.taskTimes = this.taskTimesMv;
                    
                    for i=1:2
                        %only decrease the maximums. Minimums can stay (for now)
                        this.s_tau.Put([this.rstate.id i],sum(this.taskTimes(i,:),2)/2);
                    end
                    this.UpdateMaxMin();
                end
            end
            
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   ChooseTask(this)
        %   
        %   Runs after each epoch only (so we allow some inefficent code)
        %   This function examines the motivation for each robot toward
        %   each tasks, and picks a task according to the L-ALLIANCE
        %   motivation values. 
        %   
        function taskId = ChooseTask(this,rstateIn)
            this.UpdateKVals();

            robotId = rstateIn.id;
            c = Configuration.Instance(this.configId );
            numRobots = c.numRobots;
            numTasks = c.numTargets;
            robotIds = 1:numRobots;
            taskIds = 1:numTasks;
            
            taskAssign = zeros(numRobots,1);
            robotMotivation = zeros(numTasks,numRobots);
            
            for t=1:numTasks
                for r=1:numRobots
                    robotMotivation(t,r) = this.s_motivation.Get([r t]);
                    %strcat(num2str(robotMotivation(t,r)),'  <CHOOSE')
                end
            end

            %find task I'm most motivated toward
            arrSize = size(robotMotivation);
            arrSize = arrSize(1)*arrSize(2); 
            
            
            while (arrSize  > 0)
                [motivation,rowList] = max(robotMotivation,[],1);
                [MaxM,colNum] = max(motivation);
                rowNum = rowList(colNum);

                %assign the robot to the task
                taskAssign( robotIds(colNum) ) = taskIds(rowNum);
                
                %kill the robot
                robotMotivation(:,colNum) = []; %blow away the robot
                robotIds(colNum) = []; %blow away the robot id

                %kill the task
                robotMotivation(rowNum,:) = []; %blow away that task
                taskIds(rowNum) = []; %blow away the task id
                
                arrSize = size(robotMotivation);
                arrSize = arrSize(1)*arrSize(2); 
                
            end
            
            taskId = taskAssign(robotId);
            %show = strcat(num2str(taskId),' task for ', num2str(robotId),' robot')
            
        end
        
        function StartEpochChooseTask(this,rstateIn)
            [robPos, robOrient, millis, obstaclePos,targetPos,goalPos,targetProperties,robotProperties ]  = rstateIn.GetSnapshot();
            
                 newTask = this.ChooseTask(rstateIn);
                
                if newTask ~= this.taskId && newTask ~= 0
                    this.taskType = targetProperties(newTask,3); %set task type
                    
                    %if nobody has touched the task yet, we can reset our
                    %task timer. Otherwise, it's ambiguous... so we leave
                    %it running pessimistically.
                    %if(targetProperties(newTask,6) == 0)
                    %    this.taskTicks = 0;
                    %end
                    %this.taskTicksTotal(this.taskId)
                    
                end
                if(newTask > 0)
                    if targetProperties(newTask,1) ~= 1 %if it's not finished!
                        this.taskId = newTask;
                    end
                end

        
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   GetTask(this)
        %   
        %   Runs after each iteration. TODO - simplify! This function
        %   retrieves the current task according to the L-ALLIANCE method.
        %   if it is the end of an epoch, this GetTask method calls
        %   ChooseTask. Otherwise this method really only looks up the
        %   currently assigned task (and makes sure it's not returned)
        %           
        function taskId = GetTask(this,rstateIn)    
            [robPos, robOrient, millis, obstaclePos,targetPos,goalPos,targetProperties,robotProperties ]  = rstateIn.GetSnapshot();

            %{
            this.ticks = this.ticks + 1;
            if this.ticks > this.epochSize
                this.ticks = 0;
                newTask = this.ChooseTask(rstateIn);
                
                if newTask ~= this.taskId && newTask ~= 0
                    this.taskType = targetProperties(newTask,3); %set task type
                    
                    %if nobody has touched the task yet, we can reset our
                    %task timer. Otherwise, it's ambiguous... so we leave
                    %it running pessimistically.
                    if(targetProperties(newTask,6) == 0)
                        this.taskTicks = 0;
                    end
                    
                end
                if(newTask > 0)
                    if targetProperties(newTask,1) ~= 1 %if it's not finished!
                        this.taskId = newTask;
                    end
                end
            end
            %}
            
            %make sure the task isn't completed on every iteration.
            numTasks = size(targetProperties);

            if this.taskId > 0 && this.taskId <= numTasks(1) 
                carriedBy = abs(targetProperties(this.taskId,4));
                
                %  drop the task under certain conditions:
                if targetProperties(this.taskId,1) == 1 
                    this.UpdateTaskTimes();
                    this.taskId = 0;
                elseif(carriedBy ~=0 && carriedBy ~= rstateIn.id)
                    this.taskId = 0;
                end
                
                % update task timers
                if this.taskId > 0
                    %if we should, update the maximum task complete time
                    % our current time is longer than our saved maximum
                    if this.taskTicksTotal(this.taskId) > this.taskTimes(this.taskType,2)
                        this.taskTimes(this.taskType,2) = this.taskTicksTotal(this.taskId);
                    end

                    % if we should, update the minimum task complete time
                    % IE we have a default value and are finding we are taking
                    % longer than our guess
                    if this.taskTimesDefault(this.taskType) == 1
                        if this.taskTicksTotal(this.taskId) > this.taskTimes(this.taskType,1)
                            this.taskTimes(this.taskType,1) = this.taskTicksTotal(this.taskId);
                        end
                    end
                end
            end
            taskId = this.taskId;
        end
    end
    
end

