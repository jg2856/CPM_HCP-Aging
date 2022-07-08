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
% >> run_cpm_sort_sex({'ravlt','neon'},{'rfMRI_REST1_AP', 'rfMRI_REST1_PA', 'rfMRI_REST2_AP', 'rfMRI_REST2_PA','tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'})

% Outputs:

%% Implementation

function run_cpm_sort_sex(param_list, scan_type_list)
tic;

CPM_HCP_Aging_path = '/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/CPM_HCP-Aging/';

for param = 1:length(param_list)
    load(sprintf('%s_by_sex_pt_conn_mat.mat',char(param_list{param})),'pt_struct_by_sex', 'conn_mat_struct_by_sex')
    
    cd(CPM_HCP_Aging_path)
    
    pt_table = pt_struct_by_sex.pt_all;
    pt_table_F = pt_struct_by_sex.pt_F;
    pt_table_M = pt_struct_by_sex.pt_M;
    
    %% CPM_OUTPUT STRUCT SETUP
    
    cpm_output_by_sex = struct();

    for st = 1:length(scan_type_list)
        cd(CPM_HCP_Aging_path)
        
        %% run cpm here!! 
        y_hat_output_F_100 = zeros(length(pt_table_F.y),100);
        corr_output_F_100 = zeros(2, 100);
        randinds_output_F_100 = zeros(length(pt_table_F.y),100);
        pmask_output_F_100 = zeros(35778,5,100);
        for i = 1:100
            [y_hat_output_F,corr_output_F,randinds_output_F,pmask_output_F] = cpm_main(conn_mat_struct_by_sex.F_conn_mats.(char(scan_type_list(st))),pt_table_F.y','pthresh',0.01,'kfolds',5);
            y_hat_output_F_100(:,i) = y_hat_output_F;
            corr_output_F_100(1,i) =  corr_output_F(1);
            corr_output_F_100(2,i) =  corr_output_F(2);
            randinds_output_F_100(:,i) = randinds_output_F';
            pmask_output_F_100(:,:,i) = pmask_output_F;
        end
        
        cpm_output_by_sex.('F').(char('y_hat_struct')).(char(scan_type_list(st))) = y_hat_output_F_100;
        cpm_output_by_sex.('F').(char('corr_struct')).(char(scan_type_list(st))) = corr_output_F_100;
        cpm_output_by_sex.('F').(char('randinds_struct')).(char(scan_type_list(st))) = randinds_output_F_100;
        cpm_output_by_sex.('F').(char('pmask_struct')).(char(scan_type_list(st))) = pmask_output_F_100;
    end
        
    for st = 1:length(scan_type_list)     
        %% run cpm here!! 
        y_hat_output_M_100 = zeros(length(pt_table_M.y),100);
        corr_output_M_100 = zeros(2, 100);
        randinds_output_M_100 = zeros(length(pt_table_M.y),100);
        pmask_output_M_100 = zeros(35778,5,100);
        
        for i = 1:100
            [y_hat_output_M,corr_output_M,randinds_output_M,pmask_output_M] = cpm_main(conn_mat_struct_by_sex.M_conn_mats.(char(scan_type_list(st))),pt_table_M.y','pthresh',0.01,'kfolds',5);
            y_hat_output_M_100(:,i) = y_hat_output_M;
            corr_output_M_100(1,i) =  corr_output_M(1);
            corr_output_M_100(2,i) =  corr_output_M(2);
            randinds_output_M_100(:,i) = randinds_output_M';
            pmask_output_M_100(:,:,i) = pmask_output_M;
        end
        
        cpm_output_by_sex.('M').(char('y_hat_struct')).(char(scan_type_list(st))) = y_hat_output_M_100;
        cpm_output_by_sex.('M').(char('corr_struct')).(char(scan_type_list(st))) = corr_output_M_100;
        cpm_output_by_sex.('M').(char('randinds_struct')).(char(scan_type_list(st))) = randinds_output_M_100;
        cpm_output_by_sex.('M').(char('pmask_struct')).(char(scan_type_list(st))) = pmask_output_M_100;
    end
        
    %% COLLECT CPM OUTPUTS!
    if strcmp(param_list{param},'ravlt')
        save('ravlt_by_sex_cpm_output.mat', 'cpm_output_by_sex')
        disp('RAVLT results saved!')
    end
    if strcmp(param_list{param},'neon')
        save('neon_by_sex_cpm_output.mat', 'cpm_output_by_sex')
        disp('NEO-N results saved!')
    end
end

toc;

cd(CPM_HCP_Aging_path)
end
