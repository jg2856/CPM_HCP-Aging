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
% >> run_cpm_setup({'ravlt','neon'},{'rfMRI_REST1_AP', 'rfMRI_REST1_PA', 'rfMRI_REST2_AP', 'rfMRI_REST2_PA','tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'})

% outputs:
%   saves a .mat file for each param in param_list with structs holding all pt info ('pt_struct_allsubjs') and connectivity matrices ('conn_mat_struct_allsubjs')

%% Implementation
function run_cpm_setup(param_list, scan_type_list)
tic;

CPM_HCP_Aging_path = '/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/CPM_HCP-Aging/';
hcp_a_cpm_path = '/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/';
behavioralData_path = '/data23/mri_group/an_data/HCP-A2.0/behavioralData/';

for param = 1:length(param_list)
    cd (CPM_HCP_Aging_path)
    
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
    
    %% PT STRUCT SETUP
    % initialize struct with all pt demo info and conn mats (pt_struct)
    pt_struct_allsubjs(length(pt)) = struct('pt_id',[],'age',[],'sex',[],'y',[]);
    
    %% CONN_MAT STRUCT SETUP
    % initialize struct with all conn_mats (n x m x n_subs) for each scan type in scan_type_list (conn_mat_struct)
    conn_mat_struct_allsubjs = struct();
    
    for st = 1:length(scan_type_list)
        %% CONN_MAT SETUP/COLLECTION
        conn_mat = [];
        for sub = 1:length(pt)
            CM_dir = sprintf('%s%s/connmat_output', hcp_a_cpm_path, scan_type_list{st});
            cd(CM_dir)

            CM_filename = sprintf('%s_bis_matrix_1_matrix.txt', char(pt(sub)));
            conn_mat_single = load(CM_filename);
            conn_mat = cat(3,conn_mat,conn_mat_single);
            
            %% PT STRUCT POPULATION 
            pt_struct_allsubjs(sub) = struct('pt_id',pt(sub),'age',all_pt_demos{pt(sub),'age'},...
                'sex',all_pt_demos{pt(sub),'sex'},'y',param_data(sub));
        end
        %% CONN_MAT STRUCT POPULATION
        conn_mat_struct_allsubjs.(char(scan_type_list(st))) = conn_mat;
    end
    
    cd(CPM_HCP_Aging_path)
    
    %% COLLECT PT INFO AND ALL CONNECTIVITY MATRICES!
    if strcmp(param_list{param},'ravlt')
        save('ravlt_allsubjs_pt_conn_mat.mat', 'pt_struct_allsubjs', 'conn_mat_struct_allsubjs','-v7.3')
        disp('RAVLT pt info and connectivity matrices saved!')
    end
    if strcmp(param_list{param},'neon')
        save('neon_allsubjs_pt_conn_mat.mat', 'pt_struct_allsubjs', 'conn_mat_struct_allsubjs','-v7.3')
        disp('NEO-N pt info and connectivity matrices saved!')
    end
end

toc;
end