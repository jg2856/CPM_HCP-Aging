%% Written by Suyeon Ju, 7.10.22, adapted from Corey Horien's scripts

%% general script info

% fxn to get positive and negative pmasks of significant edges from cpm

% inputs:
%   `param_list` = cell array of parameters to be tested
%       i.e., "{'ravlt','neon'}"

% outputs:
%   `MxM_matrix_pos`
%   `MxM_matrix_neg`
%   `size_of_pos_mask`
%   `size_of_neg_mask`

%% Implementation
function [MxM_matrix_pos,MxM_matrix_neg,size_of_pos_mask,size_of_neg_mask] = get_consensus_mask(pmask_stock,k_folds,trial_count,thresholder_to_use)

%% condense pmask_stock (across all folds and all trials)
% average pmask values across all folds (add up pmask values, then divide by k_folds number)
pmask_fold = (sum(pmask_stock, 2))/k_folds;

% add up pmask values across all trials
pmask_trial = sum(squeeze(pmask_fold),2);

% change all positive sig edge values to 1 and all negative sig edge values to -1
pmask = pmask_trial;
pmask(pmask > 0) = 1;
pmask(pmask < 0) = -1;

% extract positive and negative elements from pmask
pmask_pos = pmask;
pmask_pos(pmask_pos==-1) = 0;

pmask_neg = pmask;
pmask_neg(pmask_neg==1) = 0;

%% check checking that there are no values in the mats that shouldn't be there
find(pmask_pos ==-1);
find(pmask_neg ==1);

%% use thresholder on pmasks and calculate number of selected edges in pos/neg mats
thresholder = thresholder_to_use;

%now am able to sum ***still need to figure out this math myself...***
sum_pos = sum(pmask_pos,2);
sum_neg = sum(pmask_neg,2);

sum_pos(sum_pos < ( size(pmask,2)* thresholder)) = 0;
sum_neg(sum_neg > ( size(pmask,2)* thresholder)) = 0;

% sum_pos_tmp(:,k) = +(sum_pos ~= 0);
% sum_neg_tmp(:,k) = +(sum_neg ~= 0);

sum_pos = +(sum_pos ~= 0);
sum_neg = +(sum_neg ~= 0);

%these are the sizes of edges that show up in every cross iteration loop
size_of_pos_mask = length(find(sum_pos));
size_of_neg_mask = length(find(sum_neg));


%% triangularization of pos_mat/neg_mat vectors
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
MxM_matrix_pos = edge_vector_matrix_pos;

edge_vector_matrix_neg(upp_id) = sum_neg;
edge_vector_matrix_neg = edge_vector_matrix_neg + edge_vector_matrix_neg';
MxM_matrix_neg = edge_vector_matrix_neg;
clear sum_pos sum_neg

end

