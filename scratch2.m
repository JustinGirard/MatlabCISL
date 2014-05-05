clear all;
load('gmmData');
g=1;
GMMestimate([0 0 0 0 0 0],gmmCentroids,gmmCovariance,g)



f = @(x,y,c) gmmWeights(c).*GMMestimate([x y 0 0 1 1],gmmCentroids,gmmCovariance,c)...
         + gmmWeights(c+1).*GMMestimate([x y 0 0 1 1],gmmCentroids,gmmCovariance,c+1)...;
         + gmmWeights(c+2).*GMMestimate([x y 0 0 1 1],gmmCentroids,gmmCovariance,c+2);


%ezcontour(f,[-10,10],100)



    z = zeros(21,21);
    for a=-10:10
        for b=-10:10
            z(a+11,b+11) = f(a,b,11);
        end
    end
    hold
    contour(z);



