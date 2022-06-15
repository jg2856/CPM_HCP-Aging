

cpm_output_file = 'cpm_output_ravlt_p0.05_k5.mat';
p_thresh = 0.05;
k_folds = 5;
param = 'ravlt';
scan_type_num = 1;

% switch scan_type_num
%     case 1
%         scan_type = 'rfmri_REST1_AP'
%     case 2
%         scan_type = 'rfmri_REST1_PA'
%     case 3
%         scan_type = 'rfmri_REST2_AP'
%     case 4
%         scan_type = 'rfmri_REST2_PA'
%     case 5
%         scan_type = 'tfmri_CARIT'
%     case 6
%         scan_type = 'tfmri_FACENAME'
%     case 7
%         scan_type = 'tfmri_VISMOTOR'
% end

pmask_get_consensus_suyeonpmask_test(cpm_output_file, p_thresh, k_folds, param, scan_type_num)
