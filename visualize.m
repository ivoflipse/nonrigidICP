function visualize(faces, vertices)

figure();
trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:, 3), 0.3, 'Edgecolor', 'none');
hold
light
lighting phong;
set(gca,  'visible',  'off')
set(gcf, 'Color', [1 1 0.88])
view(90, 90)
set(gca, 'DataAspectRatio', [1 1 1], 'PlotBoxAspectRatio', [1 1 1]);
alpha(0.6);