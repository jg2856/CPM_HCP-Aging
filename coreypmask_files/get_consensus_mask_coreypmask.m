function [MxM_matrix_pos,MxM_matrix_neg,size_of_pos_mask,size_of_neg_mask] = get_consensus_mask_coreypmask(pmask_stock,scan_to_use,thresholder_to_use)
% function get_consensus_mask_Suyeon_version(pmask_stock,scan_to_use,thresholder_to_use)
%fxn to get consensus mask

% size(pmask_stock)

for mm = 1:size(pmask_stock,4)
    disp(mm)

    tester = pmask_stock(:,:,:,mm);
    disp('tester')
    size(tester)

    tmp(mm,:,:) = squeeze(tester(1,:,:)); %note, pulling out 1 here means I am using the 0.05 threshold 
    disp('tmp')
    size(tmp)
end

thresholder = thresholder_to_use;

%lazy coding on my part, leaving remnants of for-loop in from before
k = scan_to_use;
    
    
pmask_tmp = tmp(k,:,:);
size(pmask_tmp)
pmask = squeeze(pmask_tmp);
disp('pmask')
size(pmask)

pmask_pos = pmask;
pmask_pos(pmask_pos==-1) = 0;

pmask_neg = pmask;
pmask_neg(pmask_neg==1) = 0;


%checking that there are no values in the mats that shouldn't be there
% find(pmask_pos ==-1);
% find(pmask_neg ==1);

%now am able to sum

sum_pos = sum(pmask_pos,2);
sum_neg = sum(pmask_neg,2);
disp('sum_pos')
size(sum_pos)

sum_pos(sum_pos < ( size(pmask,2)* thresholder)) = 0;
sum_neg(sum_neg > ( size(pmask,2)* thresholder)) = 0;

% sum_pos_tmp(:,k) = +(sum_pos ~= 0);
% sum_neg_tmp(:,k) = +(sum_neg ~= 0);

sum_pos = +(sum_pos ~= 0);
sum_neg = +(sum_neg ~= 0);
disp('sum_pos')
size(sum_pos)


%these are the sizes of edges that show up in every cross iteration loop
size_of_pos_mask = length(find(sum_pos));
size_of_neg_mask = length(find(sum_neg));
disp('size_of_pos_mask')
size(size_of_pos_mask)


%haven't touched this yet
no_node = 268;
aa = ones(no_node, no_node);
aa_upp = triu(aa, 1);
upp_id = find(aa_upp);
upp_len = length(upp_id);

%back in matrix format
edge_vector_matrix_pos = zeros(no_node, no_node);
edge_vector_matrix_neg = zeros(no_node, no_node);


%now need to put idx_pos into 35,778 vector

edge_vector_matrix_pos(upp_id) = sum_pos;
edge_vector_matrix_pos = edge_vector_matrix_pos + edge_vector_matrix_pos';
disp('edge_vector_matrix_pos')
size(edge_vector_matrix_pos)
MxM_matrix_pos =edge_vector_matrix_pos;
disp('MxM_matrix_pos')
size(MxM_matrix_pos)

edge_vector_matrix_neg(upp_id) = sum_neg;
edge_vector_matrix_neg = edge_vector_matrix_neg + edge_vector_matrix_neg';
MxM_matrix_neg =edge_vector_matrix_neg;
clear sum_pos sum_neg

end

