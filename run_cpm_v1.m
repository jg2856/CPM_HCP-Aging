%% Written by Suyeon Ju, 1.10.22, updated 4.1.22
% This script will take in the following inputs to run CPM:
 
% Inputs: 
%   `subj_list` = list of all subject IDs (should be file name of .txt file that
%       has list of all subject IDs ['HCA#######'])
%   `behav_param` = string of name of behavioral parameter to be tested (should match with the file 
%       name of the .txt file from HCP-A dataset holding that parameter's data)
%   `scan_type` = one of the following strings: 'rfMRI_REST', 'tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'

% Example command line:
% >> run_cpm('all_subjs_ravlt_hcp-a_2.txt', 'ravlt','tfMRI_CARIT')

% Outputs:
% For now, the code just prints the resulting correlation between actual 
%   and predicted y (R and p value), but I will revise the code later to 
%   collect all CPM outputs (`y_predict` and `performance`)

%% Pseudocode

% step 1: create string array with all subj IDs from subj_list

% step 2: create for loop where:
%   - iterative variable = all subj IDs
%   - `conn_mat_single` = connectivity matrix for each subj ID for
%       specified scan_type; each conn_mat_single matrix is added in 3rd
%       dimension to `conn_mat` (holds all conn mats across all subjs)
%   - `conn_mat` = compilation of all conn mats across all subjs
%   - `conn_subj_array` = collect subj IDs of all subjs in `conn_mat`

% step 3: create matrix listing all subj IDs in `conn_subj_array` (in col 1) 
%   and corresponding behavioral parameter data pulled from `behav_param` (in col 2)

% step 4: call `cpm_main` function from MRRC's CPM matlab code

%% Implementation

function run_cpm_v1(subj_list, behav_param, scan_type)
    
% step 1:
    subj_array = readtable(subj_list, 'ReadVariableNames', false);
%     size(subj_array)

% step 2
    CM_dir = sprintf('/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/conn_mat_%s/conn_mat_output/', scan_type);
    cd(CM_dir)
    conn_mat = [];
    conn_subj_array = {};
    for h = 1:size(subj_array,1)
        try
            CM_filename = sprintf('%s_bis_matrix_1_matrix.txt', string(subj_array{h,:}));
            conn_mat_single = load(CM_filename);
%             disp(CM_filename)
%             size(conn_mat_single)
            conn_mat = cat(3,conn_mat,conn_mat_single);
%             size(conn_mat)
%             disp(h)
            conn_subj_array{end+1} = subj_array{h,:};
%             size(conn_subj_array)
        catch
            continue;
        end
    end
    
% step 3:
    behav_scores = cell(size(conn_subj_array,1),2);
    if strcmp(behav_param, 'ravlt')
        opts = detectImportOptions('/data23/mri_group/an_data/HCP-A2.0/behavioralData/ravlt01.txt');
        opts.DataLines = 3;
        opts.VariableNamesLine = 1;
        ravlt_data = readtable('/data23/mri_group/an_data/HCP-A2.0/behavioralData/ravlt01.txt',opts);
        for i = 1:size(conn_subj_array,2)
            behav_scores(i,1) = conn_subj_array{i};
            behav_scores(i,2) = num2cell(ravlt_data{strcmp(ravlt_data.src_subject_id, conn_subj_array{i}),'pea_ravlt_sd_tc'}); % RAVLT Short Delay Total Correct
        end
    elseif strcmp(behav_param, 'psm') 
        opts = detectImportOptions('/data23/mri_group/an_data/HCP-A2.0/behavioralData/psm01.txt');
        opts.DataLines = 3;
        opts.VariableNamesLine = 1;
        psm_data = readtable('/data23/mri_group/an_data/HCP-A2.0/behavioralData/psm01.txt',opts);
        for i = 1:size(conn_subj_array,2)
            behav_scores(i,1) = conn_subj_array{i};
            behav_scores(i,2) = num2cell(psm_data{strcmp(psm_data.src_subject_id, conn_subj_array{i}),'nih_picseq_ageadjusted'}); % Age Adjusted scaled score for PicSeq subtest
        end
    elseif strcmp(behav_param, 'pcps') 
        opts = detectImportOptions('/data23/mri_group/an_data/HCP-A2.0/behavioralData/pcps01.txt');
        opts.DataLines = 3;
        opts.VariableNamesLine = 1;
        pcps_data = readtable('/data23/mri_group/an_data/HCP-A2.0/behavioralData/pcps01.txt',opts);
        for i = 1:size(conn_subj_array,2)
            behav_scores(i,1) = conn_subj_array{i};
            behav_scores(i,2) = num2cell(pcps_data{strcmp(pcps_data.src_subject_id, conn_subj_array{i}),'nih_patterncomp_ageadjusted'}); % Age Adjusted scaled score for PatternComp subtest
        end
    elseif strcmp(behav_param, 'nffi')
        opts = detectImportOptions('/data23/mri_group/an_data/HCP-A2.0/behavioralData/nffi01.txt');
        opts.DataLines = 3;
        opts.VariableNamesLine = 1;
        nffi_data = readtable('/data23/mri_group/an_data/HCP-A2.0/behavioralData/nffi01.txt',opts);
        for i = 1:size(conn_subj_array,2)
            behav_scores(i,1) = conn_subj_array{i};
            behav_scores(i,2) = num2cell(nffi_data{strcmp(nffi_data.src_subject_id, conn_subj_array{i}),'neo2_score_ne'}); % Neuroticism score
        end
    else
        disp('error: please enter a valid behavioral parameter! (either ravlt, pcps, or nffi)')
    end
    
    size(behav_scores)
%     disp(behav_scores)


% step 4:
    cd ../../CPM/matlab/func/
%     class(cell2mat(behav_scores(:,2)))
%     size(cell2mat(behav_scores(:,2))')
    [y_hat,corr] = cpm_main(conn_mat, cell2mat(behav_scores(:,2)'));
%     disp(y_hat)
    disp(corr)
    cd(CM_dir)
    cd /data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/


end