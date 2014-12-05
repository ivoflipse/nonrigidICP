function [cutoff] = definecutoff(vertices_old, faces_old)

% Are these the values or the indices?
faces_x = faces_old(:,1);
faces_y = faces_old(:,2);
faces_z = faces_old(:,3);

number_of_vertices = size(vertices_old,1);
number_of_faces = size(faces_old,1);

D1 = sqrt(sum((vertices_old(faces_x,:) - vertices_old(faces_y,:)).^2,2));
D2 = sqrt(sum((vertices_old(faces_x,:) - vertices_old(faces_z,:)).^2,2));

average = mean([D1; D2]);
standard_deviation = std([D1; D2]);

cutoff = average + standard_deviation;