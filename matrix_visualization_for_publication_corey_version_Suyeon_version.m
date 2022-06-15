% Copyright 2015 Monica Rosenberg and Emily Finn 

% This code is released under the terms of the GNU GPL v2. This code
% is not FDA approved for clinical use; it is provided
% freely for research purposes. If using this in a publication
% please reference this properly as: 

% Rosenberg MD, Finn ES, Scheinost D, Papademetris X, Shen X, 
% Constable RT, & Chun MM. (2016). A neuromarker of sustained 
% attention from whole-brain functional connectivity. Nature 
% Neuroscience 19, 165-171.

% The code can be used to visualize the differences in the number 
% of edges between each pair of macroscale regions, calculated by 
% subtracting the number of edges in a negative network (e.g., the 
% low-attention network) from the number in a positive network 
% (e.g., the high-attention network).


%adapted by Corey Horien in June 2017.

%load in 10x10 matrix that you want to visualize. Note that the 10x10
%matrix in this example is called "SLIM_DP_edges"

SLIM_DP_edges(:,end+1) = 0; % pad with zeros for pcolor
SLIM_DP_edges(end+1,:) = 0;

%finding the max value of each matrix so I can use it to scale the color
%bar below.

tmp_max = max(SLIM_DP_edges);
max_SLIM = max(tmp_max);

%I'm putting the max value I obtained from directly above in the zero spaces
%of the upper triangle in my matrix -- I am doing this because they are
%currently filled with zeros, which results in that square becoming black
%in my final figure with the current colormap. 

filler_upper_triangle_SLIM = ones(10,10)*max_SLIM;
filler_upper_triangle_SLIM = triu(filler_upper_triangle_SLIM,1);

filler_upper_triangle_SLIM =[filler_upper_triangle_SLIM zeros(10,1)]; %here I am adding zeros so I can add filler_upper_triangle_SLIM to my matrices below.
filler_upper_triangle_SLIM = vertcat(filler_upper_triangle_SLIM, zeros(1,11)); 

%putting them together
final_SLIM = SLIM_DP_edges + filler_upper_triangle_SLIM;

% Plot and format figure
figure;
pcolor(final_SLIM)
caxis([0 max_SLIM]) %color bar will be scaled from 0 to the max value in the matrix.
axis('square')
set(gca,'YDir','reverse','XTick',[],'YTick',[]);
set(gcf,'color','w');
colormap hot
colorbar
title('SLIM')
saveas(gcf,'matrix_visualization_CPM.jpg')

filename = 'matrix_visualization_for_publication_su-run.mat';
save(filename)






