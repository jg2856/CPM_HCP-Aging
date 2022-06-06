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

pos_edges = rand(10,10); % N x N symmetrical matrix where N = # of macroscale regions (e.g., lobes or canonical networks). Value in cell (i,j) indicates how many edges in the positive network connect regions i and j.
neg_edges = rand(10,10); % Value in cell (i,j) indicates how many edges in the negative network connect regions i and j.

% Calculate difference matrix
diff_edges = tril(pos_edges-neg_edges);
max_value  = max(abs(diff_edges(:))); % get biggest difference for scaling
diff_edges(:,end+1) = 0; % pad with zeros for pcolor
diff_edges(end+1,:) = 0;

% Plot and format figure
pcolor(diff_edges)
caxis([-1*max_value max_value])
axis('square')
set(gca,'YDir','reverse','XTick',[],'YTick',[]);
set(gcf,'color','w');

C = [0 0 1; 1 1 1; 1 0 0];
colormap(interp1(linspace(0,1,length(C)),C,linspace(0,1,250)))
colorbar 
