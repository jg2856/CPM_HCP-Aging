% read in cpm output .mat file


param_list = {'ravlt','neon'};
scan_type_list = {'rfMRI_REST1_AP','rfMRI_REST1_PA','rfMRI_REST2_AP','rfMRI_REST2_PA','tfMRI_CARIT','tfMRI_FACENAME','tfMRI_VISMOTOR'};

% ravlt allsubjs corrs
load(sprintf('../BIG_data_from_CPM_HCP-Aging/%s_allsubjs_cpm_output.mat',char(param_list{1})),'cpm_output_allsubjs')

ravlt_allsubjs_corrs = cpm_output_stats(scan_type_list, cpm_output_allsubjs, 'allsubjs');

% neon allsubjs corrs
load(sprintf('../BIG_data_from_CPM_HCP-Aging/%s_allsubjs_cpm_output.mat',char(param_list{2})),'cpm_output_allsubjs')

neon_allsubjs_corrs = cpm_output_stats(scan_type_list, cpm_output_allsubjs, 'allsubjs');


% ravlt by sex corrs
load(sprintf('../BIG_data_from_CPM_HCP-Aging/%s_by_sex_cpm_output.mat',char(param_list{1})),'cpm_output_by_sex')

ravlt_by_sex_corrs = cpm_output_stats(scan_type_list, cpm_output_by_sex, 'by_sex');

% neon by sex corrs
load(sprintf('../BIG_data_from_CPM_HCP-Aging/%s_by_sex_cpm_output.mat',char(param_list{2})),'cpm_output_by_sex')

neon_by_sex_corrs = cpm_output_stats(scan_type_list, cpm_output_by_sex, 'by_sex');