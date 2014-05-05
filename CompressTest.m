%test driver
clc;
clear all;
fail = 0;
sizeCol = 100;


dict = -10*ones(2,sizeCol) +rand(2,sizeCol)*20;
dictb = [zeros(1,sizeCol) ];
dict = [dict; dictb];
dict = [dict ;dict ;dict ;dict ]; %12 columns . . .

disp('calibrating . . ')
workingDict = compress([],[],dict,4);

vecCompressAll = [];
vecCompressTestAll = [];
disp('running . . ')

for a1=-10:10
    for a2=-10:10
        for aorient = 1:36
for b1=-10:10
    for b2=-10:10
        for borient = 1:36
%for c1=-10:10
%    for c2=-10:10
%        for corient = 1:36
%for d1=-10:10
%    for d2=-10:10
%        for dorient = 1:36
            [a1 a2 aorient b1 b2 borient]
            vector = [a1 a2 aorient*(pi*10/180)];
            vector = [vector b1 b2 borient*(pi*10/180)];
            %vector = [vector; c1 c2 corient*(pi*10/180)];
            %vector = [vector; d1 d2 dorient*(pi*10/180)];
            vector = [vector a1 a2 aorient*(pi*10/180)];
            vector = [vector b1 b2 borient*(pi*10/180)];
            
            vecCompress = compress(vector',workingDict,dict,4 );
            vecCompressAll = [vecCompressAll; vecCompress];
            vecCompressTestAll = [vecCompressTestAll; vecCompress];
            
            for testIndex=1:size(vecCompress,1)
                %PUT MORE FAILURE CONDITIONS HERE, like a high amount of
                %key collisions and other data analysis which can happend
                %during execution
                if(vecCompress(testIndex) < 0)
                    fail =1;
                elseif(vecCompress(testIndex) > 32)
                    fail = 1;
                end

            end
           if(fail==1)
               disp('fail Vector Input (size 12)');
               vector'
               disp('fail Compressed Output (should be in size 4)');
               vecCompress
               disp('type "vecCompressAll" to see all compressed data. . .');
               error('Invalid value error')
           end            
            
%        end
%    end
%end
%        end
%    end
%end
        end
    end
end
        end
    end
end

if(fail == 0)
    %PUT MORE FAILURE CONDITIONS HERE, like a high amount of
    %key collisions and other data analysis which can happend
    %during execution
    
    disp('success')
end

%this is how someone might go black box check an algorthim for
%functionality. I would sit down, and think on how one might VERIFY an
%algorithim, a compression algorithim, and alter this driver (or better
%yet, code up your own).  just "running" the code doesn't verify it, the
%first and most significant test is to show that the algorithim perserves
%information (1) and operates within parameters (2).

%slamming the algorithimgs together, when this simulation is over 10 000
%lines of code, is not really a good or apporpriate way to test or verify
%code. Its very invalid and doesn't really "prove" anything at all. Once
%the algorithim WORKS I can install the algorithim, and run some tests over the
%weekend :). The first step is verifying the algorithim works as
%anticipated, and currently it doesn't pass basic input output reqs :(