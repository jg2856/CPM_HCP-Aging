%% Written by Suyeon Ju, 7.10.22, adapted from Corey Horien's scripts

%% general script info

% fxn to get consensus (10-network) mask of significant edges from cpm

% inputs:
%   

% outputs:
%   

%% Implementation
function pmask_visualization(pos_mat,neg_mat)

close all

%% visualization setup
no_nodes = 268;
no_networks = 10;

ten_network_defn_path =  '/Users/sj737/OneDrive-YaleUniversity/Fredericks_Lab_files/CPM_HCP-A/shen_268_labels';
filename = 'ten_network_defn.mat';
file = fullfile(ten_network_defn_path, filename);
load(file);


%% loading in files you want to group by network size. <- just use pos_mat + neg_mat for now!

% Now do whatever you want with this file name,
% such as reading it in as an image array with imread()
mats = cat(3,pos_mat,neg_mat);
% %this is arranging the networks in the original matrix (into ten diff
% %networks), first by rows, then by columns.
% new_assignments_matr_INTERMEDIATE = combined_mat(ten_network_defn(:,2),:);
% new_assignments_final_matr_tmp = new_assignments_matr_INTERMEDIATE(:,ten_network_defn(:,2));
% new_assignments_final_matr_cell{1} = new_assignments_final_matr_tmp;

for k = 1 : size(mats,3)
    
    thr_1 = mats(:,:,k);
    %this is arranging the networks in the original matrix (into ten diff
    %networks), first by rows, then by columns.
    new_assignments_matr_INTERMEDIATE = thr_1(ten_network_defn(:,2),:);
    new_assignments_final_matr_tmp = new_assignments_matr_INTERMEDIATE(:,ten_network_defn(:,2));
    new_assignments_final_matr_cell{k} = new_assignments_final_matr_tmp;
end


% size(new_assignments_matr_INTERMEDIATE)
% size(new_assignments_final_matr_tmp)
% size(new_assignments_final_matr_cell)


%%

%this is finding the number of sig edges across the entire 10x10 network


for w = 1:length(new_assignments_final_matr_cell);
    
    new_assignments_final_matr = new_assignments_final_matr_cell{1,w};
    
       
    for mm = 1:no_networks
        for k = 1:no_networks
            zero_matrix = zeros(no_nodes, no_nodes);
            [indices] = find( ten_network_defn(:, 3)==k); % this will indicate the row to be used in the between network comparison
            indices_network_mm = find(ten_network_defn(:,3) ==mm); %this is indicating the column to be used in the between network comparison

            zero_matrix(indices,indices_network_mm) = 1;
            network_k = zero_matrix;
            number_of_edges = (new_assignments_final_matr + network_k);

            tmp_raw_DP_edges_within_network_mm = length(find(number_of_edges == 2));


            %GETTING RAW NUMBER OF EDGES
            if mm ==k
                raw_DP_edges_within_network_mm(k) = tmp_raw_DP_edges_within_network_mm/(2);   %GETTING RAW NUMBER OF EDGES

            elseif mm ~=k
                raw_DP_edges_within_network_mm(k) = tmp_raw_DP_edges_within_network_mm;
            end


            [indices_size,~] = size(indices); %getting the size of the network so I can use it to normalize below. --> this is what I'll need to change for SLIM and UPSM.
            [indices_network_mm_size,~] = size(indices_network_mm); %getting the size of the network so I can use it to normalize below.

            %GETTING EDGES/NETWORK SIZE

            if mm == k %note that this is for the case when I am dividing by the within network edges.   %GETTING EDGES/NETWORK SIZE
                edges_divided_by_net_size(k) =  (tmp_raw_DP_edges_within_network_mm/(2))/((indices_size*indices_network_mm_size - indices_size)./2); %here I'm just dividing the number of edges in that square by the total network size.

            elseif mm ~= k %note that this is for the case when I am dividing by the between-network edges.
                edges_divided_by_net_size(k) =  tmp_raw_DP_edges_within_network_mm./(indices_size*indices_network_mm_size);
            end

        end

        mat_test_raw_edges(mm,:) = raw_DP_edges_within_network_mm; %RAW NUMBER OF EDGES
        mat_test_edges_by_net_size(mm,:) = edges_divided_by_net_size; %GETTING EDGES/NETWORK SIZE

    end


    mat_test_raw_edges_lower_tri = tril(mat_test_raw_edges,0);
    mat_test_edges_by_net_size_lower_tri =  tril(mat_test_edges_by_net_size,0);

    mat_1{w} = mat_test_raw_edges_lower_tri; % mat_1 is lower triangle of raw edges
    mat_2{w} = mat_test_edges_by_net_size_lower_tri; % mat_2 is lower triangle of edges normalized by network size
    
