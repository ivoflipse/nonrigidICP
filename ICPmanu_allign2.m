function [error, realligned_source] = ICPmanu_allign2(target, source)

% I think knnsearch finds the nearest neighbor for each index
[IDX1, ~] = knnsearch(target, source);  
[IDX2, ~] = knnsearch(source, target);

% vertcat = Vertical concatenation
% [A;B] is the vertical concatenation of matrices A and B.
% So we append the value that corresponds to the nearest neighbor to itself
dataset_source = vertcat(source, source(IDX2,:));
% And vice versa
dataset_target = vertcat(target(IDX1(:,1),:), target);
% Basically compare the source with its nearest neighbor of the
% target and the target with its nearest neighbor in the source

% D = procrustes(X, Y) determines a linear transformation (translation, 
% reflection, orthogonal rotation, and scaling) of the points in the
% matrix Y to best conform them to the points in the matrix X
[error, realligned_source] = procrustes(dataset_target, dataset_source, 'reflection', 0);

% What does this line do? 
% It seems to retrieve all the elements of source from realligned_source
% Leaving the concatenated part behind
realligned_source = realligned_source(1:length(source(:,1)),:);