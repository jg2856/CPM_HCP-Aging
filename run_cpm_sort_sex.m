%% Written by Suyeon Ju, 6.6.22

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
hcp_a_cpm_path = '/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/';
behavioralData_path = '/data23/mri_group/an_data/HCP-A2.0/behavioralData/';

for param = 1:length(param_list)
    cd(CPM_HCP_Aging_path)
    
    %% PT LIST SETUP
    % collect subj demographic info
    all_pt_demos_temp = readtable(strcat(hcp_a_cpm_path,'HCP-A_cpm_pt_demos.csv'));
    all_pt_demos = table(all_pt_demos_temp.interview_age, all_pt_demos_temp.sex, 'RowNames',all_pt_demos_temp.src_subject_id);
    all_pt_demos.Properties.VariableNames = ["age", "sex"];
    
    % collect all subj ID lists
    all_param_pt = readtable(strcat(hcp_a_cpm_path,'HCP-A_cpm_project_exclusion_criteria.csv'));
    
    % set up array for correct subj list from all_subjs
    pt = [];
    
    % set up array for parameter data for each subj
    param_data = [];
    
    %% set pt array and param_data array to correct subj list/param scores, depending on input params (MAKE FUNCTION OUT OF THIS LATER!!!)
    if strcmp(param_list{param},'ravlt')
        pt = all_param_pt.ravlt(1:567,:);
        opts = detectImportOptions(strcat(behavioralData_path,'ravlt01.txt'));
        opts.DataLines = 3;
        opts.VariableNamesLine = 1;
        ravlt_data = readtable(strcat(behavioralData_path,'ravlt01.txt'),opts);
        param_data = NaN(length(pt),1);
        for i = 1:length(pt)
            param_data(i) = ravlt_data{strcmp(ravlt_data.src_subject_id, pt(i)),'pea_ravlt_sd_tc'}; % RAVLT Short Delay Total Correct
        end
    end
    if strcmp(param_list{param},'neon')
        pt = all_param_pt.neon(1:579,:);
        opts = detectImportOptions(strcat(behavioralData_path,'nffi01.txt'));
        opts.DataLines = 3;
        opts.VariableNamesLine = 1;
        neon_data = readtable(strcat(behavioralData_path,'nffi01.txt'),opts);
        param_data = NaN(length(pt),1);
        for i = 1:length(pt)
            param_data(i) = neon_data{strcmp(neon_data.src_subject_id, pt(i)),'neo2_score_ne'}; % Neuroticism score
        end
    end

    %% PT TABLE SETUP
    pt_id = pt;
    age = all_pt_demos{pt,'age'};
    sex = all_pt_demos{pt,'sex'};
    y = param_data;
    
    pt_table = table(pt_id, age, sex, y);
    pt_table_F = pt_table(strcmp(pt_table.sex, 'F'),:);
    pt_table_M = pt_table(strcmp(pt_table.sex, 'M'),:);
    
    pt_struct_by_sex = struct('pt_all',pt_table, 'pt_F',pt_table_F, 'pt_M',pt_table_M);

    %% CONN_MAT STRUCT SETUP
    % initialize struct with all conn_mats (n x m x n_subs) for each scan type in scan_type_list (conn_mat_struct)
    conn_mat_struct(length(scan_type_list)) = struct('scan_type',[],'conn_mat',[]);
    
    for g = ['F', 'M']
        if g == 'F'
            pts = pt_table_F;
        end
        if g == 'M'
            pts = pt_table_M;
        end
        
        for st = 1:length(scan_type_list)
            %% CONN_MAT SETUP/COLLECTION
            conn_mat = [];
            for sub = 1:size(pts,1)
                CM_dir = sprintf('/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/%s/connmat_output', scan_type_list{st});
                cd(CM_dir)
                
                CM_filename = sprintf('%s_bis_matrix_1_matrix.txt', char(pts.pt_id(sub)));
                conn_mat_single = load(CM_filename);
                conn_mat = cat(3,conn_mat,conn_mat_single);
            end
            %% CONN_MAT STRUCT POPULATION
            conn_mat_struct(st) = struct('scan_type',scan_type_list(st),'conn_mat', conn_mat);
        end
        
        if g == 'F'
            conn_mat_struct_F = conn_mat_struct;
            size(conn_mat_struct_F)
        end
        if g == 'M'
            conn_mat_struct_M = conn_mat_struct;
            size(conn_mat_struct_M)
        end
        
    end

    %% CODE TO RUN CPM!!! ***
    
    %% CPM_OUTPUT STRUCT SETUP
    % initialize structs with all cpm outputs(y_hat and corr) for each 
    %   scan type (y_hat_struct and corr_struct)
    
