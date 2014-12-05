function [vertices_new, faces_new, control] = remesh(vertices_old, faces_old, cutoff)

fk1 = faces_old(:, 1);
fk2 = faces_old(:, 2);
fk3 = faces_old(:, 3);

number_of_vertices = size(vertices_old, 1);
%number_of_faces = size(fold, 1);

D1 = sqrt(sum((vertices_old(fk1, :)-vertices_old(fk2, :)).^2, 2));
D2 = sqrt(sum((vertices_old(fk1, :)-vertices_old(fk3, :)).^2, 2));
D3 = (1:size(D2, 1))';

D1 = horzcat(D1, D3);
D2 = horzcat(D2, D3);

D1 = D1(D1(:, 1)>cutoff, :);
D2 = D2(D2(:, 1)>cutoff, :);

indices = unique(vertcat(D1(:, 2), D2(:, 2)));
control = size(indices, 1);

m1x = (vertices_old( fk1(indices, 1), 1) + vertices_old( fk2(indices, 1), 1) )/2;
m1y = (vertices_old( fk1(indices, 1), 2) + vertices_old( fk2(indices, 1), 2) )/2;
m1z = (vertices_old( fk1(indices, 1), 3) + vertices_old( fk2(indices, 1), 3) )/2;

m2x = (vertices_old( fk2(indices, 1), 1) + vertices_old( fk3(indices, 1), 1) )/2;
m2y = (vertices_old( fk2(indices, 1), 2) + vertices_old( fk3(indices, 1), 2) )/2;
m2z = (vertices_old( fk2(indices, 1), 3) + vertices_old( fk3(indices, 1), 3) )/2;

m3x = (vertices_old( fk3(indices, 1), 1) + vertices_old( fk1(indices, 1), 1) )/2;
m3y = (vertices_old( fk3(indices, 1), 2) + vertices_old( fk1(indices, 1), 2) )/2;
m3z = (vertices_old( fk3(indices, 1), 3) + vertices_old( fk1(indices, 1), 3) )/2;

vnewtemp = [ [m1x m1y m1z]; [m2x m2y m2z]; [m3x m3y m3z] ];
[vnewtemp_ ii jj] = unique(vnewtemp, 'rows' );

m1 = jj(1:control)+number_of_vertices;
m2 = jj(control+1:2*control)+number_of_vertices;
m3 = jj(2*control+1:3*control)+number_of_vertices;

tri1 = [fk1(indices) m1 m3];
tri2 = [fk2(indices) m2 m1];
tri3 = [ m1 m2 m3];
tri4 = [m2 fk3(indices) m3];
fk1(indices) = [];
fk2(indices) = [];
fk3(indices) = [];

tri5 = [fk1 fk2 fk3];
clear m1 m2 m3 fk1 fk2 fk3
 
vertices_new = [vertices_old; vnewtemp_]; % the new vertices
faces_new = [tri5; tri1; tri2; tri3; tri4]; % the new faces
 