end


% %% note that these figures are for quick visualization only. they should be
% %tinkered  with or a different script should be used for
% %publication/presentation purposes.
% 
% %mat_1 --> plotting the number of edges in a network without normalizing by
% %network size.
% figure;
% subplot(2,3,1)
% imagesc(mat_1{1,1})
% colorbar
% title('pos mask')
% 
% subplot(2,3,2)
% imagesc(mat_1{1,2})
% colorbar
% title('neg mask')
% 
% % raw_edge_fig_filename = sprintf('/Users/sj737/Library/CloudStorage/OneDrive-YaleUniversity/Fredericks_Lab_files/CPM_HCP-A/CPM_HCP-Aging/figs_and_csvmats/p%.2f_k%d/%s/consensus_mask_figs/pos_neg_mask_network_representation_raw_edges_%s_%s_p%.2f_k%d.png', p_thresh, k_folds, param, scan_type, param, p_thresh, k_folds);
% raw_edge_fig_filename = sprintf('/Users/sj737/Library/CloudStorage/OneDrive-YaleUniversity/Fredericks_Lab_files/CPM_HCP-A/CPM_HCP-Aging/figs_and_csvmats/p%.3f_k%d/%s/consensus_mask_figs/pos_neg_mask_network_representation_raw_edges_%s_%s_p%.3f_k%d.png', p_thresh, k_folds, param, scan_type, param, p_thresh, k_folds);
% % saveas(gcf,raw_edge_fig_filename)
% 
% 
% %mat_2 --> plotting the number of edges in a network normalizing by
% %network size.
% 
% figure;
% subplot(2,3,1)
% imagesc(mat_2{1,1})
% colorbar
% title('pos mask')
% 
% subplot(2,3,2)
% imagesc(mat_2{1,2})
% colorbar
% title('neg mask')
% 
% % norm_edge_fig_filename = sprintf('/Users/sj737/Library/CloudStorage/OneDrive-YaleUniversity/Fredericks_Lab_files/CPM_HCP-A/CPM_HCP-Aging/figs_and_csvmats/p%.2f_k%d/%s/consensus_mask_figs/pos_neg_mask_network_representation_raw_edges_normalized_%s_%s_p%.2f_k%d.png', p_thresh, k_folds, param, scan_type, param, p_thresh, k_folds);
% norm_edge_fig_filename = sprintf('/Users/sj737/Library/CloudStorage/OneDrive-YaleUniversity/Fredericks_Lab_files/CPM_HCP-A/CPM_HCP-Aging/figs_and_csvmats/p%.3f_k%d/%s/consensus_mask_figs/pos_neg_mask_network_representation_raw_edges_normalized_%s_%s_p%.3f_k%d.png', p_thresh, k_folds, param, scan_type, param, p_thresh, k_folds);
% % saveas(gcf,norm_edge_fig_filename)
% 
% %% mat_1_1
% % %saving results to current directory.
% % filename = 'visualizing_CPM_results.mat';
% % save(filename)
% 
% SLIM_DP_edges = mat_2{1,1};
% 
% SLIM_DP_edges(:,end+1) = 0; % pad with zeros for pcolor
% SLIM_DP_edges(end+1,:) = 0;
% 
% %finding the max value of each matrix so I can use it to scale the color
% %bar below.
% 
% tmp_max = max(SLIM_DP_edges);
% max_SLIM = max(tmp_max);
% 
% %I'm putting the max value I obtained from directly above in the zero spaces
% %of the upper triangle in my matrix -- I am doing this because they are
% %currently filled with zeros, which results in that square becoming black
% %in my final figure with the current colormap. 
% 
% filler_upper_triangle_SLIM = ones(10,10)*max_SLIM;
% filler_upper_triangle_SLIM = triu(filler_upper_triangle_SLIM,1);
% 
% filler_upper_triangle_SLIM =[filler_upper_triangle_SLIM zeros(10,1)]; %here I am adding zeros so I can add filler_upper_triangle_SLIM to my matrices below.
% filler_upper_triangle_SLIM = vertcat(filler_upper_triangle_SLIM, zeros(1,11)); 
% 
% %putting them together
% final_SLIM = SLIM_DP_edges + filler_upper_triangle_SLIM;
% 
% % Plot and format figure
% %% corey version color scheme
% figure;
% pcolor(final_SLIM)
% caxis([0 max_SLIM]) %color bar will be scaled from 0 to the max value in the matrix.
% axis('square')
% set(gca,'YDir','reverse','XTick',[],'YTick',[]);
% set(gcf,'color','w');
% colormap hot
% colorbar
% title('SLIM')
% 
% % % pos_mat_vis_fig_filename = sprintf('/Users/sj737/Library/CloudStorage/OneDrive-YaleUniversity/Fredericks_Lab_files/CPM_HCP-A/CPM_HCP-Aging/figs_and_csvmats/p%.2f_k%d/%s/consensus_mask_figs/matrix_visualization_mat_2_1_%s_%s_p%.2f_k%d.jpg', p_thresh, k_folds, param, scan_type, param, p_thresh, k_folds);
% pos_mat_vis_fig_filename = sprintf('/Users/sj737/Library/CloudStorage/OneDrive-YaleUniversity/Fredericks_Lab_files/CPM_HCP-A/CPM_HCP-Aging/figs_and_csvmats/p%.3f_k%d/%s/consensus_mask_figs/matrix_visualization_mat_2_1_%s_%s_p%.3f_k%d.jpg', p_thresh, k_folds, param, scan_type, param, p_thresh, k_folds);
% % saveas(gcf,pos_mat_vis_fig_filename)
% 
% %% mat_1_2
% SLIM_DP_edges = mat_2{1,2};
% 
% SLIM_DP_edges(:,end+1) = 0; % pad with zeros for pcolor
% SLIM_DP_edges(end+1,:) = 0;
% 
% %finding the max value of each matrix so I can use it to scale the color
% %bar below.
% 
% tmp_max = max(SLIM_DP_edges);
% max_SLIM = max(tmp_max);
% 
% %I'm putting the max value I obtained from directly above in the zero spaces
% %of the upper triangle in my matrix -- I am doing this because they are
% %currently filled with zeros, which results in that square becoming black
% %in my final figure with the current colormap. 
% 
% filler_upper_triangle_SLIM = ones(10,10)*max_SLIM;
% filler_upper_triangle_SLIM = triu(filler_upper_triangle_SLIM,1);
% 
% filler_upper_triangle_SLIM =[filler_upper_triangle_SLIM zeros(10,1)]; %here I am adding zeros so I can add filler_upper_triangle_SLIM to my matrices below.
% filler_upper_triangle_SLIM = vertcat(filler_upper_triangle_SLIM, zeros(1,11)); 
% 
% %putting them together
% final_SLIM = SLIM_DP_edges + filler_upper_triangle_SLIM;
% 
% % Plot and format figure
% %% corey version color scheme
% figure;
% pcolor(final_SLIM)
% caxis([0 max_SLIM]) %color bar will be scaled from 0 to the max value in the matrix.
% axis('square')
% set(gca,'YDir','reverse','XTick',[],'YTick',[]);
% set(gcf,'color','w');
% colormap hot
% colorbar
% title('SLIM')
% 
% % % neg_mat_vis_fig_filename = sprintf('/Users/sj737/Library/CloudStorage/OneDrive-YaleUniversity/Fredericks_Lab_files/CPM_HCP-A/CPM_HCP-Aging/figs_and_csvmats/p%.2f_k%d/%s/consensus_mask_figs/matrix_visualization_mat_2_2_%s_%s_p%.2f_k%d.jpg', p_thresh, k_folds, param, scan_type, param, p_thresh, k_folds);
% neg_mat_vis_fig_filename = sprintf('/Users/sj737/Library/CloudStorage/OneDrive-YaleUniversity/Fredericks_Lab_files/CPM_HCP-A/CPM_HCP-Aging/figs_and_csvmats/p%.3f_k%d/%s/consensus_mask_figs/matrix_visualization_mat_2_2_%s_%s_p%.3f_k%d.jpg', p_thresh, k_folds, param, scan_type, param, p_thresh, k_folds);
% % saveas(gcf,neg_mat_vis_fig_filename)
% 
% filename = 'matrix_visualization_for_publication_mat_1_1_su-run.mat';
% % save(filename)

clear all

end