%     i = 1; % i = 1: female, i = 2: male
%     for c = [conn_mat_struct_F,conn_mat_struct_M]
%         for st = 1:length(scan_type_list)
%             cd(CPM_HCP_Aging_path)
%             %% run cpm here!!
%             if i == 1
%                 size(c(st).conn_mat)
%                 size(pt_table_F.y')
%                 [y_hat_output,corr_output,randinds_output,pmask_output] = cpm_main(c(st).conn_mat,pt_table_F.y','pthresh',0.01,'kfolds',5);
%             end
%             if i == 2
%                 size(c(st).conn_mat)
%                 size(pt_table_M.y')
%                 [y_hat_output,corr_output,randinds_output,pmask_output] = cpm_main(c(st).conn_mat,pt_table_M.y','pthresh',0.01,'kfolds',5);
%             end
% 
%             y_hat_struct(st) = struct('scan_type',scan_type_list(st),'y_hat',y_hat_output);
%             corr_struct(st) = struct('scan_type',scan_type_list(st),'corr',corr_output);
%             randinds_struct(st) = struct('scan_type',scan_type_list(st),'randinds',randinds_output);
%             pmask_struct(st) = struct('scan_type',scan_type_list(st),'pmask',pmask_output);
%         end
%     
%     % create cpm_output struct to hold both y_hat_struct and corr_struct
%     cpm_output(i) = struct('y_hat_struct',y_hat_struct,'corr_struct',corr_struct,'randinds_struct',randinds_struct, 'pmask_struct',pmask_struct);
%         i = i+1;
%     end
    
    %% create cpm_output struct to hold both y_hat_struct and corr_struct
    for st = 1:length(scan_type_list)
        cd(CPM_HCP_Aging_path)

        size(conn_mat_struct_F(st).conn_mat)
        size(pt_table_F.y')
        [y_hat_output,corr_output,randinds_output,pmask_output] = cpm_main(conn_mat_struct_F(st).conn_mat,pt_table_F.y','pthresh',0.01,'kfolds',5);

        y_hat_struct(st) = struct('scan_type',scan_type_list(st),'y_hat',y_hat_output);
        corr_struct(st) = struct('scan_type',scan_type_list(st),'corr',corr_output);
        randinds_struct(st) = struct('scan_type',scan_type_list(st),'randinds',randinds_output);
        pmask_struct(st) = struct('scan_type',scan_type_list(st),'pmask',pmask_output);
    end
    cpm_output_by_sex(1) = struct('y_hat_struct',y_hat_struct,'corr_struct',corr_struct,'randinds_struct',randinds_struct, 'pmask_struct',pmask_struct);
    
    for st = 1:length(scan_type_list)
        cd(CPM_HCP_Aging_path)

        size(conn_mat_struct_M(st).conn_mat)
        size(pt_table_M.y')
        [y_hat_output,corr_output,randinds_output,pmask_output] = cpm_main(conn_mat_struct_M(st).conn_mat,pt_table_M.y','pthresh',0.01,'kfolds',5);

        y_hat_struct(st) = struct('scan_type',scan_type_list(st),'y_hat',y_hat_output);
        corr_struct(st) = struct('scan_type',scan_type_list(st),'corr',corr_output);
        randinds_struct(st) = struct('scan_type',scan_type_list(st),'randinds',randinds_output);
        pmask_struct(st) = struct('scan_type',scan_type_list(st),'pmask',pmask_output);
    end
    cpm_output_by_sex(2) = struct('y_hat_struct',y_hat_struct,'corr_struct',corr_struct,'randinds_struct',randinds_struct, 'pmask_struct',pmask_struct);
    
    %% set pt array and param_data array to correct subj list/param scores, depending on input params
    if strcmp(param_list{param},'ravlt')
        save('pt_struct_ravlt_by_sex.mat', 'pt_struct_by_sex')
        save('cpm_output_ravlt_by_sex.mat', 'cpm_output_by_sex')
        disp('RAVLT results saved!')
    end
    if strcmp(param_list{param},'neon')
        save('pt_struct_neon_by_sex.mat', 'pt_struct_by_sex')
        save('cpm_output_neon_by_sex.mat', 'cpm_output_by_sex')
        disp('NEO-N results saved!')
    end
end

toc;

cd(CPM_HCP_Aging_path)
end
