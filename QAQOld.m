classdef QAQ < handle 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
    %Q-Learning, Advice Exchange, L-Alliance
    % Advise a single robot
    % Tell it what actions to take given a robot state vector
    
    properties
        qteam = [];
        qlearning = [];
        advisorqLearning = [];
        adviceexchange = [];
        
        boxForce = 0.05;
        stepSize =0.1;
        rotationSize = pi/4;

        angle = [0; 90; 180; 270];
        
        actionsAmount = 7;

        targetReward = 10;
        arrBits = 20;
        arrDimension = 4;
        learnedActions = 0;
        randomActions = 0;
        maxGridSize = 11;
        targetId = 0;
        %rxxewardObtained = 0;
        decisionsMade = 0;
        targetOld = 1000;
        
        configId = 1;
        %needed for particle filter
        lastAction = 0;
        worldHeight = 0;
        worldWidth = 0;
        %encodedCodes = zeros(200,200,400);
        actionCount = 0;
        
        triggerDistance = 0.4;
        
        simulationRunActionsTarget = 0;
        simulationRunLearnsTarget = 0;
        simulationRewardObtainedTarget = 0;

        simulationRunActions = 0;
        simulationRunLearns = 0;        
        simulationRewardObtained = 0;
        robotId = 0;
        
        epochTicks = 0;
        epochMax = 200;
        s_encodedCodes = [];
        
        pIncorrectAction = 0;
        numActions = 0;
        
        aIncorrectReward = 0;
        aTrueReward = 0;
        aFalseReward = 0;
        numLearns = 0;        
        
        teamId = [];
        rewardLast = 0;
        lastTeamAction = 1;
        
        advexc_on = 0;        
    end
    
    
    properties (Constant)
        %SysEncodedCodes = zeros(200,200,400);

        %s_encodedCodes = SparseHashtable(24);

    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function this = QAQ(configId,robotId,encCodes)
            %this.s_encodedCodes = zeros(200,200,400);
            this.s_encodedCodes =encCodes;
            this.robotId = robotId;
            this.configId = configId;
            
            c = Configuration.Instance(this.configId );

            this.maxGridSize = c.cisl_MaxGridSize;
            this.worldHeight = c.world_Height;
            this.worldWidth = c.world_Width;
            
            this.boxForce = 0.05;

            %instance core objects
            this.qlearning = Qlearning(this.actionsAmount,this.arrBits,configId );
            
            % State structure
            % 
            % Task Types    -> TT(1-N), {1,0}
            
            % independnt from
            % Return Status -> RS(1-N),{1,0}

            % independnt from
            % Other Robot On Task -> OR (1-N), {1,0}
            
            %State = [TT RS OR]
            this.teamId = [0 0 1]; 
            teamActionsAmount = 3;
            this.qteam = Qlearning(teamActionsAmount,10,configId );
            
            this.adviceexchange = AdviceExchange(robotId,c.numRobots,c.robot_sameStrength);
            
            this.advisorqLearning =  this.qlearning;
            
            this.triggerDistance = c.cisl_TriggerDistance;
            %set up robot properties (should live in robot layer
            this.epochTicks = 0;
            

            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function SetRobotProperties(this,stepSizeIn,rotationSizeIn)
            this.stepSize = stepSizeIn;
            this.rotationSize = rotationSizeIn;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function targetId = GetTask(this)
            targetId = this.targetId;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function val= GetLearnedActions(this)
            val = this.qlearning.learnedActions;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function ld = GetIndividualLearningData(this)
            ld = this.qlearning.GetLearningData();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   GetTeamLearningData
        %   
        %   Return the maximum and minimum taus.
        %   This is meerely longest and shortest task
        %   completion time
        %   [task1_min task1_max   task2_min task2_max]
        %

        function td = GetTeamLearningData(this)
            td = [0 0 0 0];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        % Reset - we have changed to a new world and need to drop any values
        % or settings that are related to previous simulations
        function Reset(this)
            this.targetId = 0;
            this.rewardLast  = 0;
            this.teamId = [0 0 1]; 
            this.lastTeamAction = 1;
                  
            this.qteam.Reset();
            this.qlearning.Reset();
            this.epochTicks = 0;
            this.advisorqLearning = this.qlearning;
            %track our actions, reward, and times we have 'learned'
            this.simulationRunActions = 0;
            this.simulationRunLearns = 0; 
            this.simulationRewardObtained = 0;

            %track our actions, reward, and times we have 'learned'
            %towards a target
            this.simulationRunActionsTarget = 0;
            this.simulationRunLearnsTarget = 0; 
            this.simulationRewardObtainedTarget = 0;

        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function val= GetRandomActions(this)
            val = this.qlearning.randomActions;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function CheckUnavaliableTask(this,robotState)
                [robPos, robOrient, millis, obstaclePos,targetPos,goalPos,targetProperties,robotProperties ] ...
                    = robotState.GetSnapshot();
            if(this.targetId > 0)
                if targetProperties(this.targetId,1) == 1 
                    this.targetId = 0;
                end
            end
            if(this.targetId > 0)
                if targetProperties(this.targetId,4) > 0 
                    if targetProperties(this.targetId,4) ~= robotState.id
                        this.targetId = 0;
                    end
                end
            end
        
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function ChooseTask(this,robotState)
            %every epoch each robot learns.
            [robPos, robOrient, millis, obstaclePos,targetPos,goalPos,targetProperties,robotProperties ] ...
                = robotState.GetSnapshot();
            % targetProperties       
            % 1 [isReturned
            % 2 weight                 
            % 3 type(1/2)          
            % 4 carriedBy           
            % 5 size                   
            % 6 lastRobotToCarry]
            % A few needed variables
            %targetTypes =  targetProperties(:,3)-1;
            %returnStatus =  targetProperties(:,1);
            carriedByMe = (targetProperties(:,4)==robotState.id);
            %otherRobotAssigned = (targetProperties(:,4) >0) - (carriedByMe );

            % A measure of our returned targets
            targetsReturned = sum(targetProperties(:,1).*5,1);
            targetsCarried = sum((targetProperties(:,4) > 0));
            rewardCurrent = targetsReturned+ targetsCarried;
            
            %building the state
            % [freeType1Targets freeType2Targets freeRobots] 
            freeTargets = (targetProperties(:,1) + targetProperties(:,4)) == 0;
            
            
            freeRobotCount = size(robPos,1) -targetsCarried;
            
            freeTargetsT1 = (targetProperties(:,3) == 1).*freeTargets;
            freeTargetsT2 = (targetProperties(:,3) == 2).*freeTargets;
            
            freeTargetsT1 = sum(freeTargetsT1,1); 
            freeTargetsT2 = sum(freeTargetsT2,1); 
            
            
            freeRobotCount = freeRobotCount+1;%this just avoids a [0 0 0] vector
            if(freeRobotCount > 7)
                freeRobotCount = 7;
            end
            % the new ID
            currentId = [freeTargetsT1 freeTargetsT2 freeRobotCount];%[TT RS OR]
            
            this.qteam.Learn(this.teamId,currentId,this.lastTeamAction,rewardCurrent );
            % update values
            this.teamId = currentId;
            this.rewardLast = rewardCurrent;
            [quality,experienceProfile] = this.qteam.GetUtility(this.teamId ,0.01);

            totalQual = sum(quality);
            zeroQual = (quality == 0);


            quality = quality + zeroQual.*totalQual.*0.05;

            totalQual = sum(quality);
            actionSelect = totalQual*rand(); %pick a number
            
            i = 0;
            index =1;
            num = 0;
            while (num < actionSelect)
                i = i+1;
                num = num + quality(i);
                if num > actionSelect
                    actionIndex = i;
                    %actionIsSelected = index
                    break;
                end
            
            end
            
            
            this.lastTeamAction = actionIndex;
            
            
            % Constraint 2 - can't choose a task that is finished
            % Constraint 3 - can't choose a task other than a carried task
            %now we execute the action.
            freeTargetsT1 = (targetProperties(:,3) == 1).*freeTargets;
            freeTargetsT2 = (targetProperties(:,3) == 2).*freeTargets;
            
            if(sum(carriedByMe,1) == 0) % Constraint 1 - can't choose a task that is carried 
                if(actionIndex > 1)
                    targetType = actionIndex-1;
                    if(targetType ==1)
                        ind = find(freeTargetsT1);
                    else
                        ind = find(freeTargetsT2);
                    end
                    if(ind > 0)
                        ind = randsample(ind,1);
                        this.targetId = ind;
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        % Get the action from the learning layer, considering the current
        % robotState
        function [action, actionId,experienceProfile,acquiescence] = Act(this,rstate)
            this.epochTicks =	this.epochTicks +1;
            if(this.epochTicks > this.epochMax)
                this.epochTicks = 1;
            end
            
            if(this.epochTicks == 1)
                this.ChooseTask(rstate);
            end
            this.CheckUnavaliableTask(rstate);
            
            %make sure we are working toward the right target (box)

            this.simulationRunActions = this.simulationRunActions +1;
            if(this.targetId > 0)
                this.simulationRunActionsTarget = this.simulationRunActionsTarget +1;
            end
            
            if(this.actionCount > 0)
                this.actionCount = this.actionCount -1;
                action = this. lastAction (2:3);
                actionId = this.lastAction (1);
                return;
            end
 
            
            
            id = this.GetQualityId(rstate,0);

            [quality,experienceProfile] = this.advisorqLearning.GetUtility(id,0.01);
            
            [targets,obstacles,goal,borderOfWorld,robot] = rstate.GetCurrentState();
            orientation = robot(6);
            
            angle = this.angle.*(pi/180);
            angle = bsxfun(@plus,angle,orientation);
            angle = mod(angle, 2*pi);
            

            qDecide = [quality(1) this.stepSize 0; 
                       quality(2) 0 this.rotationSize;
                       quality(3) 0 -this.rotationSize;
                       quality(4) this.boxForce angle(1);
                       quality(5) this.boxForce angle(2);
                       quality(6) this.boxForce angle(3);
                       quality(7) this.boxForce angle(4)];
            
                   
      
            %%%%%%%%%%%%%%%%%%%%%%%      
            %  in this section we track the difference in the policy
            trueId = this.GetTrueQualityId(rstate,0);
            [qualityTrue,defaultVarname] = this.advisorqLearning.GetUtility(trueId,0.01);
            
            qDecideTrue = [qualityTrue(1); 
                       qualityTrue(2);
                       qualityTrue(3);
                       qualityTrue(4);
                       qualityTrue(5);
                       qualityTrue(6);
                       qualityTrue(7)];
            
            qDecideMessy = qDecide(:,1);
            qDecideMessy = qDecideMessy / sum(qDecideMessy ,1);
            qDecideTrue = qDecideTrue / sum(qDecideTrue ,1);
            pSum = sum(abs(qDecideTrue -qDecideMessy),1)/2;

            if(this.numActions == 0)
                this.pIncorrectAction = pSum;
                this.numActions = 1;
            else
                this.pIncorrectAction = (this.pIncorrectAction*this.numActions + pSum)/(this.numActions+1);
                this.numActions = this.numActions +1;
            end

            % end difference in policy section
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   
            totalQual = sum(quality);
            zeroQual = (quality == 0);
            %make sure every action has at least 0.005 (0.5%)probability
            %this will help discover new actions, a tiny tiny bit...
            
            quality = quality + zeroQual.*totalQual.*0.05;
            totalQual = sum(quality);
            actionSelect = totalQual*rand(); %pick a number
            
            i = 0;
            index =1;
            num = 0;
            while (num < actionSelect)
                i = i+1;
                num = num + quality(i);
                if num > actionSelect
                    index = i;
                    %actionIsSelected = index
                    break;
                end
            
            end
            
            %[decision,index] = max(qDecide(:,1));
            %action = qDecide(index,1:3);
            action = qDecide(index,2:3);
            this.lastAction = [index action];
            
           % if(index ==1 || index >3)
           %     this.actionCount = 2;
           % end
            acquiescence = 0;
            actionId = index;
            
        end
        
        
  
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function  [pIncorrectAction, numActions ] = GetIncorrectActionProbability(this)
            pIncorrectAction = this.pIncorrectAction;
            numActions = this.numActions;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function  [aIncorrectReward, numLearns ,aTrueReward,aFalseReward] = GetFalseReward(this)
            aIncorrectReward = this.aIncorrectReward;
            aTrueReward = this.aTrueReward;
            aFalseReward = this.aFalseReward;
            numLearns = this.numLearns;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function val = GetElements(this)
            val = this.qlearning.quality.GetElements();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function val = GetCollisions(this)
            val = this.qlearning.quality.GetCollisions();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function val = GetAssignments(this)
            val = this.qlearning.quality.GetAssignments();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function val = GetUpdates(this)
            val = this.qlearning.quality.GetUpdates();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        %  LearnFrom(this,state,actionId)
        %  One robot learns from observing one iteration
        %  state - the resulting robotState
        %  actionId - the action that was taken in the last iteration
        function val = LearnFrom(this,state,actionId)
            rwdfalse =  this.LearnFromUpdate(state,actionId,1,1);
            rwdtrue = this.LearnFromUpdate(state,actionId,0,0);
            val = rwdfalse - rwdtrue;

            this.aIncorrectReward = ((this.aIncorrectReward *this.numLearns) + val)/(this.numLearns+1);
            this.aTrueReward = ((this.aTrueReward *this.numLearns) + rwdtrue)/(this.numLearns+1);
            this.aFalseReward = ((this.aFalseReward *this.numLearns) + rwdfalse)/(this.numLearns+1);
            this.numLearns =this.numLearns + 1; 
        end
        
        function val = LearnFromUpdate(this,state,actionId,updateQVals,sensorTruth )
            if(actionId == 0 && updateQVals==1)

                val = 0;
                return;
            end
            previousStateId = 1;
            currentStateId = 0;
            
            if(sensorTruth  == 1)
                [oldRelativeTargetPos,oldRelativeObstaclePos,oldGoalPos,oldborderOfWorld,oldrobot,oldTargProp] = state.GetSavedState();
                [relativeTargetPos,relativeObstaclePos,goalPos,borderOfWorld,robot,targProp] = state.GetCurrentState();
                id = this.GetQualityId(state,previousStateId);
                idNew = this.GetQualityId(state,currentStateId);
            else
                [oldRelativeTargetPos,oldRelativeObstaclePos,oldGoalPos,oldborderOfWorld,oldrobot,oldTargProp] = state.GetTrueSavedState();
                [relativeTargetPos,relativeObstaclePos,goalPos,borderOfWorld,robot,targProp] = state.GetTrueCurrentState();
                id = this.GetTrueQualityId(state,previousStateId);
                idNew = this.GetTrueQualityId(state,currentStateId);
            end
            targets_change = relativeTargetPos - oldRelativeTargetPos;
            targets_change = floor(targets_change*100);
            %obstacles_change = relativeObstaclePos - oldRelativeObstaclePos;
            goal_change = goalPos - oldGoalPos;

            %[distance,closestTargetId] = min(relativeTargetPos(:,1));
            reward = 0;
            
            distanceIndex = 1; %TODO make into constant


            %learn to go to the home position
            if(this.targetId == 0)
                % % % % %
                %Get Reward for moving closer to targeted box (distance
                %shrinks)
                %goal_change
                %goalPos
                goalDistance = 5;
                %move away from the goal!
                
                if goalPos(distanceIndex ) < goalDistance
                    if goal_change(distanceIndex ) > 0

                        reward = reward +this.targetReward;
                    end
                end
    
                %do one step of QLearning
                if( updateQVals ==1)
                    this.qlearning.Learn(id,idNew,actionId,reward);

                    this.simulationRunLearns = this.simulationRunLearns +1;
                    this.simulationRewardObtained = this.simulationRewardObtained  + reward;
                    if(this.advexc_on == 1)
                        this.adviceexchange.AddReward(reward);
                    end
                end
                val = reward;
                return;
            end
            
            %add a cost to trying to move a box
            %(this is to make sure empty rewards based on noise are not
            %encouraged due to slight pertubations in object locations
            if( actionId > 1)
                reward = -1;
            end
            if( actionId > 3)
                reward = -2;
            end

%Standard Rewards
%Reward	Value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1) Reward for pushing box x m closer to target zone	+0.5
            distanceInital = sum((oldGoalPos(2:4) - oldRelativeTargetPos(this.targetId,2:4)).^2);
            distanceFinal = sum((goalPos(2:4) - relativeTargetPos(this.targetId,2:4)).^2);
            distanceInital = floor(distanceInital *100);
            distanceFinal =floor(distanceFinal *100);
            distance= distanceInital - distanceFinal;
            
            if oldTargProp(this.targetId,1) ~= 1 %if it's not finished!
                if targProp(this.targetId,1) == 1 %if it's finished now!
                    reward = reward + 10; %MASSIVE reward for returning box
                end
                        
            end
            
            
            %  Reward for moving x m closer to the chosen box
            
            if distance > this.triggerDistance*50
                
                 %rwdAdd = this.targetReward*10 -(distanceFinal/30); 
                %if(rwdAdd <= 0)
                %    rwdAdd = 1;
                %end
                rwdAdd = 0.5;% + 0.5* abs(distance/100);
           %     if(this.robotId==1)
           %         disp(strcat('pushed box closer: ',num2str(distance - this.triggerDistance*50 )));
           %     end
                reward = reward + rwdAdd;
%7) Reward for pushing box farther from target zone by x m	-0.3
            %elseif distance < -10
            elseif distance < -this.triggerDistance*50
                reward =reward - 0.3;% - 0.3* abs(distance/100);
                 %'pushed away'
            end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2) Reward for moving x m closer to the chosen box	+0.5
            %if targets_change(this.targetId,distanceIndex ) < -0.15
            if targets_change(this.targetId,distanceIndex ) < -this.triggerDistance*50
                dist = targets_change(this.targetId,distanceIndex ) + this.triggerDistance*50;
                
                % reward = reward + this.targetReward*abs(targets_change(this.targetId,distanceIndex ) ); 
                reward = reward + 0.5;% + 0.5*(abs(targets_change(this.targetId,distanceIndex )/100)); 
                
             %   if(this.robotId==1)
             %       disp(strcat('moved closer: ',num2str(dist)));
             %   end
