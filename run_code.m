% I'm reversing the problem
% We set a rough segmentation as our source and then transform a fitted SSM
% to match it as close as possible. That way, it will give us a transformed
% SSM fit, but for which we know what anatomical area certain indices
% correspond with.

% Pick a target model
template_job_id = '126300';
fprintf('Loading template job: %s\n', template_job_id);

faces_file_path = strcat('C:\Dropbox\Public\Manu\', num2str(template_job_id), '_combined_raw_faces.txt');
verts_file_path = strcat('C:\Dropbox\Public\Manu\', num2str(template_job_id), '_combined_raw_vertices.txt');

[vertices, faces] = load_new_files(verts_file_path, faces_file_path);

template_vertices = vertices;
template_faces = faces;

% visualize(template_faces, template_vertices);
% uiwait();

% Pick a source model and set its job_id
source_job_id = '126316';
fprintf('Loading source job: %s\n', source_job_id);

faces_file_path = strcat('C:\Dropbox\Public\Manu\', num2str(source_job_id), '_ssm_combined_faces.txt');
verts_file_path = strcat('C:\Dropbox\Public\Manu\', num2str(source_job_id), '_ssm_combined_vertices.txt');

[vertices, faces] = load_new_files(verts_file_path, faces_file_path);

source_vertices = vertices;
source_faces = faces;

% visualize(source_faces, source_vertices);
% uiwait();

% Just running rigidICP instead
if false
    % If flag==0 it prealigns
    [~, registered, ~] = rigidICP(template_vertices, source_vertices, 0);  
    %plot of the meshes
    figure();
    h = trisurf(source_faces, source_vertices(:, 1), source_vertices(:, 2), source_vertices(:, 3), 'Facecolor', 'g', 'Edgecolor', 'none');
    hold
    light
    lighting phong;
    set(gca,  'visible',  'off')
    set(gcf, 'Color', [1 1 0.88])
    view(90, 90)
    set(gca, 'DataAspectRatio', [1 1 1], 'PlotBoxAspectRatio', [1 1 1]);
    tttt = trisurf(template_faces, template_vertices(:, 1), template_vertices(:, 2), template_vertices(:, 3), 'Facecolor', 'm', 'Edgecolor', 'none');
    alpha(0.6)
else
    % Run the registration
    [registered] = nonrigidICP2(template_vertices, source_vertices, template_faces, source_faces, 5);
end




write_file(strcat('C:\Dropbox\Public\Manu\', num2str(template_job_id), '_ssm_registered.txt'), registered);