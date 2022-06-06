%grouping edges by network. contact corey.horien@yale.edu for questions.

%note that no_nodes, no_networks are hard-coded
%in - changed these based on your needs.

no_nodes = 268;
no_networks = 10;


ten_network_defn_path =  '/mnt/store4/mri_group/corey_data/datasets/';
filename = 'ten_network_defn.mat';
file = fullfile(ten_network_defn_path, filename);
load(file);


%% loading in files you want to group by network size.


% Specify the folder where the files live.
myFolder = '/home/corey/Desktop';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
    uiwait(warndlg(errorMessage));
    return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.txt'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(myFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    thr_1 = dlmread(fullFileName);
    %this is arranging the networks in the original matrix (into ten diff
    %networks), first by rows, then by columns.
    new_assignments_matr_INTERMEDIATE = thr_1(ten_network_defn(:,2),:);
    new_assignments_final_matr_tmp = new_assignments_matr_INTERMEDIATE(:,ten_network_defn(:,2));
    new_assignments_final_matr_cell{k} = new_assignments_final_matr_tmp;
end


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
      
        mat_1{w} = mat_test_raw_edges_lower_tri;
        mat_2{w} = mat_test_edges_by_net_size_lower_tri;
       
        
    
end


%note that these figures are for quick visualization only. they should be
%tinkered  with or a different script should be used for
%publication/presentation purposes.

%mat_1 --> plotting the number of edges in a network without normalizing by
%network size.
figure;
subplot(2,3,1)
imagesc(mat_1{1,1})
colorbar
title('neg mask')

subplot(2,3,2)
imagesc(mat_1{1,2})
colorbar
title('pos mask')

saveas(gcf,'pos_neg_mask_network_representation_raw_edges.png')


%mat_2 --> plotting the number of edges in a network normalizing by
%network size.

figure;
subplot(2,3,1)
imagesc(mat_2{1,1})
colorbar
title('neg mask')

subplot(2,3,2)
imagesc(mat_2{1,2})
colorbar
title('pos mask')

saveas(gcf,'pos_neg_mask_network_representation_raw_edges_normalized.png')


%saving results to current directory.
filename = 'visualizing_CPM_results.mat';
save(filename)


