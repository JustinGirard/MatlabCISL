


compare = 0;

if compare == 0

    load('PF35v15Full6');
    %load('PF20Full4_noMean');
    
    surf(results(:,:,1)./2);
    

    
    %testPfStd = testPfStd.*100;
    %remove = [];
    %for i=1:size(testPfStd,2)
    %    if(mod(i,2) == 0)
    %        remove = [remove i];
    %    end
    %end
    %testPfStd(remove) = [];
    indexes = [];

    %for i=1:size(testPfStd,2)    
    %    if(mod(i,6) == 0)
    %        indexes = [indexes i];
    %    elseif(i == size(testPfStd,2))
    %        indexes = [indexes i];
    %    end
    %end

    ylabel('Noise STD (cm)');
    xlabel('Particle STD (cm)');
    set(gca,'XTick',[1:size(testPfStd,2)]);
    set(gca,'XTickLabels',testPfStd);

    set(gca,'YTick',[1:size(testNoise,2)]);
    set(gca,'YTickLabels',testNoise);
    %testNoise(choice)
    %testPfStdLabel = num2Str(testPfStd);
    
    data = sum(sum(results,1),2);
    data

else
%load('PF20Test12_noMean')

load('PF20Full4_noMean')


%resultsHigher = results; 
%testPfStdHigher = testPfStd; 
%load('PF20Test12_noMean')
%sz = size(testPfStdHigher,2);

%results = [results resultsHigher(:,2:sz,:)];

%testPfStd = [testPfStd testPfStdHigher(2:sz) ];

%limit = results(4,1);

%bottomLimit = results(2,1);

    mini = min(min(min(results)));
%{
    for k=1:size(results,3)    
        for i=1:size(results,1)    
            for j=1:size(results,2)
                if(results(i,j,k) > results(2,1,k))
                    results(i,j,k) = results(2,1,k) ;
                end

            end
        end
    end
  %}  
    hold on;

    h1 = surf(results(:,:,1));
    h2 = surf(results(:,:,2));
    h3 = surf(results(:,:,3));
    h4 = surf(results(:,:,4));
    set(h1,'facealpha',0);
    set(h2,'facealpha',0.5);
    set(h3,'facealpha',0);
    set(h4,'facealpha',1);


    hold off;
    ylabel('Noise STD (cm)');

    legend(num2str(testPfType(1)),num2str(testPfType(2)),num2str(testPfType(3)),num2str(testPfType(4)));

    %testPfStd = testPfStd.*100;
    %remove = [];
    %for i=1:size(testPfStd,2)
    %    if(mod(i,2) == 0)
    %        remove = [remove i];
    %    end
    %end
    %testPfStd(remove) = [];
    indexes = [];

    %for i=1:size(testPfStd,2)    
    %    if(mod(i,6) == 0)
    %        indexes = [indexes i];
    %    elseif(i == size(testPfStd,2))
    %        indexes = [indexes i];
    %    end
    %end

    xlabel('Particle STD (cm)');
    %set(gca,'XTick',testPfStd);
    set(gca,'XTickLabels',testPfStd);
    set(gca,'YTickLabels',testNoise);
    %testPfStdLabel = num2Str(testPfStd);
    sum(sum(results,1),2)
end


