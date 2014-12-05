function [prealligned_source, prealligned_target, transform_target ] = prealign(target, source)
% This function performs a first and rough pre-alligment of the data as 
% starting position for the iterative allignment and scaling procedure
% Initial positioning of the data is based on alligning the coordinates of 
% the objects -which are assumed to be close/similar in shape- following 
% principal component analysis

% princomp Principal Components Analysis (PCA) from raw data.
% We apply PCA to both the target and source
[~, prealligned_source] = princomp(source);
[~, prealligned_target] = princomp(target);

% the direction of the axes is than evaluated and corrected if necesarry.
max_target = max(prealligned_source);
max_source = max(prealligned_target);
% We calculate the fraction between the two components
D = max_target./max_source;
% And use those values to create a transformation matrix
D = [D(1, 1) 0 0; 0 D(1, 2) 0; 0 0 D(1, 3)];
% We apply it to our prealigned source
RTY = prealligned_source * D;

% R is an 1x8 structure, where each element contains a 3x3 transformation 
% matrix T. 
% load R  % I removed this line and put R into the code itself
R = {
    [ 1, 0, 0; 0  1 0; 0 0  1]
    [ 1, 0, 0; 0  1 0; 0 0 -1]
    [ 1, 0, 0; 0 -1 0; 0 0 -1]
    [ 1, 0, 0; 0 -1 0; 0 0  1]
    [-1, 0, 0; 0  1 0; 0 0  1]
    [-1, 0, 0; 0  1 0; 0 0 -1]
    [-1, 0, 0; 0 -1 0; 0 0 -1]
    [-1, 0, 0; 0 -1 0; 0 0  1]
};

for i = 1:8
    % Extract the transformation matrix from R
    T = R{i}; %R{1, i};
    % Apply the transformation to our prealigned source
    T = RTY * T;
    % And find the distances to our target using KNN
    [~, DD] = knnsearch(T, prealligned_target);
    % Store the sum of the distances in MM
    MM(i, 1) = sum(DD);
    fprintf('Transformation %d: summed distances: %f\n', i, sum(DD));
end

% Get the index of the minimal value
[~, I] = min(MM);
% And retrieve the transformation that yielded that minimum
T = R{I}; % R{1, I};
% Apply it to the prealigned source
prealligned_source = prealligned_source * T;
% And apply procrustes on the target
% D = procrustes(X, Y) determines a linear transformation (translation, 
% reflection, orthogonal rotation, and scaling) of the points in the
% matrix Y to best conform them to the points in the matrix X
[~, ~, transform_target] = procrustes(target, prealligned_target);