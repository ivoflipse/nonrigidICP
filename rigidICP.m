function [error, realligned_source, transform]  = rigidICP(target, source, flag)

% This function rotates, translates and scales a 3D pointcloud "source" of N*3 size (N points in N rows, 3 collumns for XYZ)
% to fit a similar shaped point cloud "target" again of N by 3 size
% 
% The output shows the minimized value of dissimilarity measure in "error", the transformed source data set and the 
% transformation, rotation, scaling and translation in transform.T, transform.b and transform.c such that
% realligned_source   =  b*source*T + c;
%
% flag determines whether we want to prealign or not
if flag == 0
    [prealligned_source, prealligned_target, transformtarget ]  = prealign(target, source);
else
    prealligned_source = source;
    prealligned_target = target;
end

error_index  = 1;
% errortemp stores the error value returned by ICPmanu_allign2
% We add a new value after each iteration
[errortemp(error_index,:), realligned_source_temp] = ICPmanu_allign2(prealligned_target, prealligned_source);
% This line is just for debugging purposes
d = errortemp(error_index,:);
fprintf('Step: %d \tError: %d\n', error_index, d);

[errortemp(error_index+1,:), realligned_source_temp] = ICPmanu_allign2(prealligned_target, realligned_source_temp);
error_index  = error_index+1;
d = errortemp(error_index,:);
fprintf('Step: %d \tError: %d\n', error_index, d);

% While the error is bigger than some value epsilon, we keep aligning the
% two models
while ((errortemp(error_index-1,:) - errortemp(error_index,:))) > 0.0001 % Increased for 0.0000001
    [errortemp(error_index+1,:), realligned_source_temp] = ICPmanu_allign2(prealligned_target, realligned_source_temp);
    error_index  = error_index+1;
    d = errortemp(error_index,:);
    fprintf('Step: %d \tError: %d\n', error_index, d);
end

% Get the final error value
error = errortemp(error_index,:);

if flag == 0
    realligned_source  = realligned_source_temp * transformtarget.T + repmat(transformtarget.c(1,1:3), length(realligned_source_temp(:,1)),1);
    [~, realligned_source, transform] = procrustes(realligned_source, source);
else
    [~, realligned_source, transform] = procrustes(realligned_source_temp, source);
end
