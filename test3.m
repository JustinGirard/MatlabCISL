
%{
clc;


action1 = 5;
action2 = 5;


sa1 = zeros(3,5);
sa2 = zeros(3,5);

for i=1:50000
    state = 1;
    %normrnd(mu,sigma)
    x = floor(i/1000);
    action1 = round(normrnd(-1,2.5) + 3);
    action2 = round(normrnd(x,2.5) + 3) ;
    
    if(action1 < 1)    action1 =1;    end
    if(action1 > 5)    action1 =5;    end
    if(action2 < 1)    action2 =1;    end
    if(action2 > 5)    action2 =5;    end
    
    sa1(state,action1)=sa1(state,action1)+1;
    sa2(state,action2)=sa2(state,action2)+1;
    i = i+1;
end

saaDiff = sa2 - sa1;
saaDiff = abs(saaDiff);
sa2
sa1

saaDiffTotal = sum(sum(saaDiff,1),2);
saaTotal = sum(sum(sa2,1),2) + sum(sum(sa1,1),2);

difference = saaDiffTotal/saaTotal;
difference 


%}
sz = 2;
dist1 = [0.8 0.2 ]';
dist2 = [0.2 0.8 ]';

distM = dist1*(dist2');
ieye = 1 - eye(sz,sz)

res = ieye .* distM;

prob = sum(sum(res,2),1);
prob

%sum(abs(dist1 - dist2),1)/2




