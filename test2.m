clear all;

clc;

attempts = 10;
slope = 0.15;

pos = attempts/2;
v = 1:300;
dat = [];
for v=1:300
    x = randn()*100
    v = v - pos;
    beta = (exp(slope*v)...
        ./(1+exp(slope*v)));
    %update out task times, and our averages
    learnRate = 1/(v/10+1);
    
    tau = beta.*(tau + learnRate.*(x - tau) + 0) ;
    
    dat = [dat tau];
end