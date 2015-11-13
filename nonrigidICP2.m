function [registered, target_vertices, target_faces] = nonrigidICP2(target_vertices, source_vertices, target_faces, source_faces, iterations)

% INPUT
% -target: vertices of target mesh; n * 3 array of xyz coordinates
% -source: vertices of source mesh; n * 3 array of xyz coordinates
% -Ft: faces of target mesh; n * 3 array
% -Fs: faces of source mesh; n * 3 array
% -iterations: number of iterations; usually between 20 en 100
% source and target should be close to equal size in vertices
%
% OUTPUT
% -registered: registered source vertices on target mesh. Faces are not affected and remain the same is before the registration (Fs). 
%
%EXAMPLE
% load EXAMPLE
% [registered] = nonrigidICP2(targetV, sourceV, targetF, sourceF, 25)

clf
%initial allignment and scaling
% mean_target_vertices = mean(target_vertices);
% Substract the mean from the target vertices
% target_vertices = target_vertices - repmat(mean_target_vertices, size(target_vertices, 1), 1);
% We apply Rigid ICP,  to we try to make them as close to each other without
% deforming it
try
    [~, source_vertices, ~] = rigidICP(target_vertices, source_vertices, 0);
catch err
    fprintf('Something bad happened! The first iteration of rigidICP failed, too bad!'); 
    registered = source_vertices;
    return;
end

%plot of the meshes
h = trisurf(source_faces, source_vertices(:, 1), source_vertices(:, 2), source_vertices(:, 3), 0.3, 'Edgecolor', 'none');
hold
light
lighting phong;
set(gca,  'visible',  'off')
set(gcf, 'Color', [1 1 0.88])
view(90, 90)
set(gca, 'DataAspectRatio', [1 1 1], 'PlotBoxAspectRatio', [1 1 1]);
% trisurf(TRI,X,Y,Z,C) displays the triangles defined in the M-by-3 
% face matrix TRI as a surface
tttt = trisurf(target_faces, target_vertices(:, 1), target_vertices(:, 2), target_vertices(:, 3), 'Facecolor', 'm', 'Edgecolor', 'none');
alpha(0.6)

[source_vertices_size] = size(source_vertices, 1);  % Why the [] here, but not below?
% General deformation
% This kernel makes gamma go up or down, because it is applied as a power
% to the mean of D
kernel1 = 2:-(1/iterations):1;
% This kernel is used to pick the number of seed points, which we increase
% in each iteration from 10^1.4 to 10^2
kernel2 = 1.4:(0.6/iterations):2;

fprintf('Step one\n');
for i  = 1:iterations
    fprintf('Iteration: %d of %d\n', i, iterations);
    % We pick a bunch of seed points from 25 up to 100
    number_of_seed_points = round(10^(kernel2(1,  i)));

    % define mutual closest points by running KNN search on the target and
    % the source and vice versa
    [IDXS,  ~] = knnsearch(target_vertices,  source_vertices);
    [IDXT,  ~] = knnsearch(source_vertices,  target_vertices);

    % R = rand(N) returns an N-by-N matrix containing pseudorandom values drawn
    % from the standard uniform distribution on the open interval(0,1)
    % So basically we pick some random indices from the source_vertices
    seed_point_indices = unique(round((source_vertices_size-1) * rand(number_of_seed_points,  1))+1);

    % We pick our seed points from our source vertices
    temp = source_vertices(seed_point_indices,  :);
    [seed_point_size] = size(seed_point_indices,  1);
    % pdist2 = Pairwise distance between two sets of observations.
    % So we calculate the pairwise distance between our source vertices and
    % the random subset from source vertices. No idea why though
    D = pdist2(source_vertices,  temp);
    % We calculate gamma based on the average distance and the kernel we
    % picked
    gamma = 1/(2 * (mean(mean(D)))^kernel1(1,  i));
    % We vertically concatenate the source vertices and the points that are 
    % the nearest neighbors
    dataset_source = vertcat(source_vertices,  source_vertices(IDXT,  :));
    % We do the same for our target vertices
    dataset_target = vertcat(target_vertices(IDXS,  :),  target_vertices);
    % We also concatenate the distances
    dataset_source2 = vertcat(D,  D(IDXT, :));
    % We subtract the concatenated source vertices from our target
    distance_between_vertices = dataset_target-dataset_source;
    % We store the size of the vectors
    [distance_size] = size(distance_between_vertices, 1);

    % define radial basis width for deformation points
    % I have no clue what this part is supposed to do
    % But it takes gamma, which is a weight based on the pairwise distances
    % and a concatenation of the distances
    tempy1 = exp(-gamma * (dataset_source2.^2));
    % We create a large matrix based on the number of distances and seed
    % points and fill that with tempy1, but in a strided fashion
    tempy2 = zeros(3 * distance_size, 3 * seed_point_size);
    tempy2(1:distance_size, 1:seed_point_size) = tempy1;
    tempy2(distance_size+1:2 * distance_size, seed_point_size+1:2 * seed_point_size) = tempy1;
    tempy2(2 * distance_size+1:3 * distance_size, 2 * seed_point_size+1:3 * seed_point_size) = tempy1;

    % solve optimal deformation directions
    % pinv = Pseudoinverse
    ppi = pinv(tempy2);
    % We multiply that with our distances (which is reshaped to a :, 3
    % matrix)
    modes = ppi * reshape(distance_between_vertices, 3 * distance_size, 1);    
    % We multiply tempy2 with our modes
    test = tempy2 * modes;
    % And reshape it to the shape of the original data
    test = reshape(test, size(test, 1)/3, 3);
    % deform source mesh by adding the required deformations from test
    source_vertices = source_vertices + test(1:size(source_vertices, 1), 1:3);
    % Next we apply rigidICP, which returns us a new version of
    % source_vertices
    try
        [~, source_vertices, ~] = rigidICP(target_vertices, source_vertices, 1);
    catch
        fprintf('An error occured in rigidICP, so we exit the for-loop\n');
        break;
    end
    delete(h)
    % We visualize the result
    h = trisurf(source_faces, source_vertices(:, 1), source_vertices(:, 2), source_vertices(:, 3), 'FaceColor', 'y', 'Edgecolor', 'none');
    alpha(0.6)
    pause (0.1)