%8) Reward for moving farther from box by x m	-0.3
            elseif targets_change(this.targetId,distanceIndex ) > this.triggerDistance*50
                reward = reward - 0.3;% - 0.3*(abs(targets_change(this.targetId,distanceIndex )/100)); 
                %'moved away'
                
            end


%3) Reward for reaching box	+1
%4) Reward for reaching target zone	+3
%5) Reward for every iteration of task	-0.01
            reward = reward - 0.01;
%6) Reward for allowing obstacle or another robot to come into minimum range	-1
            
           
            if(reward < 0)
                reward = 0;
            end
            
            %id = this.GetQualityId(state,previousStateId);            
            %idNew = this.GetQualityId(state,currentStateId);

            if( updateQVals == 1)
                %do one step of QLearning
                this.qlearning.Learn(id,idNew,actionId,reward);

                this.simulationRunLearns = this.simulationRunLearns +1;
                this.simulationRewardObtained = this.simulationRewardObtained  + reward;

                if(this.targetId > 0)
                    this.simulationRunLearnsTarget = this.simulationRunLearnsTarget +1;
                    this.simulationRewardObtainedTarget = this.simulationRewardObtainedTarget + reward;
                end
                
                if(this.advexc_on == 1)
                    this.adviceexchange.AddReward(reward);
                end
             end
            val = reward;
            
        end
        
        
        %function [reward, decisions, targetReward] = GetTotalReward(this)
        %    reward = this.qlearning.rewardObtained;
        %    decisions = this.qlearning.decisionsMade;
        %    targetReward = this.simulationTargetRewardObtained;
        %end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function actionProfile = GetRunActionProfile(this)
            actionProfile = [this.simulationRunActions this.simulationRunLearns this.simulationRewardObtained];
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function actionProfile = GetRunActionProfileTarget(this)
            actionProfile = [this.simulationRunActionsTarget this.simulationRunLearnsTarget this.simulationRewardObtainedTarget];
        end

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function qualityId = GetQualityId(this,state,fromSavedState)

            qualityId = this.GetNewQualityIdFromState(state,fromSavedState,0);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function qualityId = GetTrueQualityId(this,state,fromSavedState)

            qualityId = this.GetNewQualityIdFromState(state,fromSavedState,1);
        end
                
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
        function qualityId = GetNewQualityIdFromState(this,state,fromSavedState,fromGroundTruth)
            
            if(fromGroundTruth == 1)
                if(fromSavedState == 1)
                    [relativeTargetPos,relativeObjectPos,goalPos,borderWithWorld,robot,targetProperties] = state.GetTrueSavedState();
                else
                    [relativeTargetPos,relativeObjectPos,goalPos,borderWithWorld,robot,targetProperties] = state.GetTrueCurrentState();
                end
            else
                if(fromSavedState == 1)
                    [relativeTargetPos,relativeObjectPos,goalPos,borderWithWorld,robot,targetProperties] = state.GetSavedState();
                else
                    [relativeTargetPos,relativeObjectPos,goalPos,borderWithWorld,robot,targetProperties] = state.GetCurrentState();
                end
            end
 
            [distance,closestObstacleId] = min(relativeObjectPos(:,1));
            orient = robot(6);
            
            if(orient > 2*pi)
                orient = mod(orient, 2*pi);
            end
            
            if(this.targetId == 0)
                targetPosEnc = [0 0];
                goalPosEnc = goalPos(2:3);
                borderPosEnc = borderWithWorld(1:2);
                closestObs= relativeObjectPos(closestObstacleId,2:3);
                targetType = 0;
            else
                
                targetPosEnc = relativeTargetPos(this.targetId,2:3);
                goalPosEnc = goalPos(2:3);
                borderPosEnc = borderWithWorld(1:2);
                closestObs= relativeObjectPos(closestObstacleId,2:3);
                targetType = targetProperties(this.targetId,3);
            end
            
            c = Configuration.Instance(this.configId);
            bx = this.worldWidth*2;
            by = this.worldHeight*2;

            %5 bits each
             id= [this.EncodePos(targetPosEnc,orient )...
             this.EncodePos(goalPosEnc,orient )...
             this.EncodePos(borderPosEnc ,orient )...
             this.EncodePos(closestObs,orient)...
             targetType ...
             ];
             qualityId = id;
             
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
      function val = GetMemoryOccupancy(this)
        val = this.qlearning.quality.OccupancyPercentage();
      end
      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   Class Name
        %   
        %   Description 
        %   
        %   
        %   
      function code = EncodePos(this,dist,orient)
        %dist = [-200 -100];
        
        d= floor(dist+100);
        o= round(orient+1);
        if(o <= 0)
            o = 1;
        end
        %s_encodedCodes
        %[d(1) d(2) o]
        %if(this.encodedCodes(d(1),d(2),o) ~= 0)
        %    code = this.encodedCodes(d(1),d(2),o);
        %testCode = this.s_encodedCodes.Get([d(1) d(2) o]);
        if(d(1) < 0) d(1) = 0; end
        if(d(2) < 0) d(2) = 0; end
        if(d(1) >200) d(1) = 200; end
        if(d(2) >200) d(2) = 200; end
        
        testCode = this.s_encodedCodes.cd(d(1), d(2), o);
        %testCode = this.s_encodedCodes(d(1), d(2), o);
        if(testCode ~= 0 || isnan(testCode))
            code = testCode;
            return;
        else
            angle = atan2(dist(2),dist(1))*180/pi;
            angle = angle - orient*180/pi; %adjust to make angle relative
            if(angle <0)
                angle = angle + 360;
            end

            if(angle <= 180)
                positionCode=  floor(angle*3/180)+1;
            else
                positionCode = 4;
            end
            %distanceCode = floor(log((sum(dist.^2)+1)))*4;
            distanceCode = floor(log((sum((abs(dist)*4).^2)+1)))*4;

            if(distanceCode >= 16)
                distanceCode = 16;
            end

            code = positionCode +distanceCode;
            code = full(code);
            %this.s_encodedCodes.Put([d(1) d(2) o],code);

            this.s_encodedCodes.cd(d(1), d(2), o) = code;
            
            %this.s_encodedCodes(d(1),d(2),o) = code;
        end
      end
      
  end
    
end

