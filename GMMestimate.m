function [ psum ] = GMMestimate( x,gmmCentroids,gmmCovariance,gmmWeights,G )
%GMMESTIMATE Summary of this function goes here
%   Detailed explanation goes here
    psum = 0;
    for cen=1:size(G,1)
        g=G(cen);
        gm = gmmCentroids(g,:);
        cov = gmmCovariance(:,:,g);
        fa = ((2*pi)^(6/2))*(norm(cov)^(1/2));
        fa = 1/fa;
        d = (x-gm)';
        p = fa*exp((-1/2)*(d'*inv(cov)*d));
        psum = psum + p*gmmWeights(g);
    end
end

