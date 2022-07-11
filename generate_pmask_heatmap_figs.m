%% Written by Suyeon Ju, 7.10.22, adapted from Corey Horien's scripts

%% general script info

% fxn to visualize pmasks of significant edges from cpm

% inputs: none

% outputs:
%   saves 10-network consensus heatmaps of positive and negative matrices for each scan type
%   of each parameter in `param_list` (for later use in BIS Connviewer)

%% Implementation

param_list = {'ravlt','neon'};
scan_type_list = {'rfMRI_REST1_AP', 'rfMRI_REST1_PA', 'rfMRI_REST2_AP', 'rfMRI_REST2_PA','tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'};

for n = 1:2
    % ravlt allsubjs cpm outputs
    load(sprintf('../BIG_data_from_CPM_HCP-Aging/%s_allsubjs_cpm_output.mat',char(param_list{n})),'cpm_output_allsubjs') % currently set to get ravlt cpm outputs

    cpm_output = cpm_output_allsubjs;
    p_thresh = 0.01;
    k_folds = 5;
    param = char(param_list{n});

    for i = 1:7 % loops through all scan_types; currently only goes through first two scan types!
        scan_type_num = i;
        
        switch scan_type_num
            case 1
                scan_type = 'rfMRI_REST1_AP';
            case 2
                scan_type = 'rfMRI_REST1_PA';
            case 3
                scan_type = 'rfMRI_REST2_AP';
            case 4
                scan_type = 'rfMRI_REST2_PA';
            case 5
                scan_type = 'tfMRI_CARIT';
            case 6
                scan_type = 'tfMRI_FACENAME';
            case 7
                scan_type = 'tfMRI_VISMOTOR';
        end

        %% set trial count and threshold values for sig edges
        trial_count = 100;
        thresholder = 0;

        %% get positive and negative pmasks and their sizes
        [pos_mat,neg_mat,pos_mat_size,neg_mat_size] = get_consensus_mask(cpm_output.pmask_struct.(scan_type),k_folds,trial_count,thresholder);

        pmask_visualization(pos_mat,neg_mat, param, scan_type)
    end

end