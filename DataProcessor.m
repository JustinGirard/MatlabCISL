classdef DataProcessor
    %DATAPROCESSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   UpdateFileWithCoopData - 
        %   
        %   So there was a big bad time in history, where I had to
        %   creep all the 'awesome' replay data. I had to update the files
        %   with rates of cooperation, defined as the sum of actions, made
        %   by individual robots, which result in cooperation
        %   
        function [success] = UpdateFileWithCoopData(this,file,forceUpdate)
            
            %First, check to see if we need to update the file
            doUpdate = 0;
            for fileType=1:2
                if(fileType == 1)
                    fileTypeString = '_blob';
                end
                if(fileType == 2)
                    fileTypeString = '_iter_targ_';
                end
                cd('results');
                files = dir(strcat(file,fileTypeString,'.mat'));
                cd('..');
                if(size(files,1) > 0)
                    load (strcat('.\results\',file,fileTypeString));
                    if(size(iterDatTarg,2) < 5 || forceUpdate == 1)
                        doUpdate =1;
                    end
                end
            end
            
            if(doUpdate == 0)
                disp(strcat('Not Loading . . . Dont need to update: ',file,':'));
                success = 0;
                return;
            end
            
            coopList = [];
            success = 0;

            %First we load the files
            cd('results');
            cd('replay');
            files = dir(strcat(file,'_replay_*'));
            cd('..');
            cd('..');

            %then we find the maximum number of iterations
            maxNumber = 0; 
            for f=1:size(files,1)
                strNumberLocation = strfind(files(f).name,'_replay_');
                strNumberMat = files(f).name(strNumberLocation:size(files(f).name,2));
                strNumber =  strrep(strrep(strNumberMat,'_replay_',''),'.mat','');
                number = str2num(strNumber);
                if(number > maxNumber)
                    maxNumber = number;
                end
            end
            disp(strcat('Max Number for: ',file, ': ', num2str(maxNumber)));


            %then we verify all files exist before proceeding, otherwise we skip.
            cd('results');
            cd('replay');
            foundAll = 1;
            for f=1:maxNumber
                files = dir(strcat(file,'_replay_',num2str(f),'.mat'));
                if(size(files,1) ==0)
                    foundAll =0;
                    break;
                end
            end
            cd('..');
            cd('..');

            if(foundAll == 0 )
                disp(strcat('Not Loading . . . Missing data for: ',file,':',strcat(file,'_replay_',num2str(f))));
                return;
            elseif(maxNumber < 300)
                disp(strcat('Not Loading . . . File is not 300 dat points: ',file,':',strcat(file,'_replay_',num2str(f))));
                return;
            else
                disp(strcat('Loading . . : ',file));
            end
            
            %Get all the COOP data from source files.
            for i=1:maxNumber
                fileFull =strcat(file,'_replay_',num2str(i));
                coopSum = this.ExtractCoopReplayData(fileFull);
                coopList = [coopList;coopSum];
            end



            for fileType=1:2
                if(fileType == 1)
                    fileTypeString = '_blob';
                end
                if(fileType == 2)
                    fileTypeString = '_iter_targ_';
                end
                cd('results');
                files = dir(strcat(file,fileTypeString,'.mat'));
                cd('..');
                if(size(files,1) > 0)
                    load (strcat('.\results\',file,fileTypeString));

                    if(size(iterDatTarg,1) == size(coopList,1))
                        if(size(iterDatTarg,2) == 4 || forceUpdate == 1)
                            iterDatTarg(:,5) = coopList;
                            save (strcat('.\results\',file,fileTypeString),'iterDatTarg','-append');
                            disp(strcat('Augmented Coop Data:',fileTypeString,': for :',file));
                            success = 1;
                        else
                            disp(strcat('File already has coop data in:',fileTypeString,': for :',file));
                        end
                    else
                        [size(iterDatTarg,1) size(coopList,1)]
                        disp(strcat('Did not add coop list to:',fileTypeString,': for :',file));
                    end
                else
                    disp(strcat('Could not find ',fileTypeString,': for :',file));
                end
            end

            %load(str'')

        
        
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   ExtractCoopReplayData - 
        %   
        %   Gets data from the replay directory, which
        %   is a huge pain in general. However, I'm glad we have 
        %   the replay directory, or we wouldnt have back 
        %   raw data at all!
        %   
        % [alpha,gamma,expereince,quality(Q) , iteration,rewd]        
        function [coopSum ] = ExtractCoopReplayData(this,file)
            disp(file);
            coopSum=0;
            %load(strcat('..\CISL_v21\results\replay\',file))
            load(strcat('results\replay\',file));
            time = size(posData,3);

            %set(gcf,'DoubleBuffer','on');
            for ta=1:time
                t=ta;
                numRobots = size(posData,1);
                numTargets = size(targData,1);
                numObstacles = size(obsData,1);

                for i=1:numTargets
                    robotOnTask  = 0;
                    robotOnTask2 = 0;

                    for r=1:numRobots
                        try
                            if(rpropData(r,1,t) == i && robotOnTask  ==0)
                                robotOnTask = r;
                            elseif(rpropData(r,1,t) == i && robotOnTask2  ==0)
                                robotOnTask2 = r;
                                coopSum = coopSum +2; %two cooperative actions this iteration
                                break;
                            end
                        catch err
                            rpropData(r,1,t)
                            i
                            robotOnTask
                            num2str(0)
                            gdsagdasg
                        end
                    end
                end 
            end
        end        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        %   ResultsCopy - 
        %   
        %   Copy processed results to a dub directory
        %   
        function [success] = ResultsCopy(this,file)
            
            %First, check to see if we need to update the file
            cd('results');
            files = dir(strcat(file,'*.mat'));
            cd('..');
            load (strcat('.\results\',file,'_iter_targ_.mat'));
            
            if(size(iterDatTarg,2) == 5 || size(iterDatTarg,1) == 300 )
                if(size(files,1) > 0)
                    for f=1:size(files,1)
                        disp(strcat('moving:.\results\',files(f).name));
                        cd('results');
                        movefile(files(f).name,strcat('.\resultsProcessed\',files(f).name ))
                        cd('..')
                    end
                end
            end
        
        end
         end

end

