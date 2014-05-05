function [ dat, num ] = removeOutliers( a,Z,window )

%REMOVEOUTLIERS Summary of this function goes here
%   Detailed explanation goes here
        %Try to remove some outliers before we add stuff to the average
        num = size(a,1);
        if(Z==0)
            dat = a;
            return;
        end
        b = zeros(size(a,1),1);
        for i=1:size(a,1)
            %i1 = i-window/2;
            %i2 = i+window/2;
            i1 = i-window;
            i2 = i;
            
            if(i2>size(a,1))
                i2 = size(a,1);
                %i1 = i2-window;
            end
            
            if(i1<1)
                i1= 1;
                %i2 = i1+window;
            end
            %[i1 i2]
            mu = mean(a(i1:i2)); 
            sd = std(a(i1:i2)); 
            if( abs(a(i)-mu) > Z*sd )         %# outliers
                %a(i) = Z*sd .* sign(a(i));      %# cap values at 3*STD(X)
                b(i) = mu;
                %a(i) = mu;
            else
                b(i) = a(i);
            end
            dat = b;
        end
        dat = b;

end

