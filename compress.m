% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Purpose: Compess observation (dataIn) assuming a sparse representation exist. 
% Input Argument:
%  - dataIn: data vector to be compreseed.
%  - compressedDict: if empty, conversion dictionary is generated, if 
% non-empty, it is assumed as the conversion dictionary.
%  - dict: dictionary of observation space
% 
% Output Argument: 
%  - compressedData: data compressed to three dimensions.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

function compressedData = compress(dataIn, compressedDict, dict, m)
    % you change the uc to any number > 1. 
    % The idea is that uc will increase the dimension of space
    uc = 10;    
% % % %     m = 3;    %maximum number of non-zero data
    % n is the number of input data
    % d is the dimension of input data
    [d n]= size(dict);
    % comopressing dictionary of possible observations
    if(isempty(compressedDict))
        Phi = randn(d, uc * d);    
        nonzero_indices = ones(2 * d, 1);
        %%%%% increase gamma until the list of outputs have 3 or less numbers.
        lambda = 1e-10;
        compressedDict = [];
        while(size(nonzero_indices, 1) > m)
            [X, nonzero_indices, dummy2, dummy3] = MFOCUSS(Phi, dict, lambda);
            compressedDict = X(nonzero_indices, :);    
            lambda = 1.2 * lambda;
        end
        convRate = max(abs(compressedDict(:)));
        compressedData = int8(16 / convRate * compressedDict + 16);
        return
    end
    
    % loading dictionary
    diff = dict - repmat(dataIn, 1, size(dict, 2));
    dist = sqrt(sum(diff.^2));
    compressedData = compressedDict(:, find(dist == min(dist)));
    if(size(compressedData, 2) > 1)
        compressedData = compressedData(:, 1);
    end

    
end