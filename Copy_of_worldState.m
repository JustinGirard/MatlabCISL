classdef worldState < handle
    %ROBOT Summary of this class goes here
    %   Detailed explanation goes here
    % Notes (to do items summary)
    % - Prof Emami - email him Thesis schedule
    % X show robot types on playback (masses change line thickness)
    % X show target types
    % X stop robot when box returned right away
    % - show current target using a dotted line from each robot
    % - up to 5 robots
    % - system diagram
    
    
    % - add in quality tracking in a reasonable way
    % - pull team configuration into config file
    % - pull random vs repeat test into config file
    % - one class at a time - all parameters to config file
    % - add in L-Alliance mechanism (should assign big robot to big block
    % and little robot to little block - eventually)
    % - Refactor so all objects exist in same array
    % -   - RobotState is just a sub-array with locally relevant data
    properties
        milliseconds = 0;

        robotPos = [];
        robotVelocity = [];
        robotOrient = [];
        %robotProperties [currentTarget rotationStep mass speedStep] 
        robotProperties = [];
        converged = 0;
        
        obstaclePos = [];
        obstacleVelocity = [];
        obstacleOrient = [];
        targetPos = [];
        targetVelocity = [];
        targetOrient = [];  
        
        %targetProperties [isReturned weight size] 
        targetProperties = [];
        
        goalPos = [];

        robotPos_inital = [];
        robotVelocity_inital = [];
        robotOrient_inital = [];
        robotProperties_inital = [];
        
        obstaclePos_inital = [];
        obstacleVelocity_inital = [];
        obstacleOrient_inital = [];

        targetPos_inital = [];
        targetVelocity_inital = [];
        targetOrient_inital = [];        
        targetProperties_inital = [];        

        goalPos_inital = [];
        
        
        robotSize = 0.5;
        obstacleSize = 0.5;
        targetSize = 0.5;
        goalSize = 1.0;
        
        robotMass = 1;
        targetMass = 1;
        obstacleMass = 0; %used as fixed in code.

        
        CONST_DIMENSION = 3;
        WIDTH = 0;
        HEIGHT = 0;
        DEPTH = 0;
        TYPE_OBSTACLE = 1;
        TYPE_ROBOT = 2;
        TYPE_TARGET = 3;

    
    end
    
    methods
        %Constructor
        function this = worldState(configId)
            %TODO - Rafactor so all objects are in one array and handeled
            %at the same time. It's very silly to have three seperate
            %idendical data structures justin
            %TODO - rafactor so positions AND orientations are stored in
            %one vector, not two.

            c = Configuration.Instance(configId);
            this.WIDTH = c.world_Height;
            this.HEIGHT = c.world_Width;
            this.DEPTH = c.world_Depth;
            
            
            this.randomizeState(c.numRobots, c.numObstacles,c.numTargets,configId);
            
            this.obstaclePos_inital =  this.obstaclePos;
            this.obstacleOrient_inital  = this.obstacleOrient ;
            this.obstacleVelocity_inital  = this.obstacleVelocity ;
            
            this.robotPos_inital  =  this.robotPos;
            this.robotOrient_inital  = this.robotOrient;
            this.robotVelocity_inital  = this.robotVelocity;
            this.robotProperties_inital = this.robotProperties;

            this.targetPos_inital  =  this.targetPos;
            this.targetOrient_inital  = this.targetOrient ;
            this.targetVelocity_inital  = this.targetVelocity;
            this.targetProperties_inital = this.targetProperties;

            this.goalPos_inital  = this.goalPos;

        end

        function reset(this)
            this.milliseconds = 0;
            this.obstaclePos =  this.obstaclePos_inital;
            this.obstacleOrient  = this.obstacleOrient_inital ;
            this.obstacleVelocity  = this.obstacleVelocity_inital ;
            
            this.robotPos  =  this.robotPos_inital;
            this.robotOrient  = this.robotOrient_inital ;
            this.robotVelocity  = this.robotVelocity_inital ;
            this.robotProperties = this.robotProperties_inital;
            
            this.targetPos  =  this.targetPos_inital;
            this.targetOrient  = this.targetOrient_inital ;
            this.targetVelocity = this.targetVelocity_inital;
            this.targetProperties = this.targetProperties_inital;
            this.converged = 0;
            this.goalPos  = this.goalPos_inital;       
            
        end
        
        function randomState = randomizeState(this,numRobots, numObstacles,numTargets,configId)
            
            c = Configuration.Instance(configId);
            
            this.obstaclePos = zeros(numObstacles,3);
            this.obstacleOrient = [zeros(numObstacles,2) rand(numObstacles,1)*2*pi];
            this.obstacleVelocity = zeros(numObstacles,3);
            
            this.robotPos = zeros(numRobots,3);
            this.robotOrient = zeros(numRobots,this.CONST_DIMENSION);
            this.robotVelocity = zeros(numRobots,3);
            %robotProperties [currentTarget rotationStep mass speedStep typeId] 
            robotTypes = c.robot_Type;
            
            this.robotProperties = [zeros(numRobots,1) ones(numRobots,1)*0.5 ones(numRobots,1) ones(numRobots,2) ones(numRobots,1)*c.robot_Reach];
            numTypes = size(robotTypes);
            numTypes = numTypes(1);

            i = 1;
            while i <= numRobots
                for j=1:numTypes
                    if(i <= numRobots)
                        this.robotProperties(i,2:5) = robotTypes(j,:); 
                        i = i + 1;
                    end
                end
            end
            
            this.targetPos = zeros(numTargets,3);
            this.targetOrient = [zeros(numTargets,2) rand(numTargets,1)*2*pi];
            this.targetVelocity = zeros(numTargets,3);
            
            % [isReturned weight type(1/2)]
            this.targetProperties = [zeros(numTargets,1) 0.5*ones(numTargets,1) ones(numTargets,1)];
            this.targetProperties(1,2:3) = [1 2]; % make one box heavy
            
            this.goalPos = [0 0 0];
            %GetRandomPositions(this,borderSize,paddingSize)
            randomPositions = this.GetRandomPositions(2,0.5);
            
            %assign the random (non conflicting) locations, that meet
            %several awesome criteria
            preOffset = 0;
            for i=1:numObstacles,        
                this.obstaclePos(i,:) = [randomPositions(i+preOffset,:) 0];
            end
            
            preOffset = numObstacles;
            for i=1:numRobots,        
                this.robotPos(i,:) = [randomPositions(i+preOffset,:) 0];
            end
            
            preOffset = numObstacles+numRobots;

            for i=1:numTargets,        
                this.targetPos(i,:) = [randomPositions(i+preOffset,:) 0];
            end
            i = i+1;
            this.goalPos = [randomPositions(i+preOffset,:) 0];
        end
        
        %Get Goal Position vector
        function val = GetGoalPos(this)
           val = this.goalPos;
        end
                
        
        %Get Robot Position vector
        function val = GetRobotPos(this,id )
           val = this.robotPos(id,:);
        end
        
        function conv = GetConvergence(this)
            conv = this.converged;
        end
        
        %Get Robot Orientation vector
        function val = GetRobotOrient(this,id )
           val = this.robotOrient(id,:);
        end        
        
        %Set Robot Position 
        function val = SetRobotPos(this,posIn,id)
           this.robotPos(id,:) = posIn;
           val = 1;
        end
        
        %Set robot orientation
        function val = SetRobotOrient(this,newOrient,id)
            %TODO - capture assignment errors here.
            this.robotOrient(id,:) = newOrient;
            val = 1;
        end
        
        %Detect collisions and do required work due to collisions
        function collide = RobotCollide(this,newPoint,type,id)
            %find the size to be used
            if type == 1
                mySize = this.obstacleSize;
            elseif type == 2
                mySize = this.robotSize;
            else %type == 3
                mySize = this.targetSize;
            end

            %Test against Robots (other robots)
            robDist = bsxfun(@minus,this.robotPos, newPoint);
            if type==2 ; robDist(id) = []; end; 
            robDist = robDist(:,1).^2 + robDist(:,2).^2 + robDist(:,3).^2;
            robDist = sqrt(robDist);
            minDistRobot = min(robDist);

            %Test against Targets
            targetDist = bsxfun(@minus,this.targetPos, newPoint);
            if  type == 3 ; targetDist(id) = []; end; 
            targetDist = targetDist(:,1).^2 + targetDist(:,2).^2 + targetDist(:,3).^2;
            targetDist = sqrt(targetDist);
            minTargetDist = min(targetDist);
            
            collide = 1;
        
        end
        
        
        %ValidPoint: evaluate if an objects movement in this worldState is valid
        function valid = ValidPoint(this,newPoint,type,id)
            %find the size to be used
            if type == 1
                mySize = this.obstacleSize;
                myVelocity = this.obstacleVelocity(id,:);
                myPos = this.obstaclePos(id,:);
                myMass = this.obstacleMass;
                myStrength = 1;
                
            elseif type == 2
                mySize = this.robotSize;
                myVelocity = this.robotVelocity(id,:);
                myPos = this.robotPos(id,:);
                myMass = this.robotMass;
                myStrength = this.robotProperties(id,3);

            else %type == 3
                mySize = this.targetSize;
                myVelocity = this.targetVelocity(id,:);
                myPos = this.targetPos(id,:);
                myMass = this.targetMass;
                myStrength = 1;

            end
            
            %Test against world boundaries
            if newPoint(1) - mySize < 0; valid=0; return; end;
            if newPoint(2) - mySize < 0; valid=0; return; end;
            if newPoint(3) < 0; valid=0; return; end;
            
            if newPoint(1) + mySize > this.WIDTH; valid=0; return; end;
            if newPoint(2) + mySize > this.HEIGHT; valid=0; return; end;
            if newPoint(3)  > this.DEPTH; valid=0; return; end;
            
            
            %Test against Obstacles
            obsDist = bsxfun(@minus,this.obstaclePos, newPoint);
            if  type == 1 ; obsDist(id,:) = [100 100 100]; end; 
            obsDist = obsDist(:,1).^2 + obsDist(:,2).^2 + obsDist(:,3).^2;
            obsDist = sqrt(obsDist);
            [minDist,closestObstacleId] = min(obsDist);

            %Test against Robots (other robots)
            robDist = bsxfun(@minus,this.robotPos, newPoint);
            if type==2 ; robDist(id,:) = [100 100 100]; end; 
            robDist = robDist(:,1).^2 + robDist(:,2).^2 + robDist(:,3).^2;
            robDist = sqrt(robDist);
            [minDistRobot,closestRobotId] = min(robDist);

            %Test against Targets
            targetDist = bsxfun(@minus,this.targetPos, newPoint);
            if  type == 3 ; targetDist(id,:) = [100 100 100]; end; 
            %next lines "moves" targets that are returned.
            
            targetDist = bsxfun(@plus,targetDist, (abs(this.targetProperties(:,1)).*100));
            
            targetDist = targetDist(:,1).^2 + targetDist(:,2).^2 + targetDist(:,3).^2;
            targetDist = sqrt(targetDist);
            [minTargetDist,closestTargetId] = min(targetDist) ;            
            
            if minDist < mySize + this.obstacleSize
                valid = 0;
                %closestId = find(obsDist, minDist, 'first');

                %preform a collision and update the velocities
                physicsArray1 = [this.obstaclePos(closestObstacleId,:) this.obstacleVelocity(closestObstacleId,:) this.obstacleSize this.obstacleMass];
                physicsArray2 = [myPos myVelocity mySize myMass];
                [physicsArray1,physicsArray2] = this.Collide(physicsArray1,physicsArray2);                  
                this.obstaclePos(closestObstacleId,:) = physicsArray1(1:3);
                this.obstacleVelocity(closestObstacleId,:) = physicsArray1(4:6);
                myPos = physicsArray2(1:3);
                myVelocity = physicsArray2(4:6);
                return;
            end
            
            if minDistRobot < mySize + this.robotSize
                valid = 0;
                %closestId = find(robDist, minDistRobot, 'first');

                %preform a collision and update the velocities
                physicsArray1 = [this.robotPos(closestRobotId,:) this.robotVelocity(closestRobotId,:) this.robotSize this.robotMass];
                physicsArray2 = [myPos myVelocity mySize myMass];
                [physicsArray1,physicsArray2] = this.Collide(physicsArray1,physicsArray2);                  
                this.robotPos(closestRobotId,:) = physicsArray1(1:3);
                this.robotVelocity(closestRobotId,:) = physicsArray1(4:6);
                myPos = physicsArray2(1:3);
                myVelocity = physicsArray2(4:6);
            
                return;
            end
            
            if minTargetDist < mySize + this.targetSize
                valid = 0;
                %closestId = find(targetDist, minTargetDist, 'first');
                
                %preform a collision and update the velocities
                boxMass = this.targetProperties(closestTargetId,2);

                physicsArray1 = [this.targetPos(closestTargetId,:) this.targetVelocity(closestTargetId,:) this.targetSize boxMass];
                physicsArray2 = [myPos myVelocity mySize myMass*myStrength];
                [physicsArray1,physicsArray2] = this.Collide(physicsArray1,physicsArray2);                  
                this.targetPos(closestTargetId,:) = physicsArray1(1:3);
                this.targetVelocity(closestTargetId,:) = physicsArray1(4:6);
                
                myPos = physicsArray2(1:3);
                myVelocity = physicsArray2(4:6);
                
                return;
            end
            valid = 1;
            
        end
        
        %physicsArray = [ pos(3) velocity(3) radius(1) mass(1)]
        function [phyResult1,phyResult2]= Collide(this,physicsArray1,physicsArray2)
            %first lets get complete vectors
            pa1 = physicsArray1;
            pa2 = physicsArray2;
            %first lets find the vector between them, from 1->2
            b = pa2(1:3) - pa1(1:3);
            
            %velocities and mass
            v1 = pa1(4:6);
            v2 = pa2(4:6);
            m1 = pa1(8);
            m2 = pa2(8);
            if(m1 == 0)
                m1 = 10000;
            end
            if(m2 == 0)
                m2 = 10000;
            end

          %  b = [0 1 0];
            b = b(:)./sqrt(b(1)^2 + b(2) ^2 + b(3) ^2);

            v1a = ((v1*b)*b)';
            v1b = v1 - v1a;

            v2a = ((v2*b)*b)';
            v2b = v2 - v2a;

            %mo1a = v1a*m1;
            %mo2a = v2a*m2;

            vf1a = ((m1 -  m2).*v1a + 2*(m2.*v2a))./(m1+m2);

            vf2a = ((m2 -  m1).*v2a + 2*(m1.*v1a))./(m1+m2);
            vf1 = vf1a+ v1b;
            vf2 = vf2a+ v2b;
            if(m1 == 0)
                vf1 = 0;
            end
            if(m2 == 0)
                vf2 = 0;
            end
            phyResult1 = [physicsArray1(1:3) vf1 physicsArray1(7:8)];
            phyResult2 = [physicsArray2(1:3) vf2 physicsArray2(7:8)];
            
            
            
            
        end
        
        function targetVelocity = MoveTarget(this,robotId,targetId,powerAngle)
            %make sure distance is close enough
            if(targetId == 0)
                val = 1;
                return;
            end
            posDiff = this.robotPos(robotId,:) - this.targetPos(targetId,:);
            posDiff = sqrt(posDiff.^2);
            posDiff = sum(posDiff);
            robotReach = this.robotProperties(robotId,6);
            if(posDiff <= robotReach)
                targetMass = this.targetProperties(targetId,2);
                robotStrength = this.robotProperties(robotId,3);
                amount = powerAngle(1);
                angle = powerAngle(2);
                amount = amount*robotStrength/targetMass;
                addVelocity = [amount*cos(angle ) amount*sin(angle ) 0];
                
                this.targetVelocity(targetId,:) = addVelocity;
            end
            targetVelocity = this.targetVelocity(targetId,:);
        end
        
        %called when we would like to move an object
        function [orientVelocity, currentVelocity] = MoveRobot(this,id,amount,rotation)
            %find a new orientation 
            newOrient =[ 0 0 mod(this.robotOrient(id,3) + rotation,2*pi)];
            
            %find a new velocity
            addVelocity = [amount*cos(newOrient(3)) amount*sin(newOrient(3)) 0];
            currentVelocity = this.robotVelocity(id,:);
            
            %increase velocity up to a maximum instantly
            for i=1:2
                %if we are going very slow, or backwards, speed up as much
                %as possible
                if abs(currentVelocity(i) + addVelocity(i)) <= abs(addVelocity(i))
                    currentVelocity(i) = currentVelocity(i) + addVelocity(i);
                %if we are going slower than our max, and can use a boost -
                %go to max speed
                elseif abs(currentVelocity(i) + addVelocity(i)) > abs(addVelocity(i)) && ...
                    abs(currentVelocity(i)) < abs(addVelocity(i))
                    currentVelocity(i) = addVelocity(i) ;
                end
            end
            
            this.SetRobotOrient(newOrient,id);
            this.robotVelocity(id,:) = currentVelocity;
            orientVelocity = [0 0 rotation];
            val = 1;
        end
        
        function UpdateRobotTarget(this,id,targetId)
            this.robotProperties(id,1) = targetId;
           
        end
        
        function val = RunPhysics(this,timeMilliseconds)
            %deal with inst velocity
            %apply friction
            decay = 0;
            [ numRobots, dimensions] = size( this.robotPos);
            for i=1:numRobots
                newPos = this.robotPos(i,:) + this.robotVelocity(i,:);
                if this.ValidPoint(newPos,this.TYPE_ROBOT,i) == 1
                    this.robotPos(i,:) = newPos;
                end
                this.robotVelocity(i,:) = this.robotVelocity(i,:)*decay;
            end
            
            [ numTargets, dimensions] = size( this.targetPos);
            for i=1:numTargets
                newPos = this.targetPos(i,:) + this.targetVelocity(i,:);
                if this.ValidPoint(newPos,this.TYPE_TARGET,i) == 1
                    this.targetPos(i,:) = newPos;
                end
                this.targetVelocity(i,:) = this.targetVelocity(i,:)*decay;
            end
            
            %see if a box is magically returned
            targetDistanceToGoal = bsxfun(@minus,this.targetPos,this.goalPos);
            targetDistanceToGoal = targetDistanceToGoal.^2;
            targetDistanceToGoal = sum(targetDistanceToGoal,2);
            targetDistanceToGoal = sqrt(targetDistanceToGoal);
            targetDistanceToGoalBarrier = targetDistanceToGoal - (this.targetSize + this.goalSize);
            i = 1;
            [numTargets,rows] = size(targetDistanceToGoal);
            
            %targetDistanceToGoalBarrier(2)
            while i <= numTargets
                if(targetDistanceToGoalBarrier(i) < -this.targetSize)
                    this.targetProperties(i) = 1;
                end
                i = i + 1;
            end
            
            targetsReturned = sum(this.targetProperties(:,1));
            if targetsReturned == numTargets
                this.converged = 1;
            end
            
            val = 1;
        end

        %Snapshot alg
        function [robPos, robOrient, millis, obstaclePos,targetPos,goalPos,targetProperties,robotProperties ] ...
                = GetSnapshot(this)
            robPos = this.robotPos;
            robOrient = this.robotOrient;
            obstaclePos = this.obstaclePos;
            targetPos = this.targetPos;
            millis = this.milliseconds;
            goalPos = this.goalPos;
            targetProperties = this.targetProperties;
            robotProperties = this.robotProperties;
            
        end
        
        function targetState =  GetTargetState(this)
                targetState = [this.targetPos this.targetOrient];
        end

        function obstacleState =  GetObstacleState(this)
                obstacleState = [this.obstaclePos this.obstacleOrient];
        end
        
        
        function randomPositions = GetRandomPositions(this,borderSize,paddingSize)
            worldWidth = this.WIDTH;
            worldHeight = this.HEIGHT;
            border = borderSize;
            padding = paddingSize;
            objectRadius = 1 + padding;

            slotH = floor( (worldWidth - border*2)/ (objectRadius+paddingSize));
            slotV = floor((worldHeight - border*2)/ (objectRadius+paddingSize));

            positions = zeros(slotH*slotV,2);

            x = 1;
            hor = combnk(1:slotH,1);
            hor= randperm(length(hor));
            for i=1:slotH,
                ver = combnk(1:slotV,1);
                ver= randperm(length(ver))';
                for j=1:slotV,
                    positions(x,:) =  [hor(i) ver(j)];
                    x= x+ 1;
                end
              
            end
            
            posRandom =  zeros(slotH*slotV,2);

            for z=1:3,
                order = randperm(length(1:(slotH*slotV)))';
                for i=1:length(order),
                    posRandom(i,:) = positions(order(i),:);    
                end
                positions = posRandom;
            end
            
            positions = positions.*(objectRadius+paddingSize);
            positions = bsxfun(@plus,positions,[borderSize borderSize]);
            randomPositions = positions;
        end
        
    end
    
end

