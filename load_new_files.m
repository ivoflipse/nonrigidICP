function [vertices, faces] = load_new_files(verts_file_path, faces_file_path)

vertices_raw = textread(verts_file_path, '%f');
[w, h] = size(vertices_raw);
vertices = reshape(vertices_raw, 3, w/3)';

faces_raw = textread(faces_file_path, '%d');
[w,h] = size(faces_raw);
% Indexing at zero gives us problems and I was reshaping the wrong way around
faces = reshape(faces_raw, 3, w/3)' + 1;