end



% local deformation
source_vertices_size = size(source_vertices, 1);
% This stores the results of procrustes
arraymap = repmat(cell(1), source_vertices_size, 1);
% In the loop for each iteration we subtract that from kk to get k
% So basically we go from kk down to kk-iterations, which is 12 as the last
% value
kk = 12+iterations;
% control is returned by remesh as the size of the indices above the cutoff
% it will keep remeshing until no more points are above the cutoff
control = 1;
% I don't know what cut off is doing exactly, but its using the vertices to
% calculate the distance between x and y and x and z and uses that to
% caclulate the average + std as the cutoff value
[cutoff] = definecutoff(source_vertices,  source_faces);

while control > 0
    % I have no idea what this code is really doing
    [target_vertices, target_faces, control] = remesh( target_vertices,  target_faces, cutoff);
end

delete(tttt)
% Visualize the result
tttt = trisurf(target_faces, target_vertices(:, 1), target_vertices(:, 2), target_vertices(:, 3), 'Facecolor', 'm', 'Edgecolor', 'none');

% % Quit early
% registered = source_vertices;
% return;

fprintf('Step two\n');
%define local mesh relation
for ddd = 1:iterations
    fprintf('Iteration: %d of %d\n', ddd, iterations);
    k = kk-ddd;  % In the final iteration k = 12
    [IDXsource, Dsource] = knnsearch(source_vertices, source_vertices, 'K', k);
    [IDXtarget, Dtarget] = knnsearch(target_vertices, source_vertices);
    sumD = sum(Dsource, 2);
    sumD2 = repmat(sumD, 1, k);
    sumD3 = sumD2-Dsource;
    sumD2 = sumD2 * (k-1);
    weights = sumD3./sumD2;
    
    % Does this mean we go over each vertex or each dimension?
    for i = 1:size(source_vertices, 1)
        % We pick the nearest neighbors from both sets as input for
        % procrustes and make sure we pick the same points for our source 
        % and target
        sourceset = source_vertices(IDXsource(i, :)', :);
        targetset = target_vertices(IDXtarget(IDXsource(i, :)', :), :);
        % D = procrustes(X, Y) determines a linear transformation (translation, 
        % reflection, orthogonal rotation, and scaling) of the points in the
        % matrix Y to best conform them to the points in the matrix X
        [~, ~, arraymap{i, 1}] = procrustes(targetset, sourceset, 'scaling', 0, 'reflection', 0);
    end
    
    for i = 1:size(source_vertices, 1)
        for ggg = 1:k
            source_vertices_temp(ggg, :) = weights(i, ggg) * (arraymap{IDXsource(i, ggg), 1}.b * source_vertices(i, :) * arraymap{IDXsource(i, ggg), 1}.T+arraymap{IDXsource(i, ggg), 1}.c(1, :));
        end
        source_vertices(i, :) = sum(source_vertices_temp);
    end
    try
        [~, source_vertices, ~] = rigidICP(target_vertices, source_vertices, 1);
    catch 
        fprintf('An error occured in rigidICP, so we exit the for-loop\n');
        break;
    end
    delete(h)
    % Visualise the result
    h = trisurf(source_faces, source_vertices(:, 1), source_vertices(:, 2), source_vertices(:, 3), 'FaceColor', 'y', 'Edgecolor', 'none');   
    pause (0.1)
end

% Set the return value
registered = source_vertices;
return;
