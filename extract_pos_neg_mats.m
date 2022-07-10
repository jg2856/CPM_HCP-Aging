param_list = {'ravlt','neon'};
scan_type_list = {'rfMRI_REST1_AP', 'rfMRI_REST1_PA', 'rfMRI_REST2_AP', 'rfMRI_REST2_PA','tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'};

% ravlt allsubjs cpm outputs
load(sprintf('../BIG_data_from_CPM_HCP-Aging/%s_allsubjs_cpm_output.mat',char(param_list{1})),'cpm_output_allsubjs') % currently set to get ravlt cpm outputs

cpm_output_file = cpm_output_allsubjs;
p_thresh = 0.01;
k_folds = 5;
param = char(param_list{1});

% pmask_test = [];

for i = 1:1 % loops through all scan_types; currently only goes through first two scan types!
%     pmask_test = cat(3,pmask_test,pmask_get_consensus(cpm_output_file, p_thresh, k_folds, param, i));
    pmask_get_consensus(cpm_output_file, p_thresh, k_folds, param, i);
end