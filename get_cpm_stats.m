% read in cpm output .mat file


param_list = {'ravlt','neon'};
scan_type_list = {'rfMRI_REST1_AP','rfMRI_REST1_PA','rfMRI_REST2_AP','rfMRI_REST2_PA','tfMRI_CARIT','tfMRI_FACENAME','tfMRI_VISMOTOR'};

% ravlt corrs
load(sprintf('../BIG_data_from_CPM_HCP-Aging/%s_allsubjs.mat',char(param_list{1})),'cpm_output_allsubjs')

ravlt_corrs = cpm_output_stats(scan_type_list, cpm_output_allsubjs);