
x = zeros(2,1000);
mean = [0; 0];
M2 = [0;0];
for i=1:5000
    uv = 0;
    %while (sum(uv) > 1 || sum(uv ) == 0)
    %    uv = rand(2,1)-0.5;
    %end
    U = rand(1,1);
    V = rand(1,1);
    z1 = sqrt(-2*log(U))*cos(2*pi*V);
    z2 = sqrt(-2*log(U))*sin(2*pi*V);
    z12 = [z1;z2]*5;
    %z12 = [ normrnd(0,1,[1,1]);normrnd(0,1,[1,1])];
    x(:,i) = z12;
    
    delta = x(:,i) - mean;
    mean = mean + delta./i;
    M2 = M2 + delta.*(x(:,i) - mean);
    variance = M2./(i - 1);   
end
hold on;


mean
std(x,0,2)
sqrt(variance)
