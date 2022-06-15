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
% >> run_cpm({'ravlt','neon'},{'rfMRI_REST1_AP', 'rfMRI_REST1_PA', 'rfMRI_REST2_AP', 'rfMRI_REST2_PA','tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'})

% Outputs:

%% Implementation

function run_cpm(param_list, scan_type_list)
tic;

for param = 1:length(param_list)
    cd '/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/CPM_HCP-Aging/'
    
    %% PT LIST SETUP
    % collect subj demographic info
    all_pt_demos_temp = readtable('/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/HCP-A_cpm_pt_demos.csv');
    all_pt_demos = table(all_pt_demos_temp.interview_age, all_pt_demos_temp.sex, 'RowNames',all_pt_demos_temp.src_subject_id);
    all_pt_demos.Properties.VariableNames = ["age", "sex"];
    
    % collect all subj ID lists
    all_param_pt = readtable('/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/HCP-A_cpm_project_exclusion_criteria.csv');
    
    % set up array for correct subj list from all_subjs
    pt = [];
    
    % set up array for parameter data for each subj
    param_data = [];
    
    % set pt array and param_data array to correct subj list/param scores, depending on input params
    if strcmp(param_list{param},'ravlt')
        pt = all_param_pt.ravlt(1:567,:);
        opts = detectImportOptions('/data23/mri_group/an_data/HCP-A2.0/behavioralData/ravlt01.txt');
        opts.DataLines = 3;
        opts.VariableNamesLine = 1;
        ravlt_data = readtable('/data23/mri_group/an_data/HCP-A2.0/behavioralData/ravlt01.txt',opts);
        param_data = NaN(length(pt),1);
        for i = 1:length(pt)
            param_data(i) = ravlt_data{strcmp(ravlt_data.src_subject_id, pt(i)),'pea_ravlt_sd_tc'}; % RAVLT Short Delay Total Correct
        end
    end
    if strcmp(param_list{param},'neon')
        pt = all_param_pt.neon(1:579,:);
        opts = detectImportOptions('/data23/mri_group/an_data/HCP-A2.0/behavioralData/nffi01.txt');
        opts.DataLines = 3;
        opts.VariableNamesLine = 1;
        neon_data = readtable('/data23/mri_group/an_data/HCP-A2.0/behavioralData/nffi01.txt',opts);
        param_data = NaN(length(pt),1);
        for i = 1:length(pt)
            param_data(i) = neon_data{strcmp(neon_data.src_subject_id, pt(i)),'neo2_score_ne'}; % Neuroticism score
        end
    end
    
    %% PT STRUCT SETUP
    % initialize struct with all pt demo info and conn mats (pt_struct)
    pt_struct(length(pt)) = struct('pt_id',[],'age',[],'sex',[],'y',[]);
    
    %% CONN_MAT STRUCT SETUP
    % initialize struct with all conn_mats (n x m x n_subs) for each scan type in scan_type_list (conn_mat_struct)
    conn_mat_struct(length(scan_type_list)) = struct('scan_type',[],'conn_mat',[]);
    
    for st = 1:length(scan_type_list)
        %% CONN_MAT SETUP/COLLECTION
        conn_mat = [];
        for sub = 1:length(pt)
            CM_dir = sprintf('/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/%s/connmat_output', scan_type_list{st});
            cd(CM_dir)

            try
                CM_filename = sprintf('%s_bis_matrix_1_matrix.txt', char(pt(sub)));
                conn_mat_single = load(CM_filename);
                conn_mat = cat(3,conn_mat,conn_mat_single);
            catch
                % might be able to get rid of this try catch thing and just have the contents of the 'try' instead!
                disp('ERROR - conn mat not found:')
                disp(pt(sub))
                disp(scan_type)
                disp('error end')
                continue;
            end
            %% PT STRUCT POPULATION 
            pt_struct(sub) = struct('pt_id',pt(sub),'age',all_pt_demos{pt(sub),'age'},...
                'sex',all_pt_demos{pt(sub),'sex'},'y',param_data(sub));
        end
        %% CONN_MAT STRUCT POPULATION
        conn_mat_struct(st) = struct('scan_type',scan_type_list(st),'conn_mat', conn_mat);
        
    end

    %% CODE TO RUN CPM!!! ***
    
    %% CPM_OUTPUT STRUCT SETUP
    % initialize structs with all cpm outputs(y_hat and corr) for each 
    %   scan type (y_hat_struct and corr_struct)
    
    y_hat_struct(length(scan_type_list)) = struct('scan_type',[],'y_hat',[]);
    corr_struct(length(scan_type_list)) = struct('scan_type',[],'corr',[]);
    randinds_struct(length(scan_type_list)) = struct('scan_type',[],'randinds',[]);
    pmask_struct(length(scan_type_list)) = struct('scan_type',[],'pmask',[]);
    
    for st = 1:length(scan_type_list)
        cd '/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/CPM_HCP-Aging/'
        
        %% run cpm here!! 
        [y_hat_output,corr_output,randinds_output,pmask_output] = cpm_main(conn_mat_struct(st).conn_mat,param_data','pthresh',0.01,'kfolds',5);
        
        y_hat_struct(st) = struct('scan_type',scan_type_list(st),'y_hat',y_hat_output);
        corr_struct(st) = struct('scan_type',scan_type_list(st),'corr',corr_output);
        randinds_struct(st) = struct('scan_type',scan_type_list(st),'randinds',randinds_output);
        pmask_struct(st) = struct('scan_type',scan_type_list(st),'pmask',pmask_output);
    end
    
    % create cpm_output struct to hold both y_hat_struct and corr_struct
    cpm_output = struct('y_hat_struct',y_hat_struct,'corr_struct',corr_struct,'randinds_struct',randinds_struct, 'pmask_struct',pmask_struct);
    
    %% CHECK SCRIPT!!!
    disp('CHECK!!')
    disp(y_hat_struct)
    disp(corr_struct)
    disp(randinds_struct)
    disp(pmask_struct)
    disp(cpm_output)
    disp('check end')
    
    
    % set pt array and param_data array to correct subj list/param scores, depending on input params
    if strcmp(param_list{param},'ravlt')
        save('pt_struct_ravlt.mat', 'pt_struct')
        save('cpm_output_ravlt.mat', 'cpm_output')
        disp('RAVLT results saved!')
    end
    if strcmp(param_list{param},'neon')
        save('pt_struct_neon.mat', 'pt_struct')
        save('cpm_output_neon.mat', 'cpm_output')
        disp('NEO-N results saved!')
    end
end

toc;

cd '/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/CPM_HCP-Aging/'
end
