%% Written by Suyeon Ju, 7.8.22

%% general script info

% inputs:
%   `param_list` = cell array of parameters to be tested
%       i.e., "{'ravlt','pcps','nffi'}"
%   `scan_type_list` = cell array containing one or more of the following: 
%       'rfMRI_REST1_AP', 'rfMRI_REST1_PA', 'rfMRI_REST2_AP', 'rfMRI_REST2_PA',
%       'tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'
%       i.e., "{'rfMRI_REST1_AP', 'tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'}"

% example command line:
% >> run_cpm({'ravlt','neon'},{'rfMRI_REST1_AP', 'rfMRI_REST1_PA', 'rfMRI_REST2_AP', 'rfMRI_REST2_PA','tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'})

% outputs:
%   saves a .mat file for each param in param_list with struct holding all cpm outputs ('cpm_output_allsubjs')

%% Implementation

function run_cpm(param_list, scan_type_list)
tic;

CPM_HCP_Aging_path = '/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/CPM_HCP-Aging/';

for param = 1:length(param_list)
    load(sprintf('%s_allsubjs_pt_conn_mat.mat',char(param_list{param})),'pt_struct_allsubjs', 'conn_mat_struct_allsubjs')
    
    cd(CPM_HCP_Aging_path)
    
    param_data = [pt_struct_allsubjs.y];
    
    %% CPM_OUTPUT STRUCT SETUP
    
    cpm_output_allsubjs = struct();
    
    for st = 1:length(scan_type_list)
        %% run cpm here!! 
        y_hat_output_100 = zeros(length(param_data),100);
        corr_output_100 = zeros(2, 100);
        randinds_output_100 = zeros(length(param_data),100);
        pmask_output_100 = zeros(35778,5,100);
        
        for i = 1:100
            [y_hat_output,corr_output,randinds_output,pmask_output] = cpm_main(conn_mat_struct_allsubjs.(char(scan_type_list(st))),param_data,'pthresh',0.01,'kfolds',5);
            y_hat_output_100(:,i) = y_hat_output;
            corr_output_100(1,i) =  corr_output(1);
            corr_output_100(2,i) =  corr_output(2);
            randinds_output_100(:,i) = randinds_output';
            pmask_output_100(:,:,i) = pmask_output;
        end
        
        cpm_output_allsubjs.(char('y_hat_struct')).(char(scan_type_list(st))) = y_hat_output_100;
        cpm_output_allsubjs.(char('corr_struct')).(char(scan_type_list(st))) = corr_output_100;
        cpm_output_allsubjs.(char('randinds_struct')).(char(scan_type_list(st))) = randinds_output_100;
        cpm_output_allsubjs.(char('pmask_struct')).(char(scan_type_list(st))) = pmask_output_100;
    end
    
    %% COLLECT CPM OUTPUTS!
    if strcmp(param_list{param},'ravlt')
        save('ravlt_allsubjs_cpm_output.mat', 'cpm_output_allsubjs')
        disp('RAVLT results saved!')
    end
    if strcmp(param_list{param},'neon')
        save('neon_allsubjs_cpm_output.mat', 'cpm_output_allsubjs')
        disp('NEO-N results saved!')
    end
end

toc;

cd(CPM_HCP_Aging_path)
end
