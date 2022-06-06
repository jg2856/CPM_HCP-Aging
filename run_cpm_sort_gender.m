%% Written by Suyeon Ju, 1.25.22, updated 4.1.22
% This script will take in the following inputs to run CPM:

% Inputs: 
%   `subj_list_all` = cell array of .txt file names of all lists of subject IDs 
%       (should be file name of .txt file that has list of all subject IDs ['HCA#######'])
%       i.e., "{'all_subjs_ravlt_hcp-a_2.txt', 'all_subjs_pcps_hcp-a_2.txt', 'all_subjs_nffi_hcp-a_2.txt'}"
%   `behav_param_list` = cell array of behavioral parameters to be tested
%       i.e., "{'ravlt','pcps','nffi'}"
%   `scan_type_list` = cell array containing one or more of the following: 
%       'rfMRI_REST1_AP', 'rfMRI_REST1_PA', 'rfMRI_REST2_AP', 'rfMRI_REST2_PA',
%       'tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'
%       i.e., "{'tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'}"
 
% Example command line:
% >> run_cpm_sort_gender({'all_subjs_ravlt_hcp-a_2.txt', 'all_subjs_pcps_hcp-a_2.txt', 'all_subjs_nffi_hcp-a_2.txt'}, {'ravlt', 'pcps', 'nffi'}, {'tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'})

% Outputs:
%   `all_results_m` = cell array holding all male subjects' CPM results (`behav_param`, `scan_type`, `behav_scores_m`, `y_hat_m`, `corr_m`)
%   `all_results_f` = cell array holding all female subjects' CPM results (`behav_param`, `scan_type`, `behav_scores_f`, `y_hat_f`, `corr_f`)
%   For now, the code just prints the contents of the `all_results` cell arrays and 
%       resulting correlations between actual and predicted y (R and p value, for both male and female predictive models), 
%       but I will revise the code later to collect and save all CPM outputs (`y_predict` and `performance`)

%% Pseudocode

% NOTE: All of the following steps are within a nested for-loop to allow for 
%   batch parameter runs (outer loop = loops through list of selected behavioral parameters; 
%   inner loop = loops through list of scan types)

% step 1: create string array with all subj IDs from `subj_list_all`
%
% step 2: create for loop where:
%   iterative variable = all subj IDs
%   `conn_mat_single` = connectivity matrix for each subj ID for specified scan_type; each conn_mat_single matrix is added in 3rd dimension to `conn_mat` (holds all conn mats across all subjs)
%   `conn_mat` = compilation of all conn mats across all subjs
%   `conn_subj_array` = collect subj IDs of all subjs in `conn_mat`
%
% step 3: create separate cell arrays for male (`behav_scores_m`) and female (`behav_scores_f`) subjects that collect:
%   -all subj IDs in `conn_subj_array` (in col 1)
%   -corresponding behavioral parameter data pulled from `behav_param` (in col 2)
%   -corresponding gender of each subj (in col 3)
%   -corresponding connectivity matrix for each subj (in col 4)
%
% step 4: extract male (`conn_mat_m`) and female (`conn_mat_f`) connectivity matrices from the `behav_scores` cell arrays (for ease of inputting the matrices into CPM in step 5)
%
% step 5: call `cpm_main` function from MRRC's CPM matlab code separately for each gender (generates predictive model and outputs results for each gender separately!)

%% Implementation

function run_cpm_sort_gender(subj_list_all, behav_param_list, scan_type_list)

all_results_m = {}; % holds all male subjects' CPM results (behav_param, scan_type, behav_scores_m, y_hat_m, corr_m)
all_results_f = {}; % holds all female subjects' CPM results (behav_param, scan_type, behav_scores_f, y_hat_f, corr_f)

for bp = 1:length(behav_param_list)
    behav_param = behav_param_list{bp};
    disp(behav_param)
    subj_list = subj_list_all{bp};
    disp(subj_list)
    
    for st = 1:length(scan_type_list)
        scan_type = scan_type_list{st};
        disp(scan_type)
    
    % step 1:
        subj_array = readtable(subj_list, 'ReadVariableNames', false);

    % step 2
        CM_dir = sprintf('/data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/conn_mat_%s/conn_mat_output/', scan_type);
        cd(CM_dir)
        conn_mat = [];
        conn_subj_array = {};
        for h = 1:size(subj_array,1)
            try
                CM_filename = sprintf('%s_bis_matrix_1_matrix.txt', string(subj_array{h,:}));
                conn_mat_single = load(CM_filename);
                conn_mat = cat(3,conn_mat,conn_mat_single);
                conn_subj_array{end+1} = subj_array{h,:};
            catch
                continue;
            end
        end

    % step 3:
        behav_scores_m = cell(size(conn_subj_array,1),4);
        behav_scores_f = cell(size(conn_subj_array,1),4);
        if strcmp(behav_param, 'ravlt')
            opts = detectImportOptions('/data23/mri_group/an_data/HCP-A2.0/behavioralData/ravlt01.txt');
            opts.DataLines = 3;
            opts.VariableNamesLine = 1;
            ravlt_data = readtable('/data23/mri_group/an_data/HCP-A2.0/behavioralData/ravlt01.txt',opts);
            for i = 1:size(conn_subj_array,2)
                if strcmp(ravlt_data{strcmp(ravlt_data.src_subject_id, conn_subj_array{i}),'sex'},'M')
                    behav_scores_m(i,1) = conn_subj_array{i};
                    behav_scores_m(i,2) = num2cell(ravlt_data{strcmp(ravlt_data.src_subject_id, conn_subj_array{i}),'pea_ravlt_sd_tc'}); % RAVLT Short Delay Total Correct
                    behav_scores_m(i,3) = ravlt_data{strcmp(ravlt_data.src_subject_id, conn_subj_array{i}),'sex'}; % Sex of the subject
                    behav_scores_m{i,4} = conn_mat(:,:,i);
                end
                if strcmp(ravlt_data{strcmp(ravlt_data.src_subject_id, conn_subj_array{i}),'sex'},'F')
                    behav_scores_f(i,1) = conn_subj_array{i};
                    behav_scores_f(i,2) = num2cell(ravlt_data{strcmp(ravlt_data.src_subject_id, conn_subj_array{i}),'pea_ravlt_sd_tc'}); % RAVLT Short Delay Total Correct
                    behav_scores_f(i,3) = ravlt_data{strcmp(ravlt_data.src_subject_id, conn_subj_array{i}),'sex'}; % Sex of the subject
                    behav_scores_f{i,4} = conn_mat(:,:,i);
                end
            end
    %         disp(behav_scores)
%         elseif strcmp(behav_param, 'psm') 
%             opts = detectImportOptions('/data23/mri_group/an_data/HCP-A2.0/behavioralData/psm01.txt');
%             opts.DataLines = 3;
%             opts.VariableNamesLine = 1;
%             psm_data = readtable('/data23/mri_group/an_data/HCP-A2.0/behavioralData/psm01.txt',opts);
%             for i = 1:size(conn_subj_array,2)
%                 behav_scores(i,1) = conn_subj_array{i};
%                 behav_scores(i,2) = num2cell(psm_data{strcmp(psm_data.src_subject_id, conn_subj_array{i}),'nih_picseq_ageadjusted'}); % Age Adjusted scaled score for PicSeq subtest
%             end
        elseif strcmp(behav_param, 'pcps') 
            opts = detectImportOptions('/data23/mri_group/an_data/HCP-A2.0/behavioralData/pcps01.txt');
            opts.DataLines = 3;
            opts.VariableNamesLine = 1;
            pcps_data = readtable('/data23/mri_group/an_data/HCP-A2.0/behavioralData/pcps01.txt',opts);
            for i = 1:size(conn_subj_array,2)
                if strcmp(pcps_data{strcmp(pcps_data.src_subject_id, conn_subj_array{i}),'sex'},'M')
                    behav_scores_m(i,1) = conn_subj_array{i};
                    behav_scores_m(i,2) = num2cell(pcps_data{strcmp(pcps_data.src_subject_id, conn_subj_array{i}),'nih_patterncomp_ageadjusted'}); % Age Adjusted scaled score for PatternComp subtest
                    behav_scores_m(i,3) = pcps_data{strcmp(pcps_data.src_subject_id, conn_subj_array{i}),'sex'}; % Sex of the subject
                    behav_scores_m{i,4} = conn_mat(:,:,i);
                end
                if strcmp(pcps_data{strcmp(pcps_data.src_subject_id, conn_subj_array{i}),'sex'},'F')
                    behav_scores_f(i,1) = conn_subj_array{i};
                    behav_scores_f(i,2) = num2cell(pcps_data{strcmp(pcps_data.src_subject_id, conn_subj_array{i}),'nih_patterncomp_ageadjusted'}); % Age Adjusted scaled score for PatternComp subtest
                    behav_scores_f(i,3) = pcps_data{strcmp(pcps_data.src_subject_id, conn_subj_array{i}),'sex'}; % Sex of the subject
                    behav_scores_f{i,4} = conn_mat(:,:,i);
                end
            end
        elseif strcmp(behav_param, 'nffi')
            opts = detectImportOptions('/data23/mri_group/an_data/HCP-A2.0/behavioralData/nffi01.txt');
            opts.DataLines = 3;
            opts.VariableNamesLine = 1;
            nffi_data = readtable('/data23/mri_group/an_data/HCP-A2.0/behavioralData/nffi01.txt',opts);
            for i = 1:size(conn_subj_array,2)
                if strcmp(nffi_data{strcmp(nffi_data.src_subject_id, conn_subj_array{i}),'sex'},'M')
                    behav_scores_m(i,1) = conn_subj_array{i};
                    behav_scores_m(i,2) = num2cell(nffi_data{strcmp(nffi_data.src_subject_id, conn_subj_array{i}),'neo2_score_ne'}); % Neuroticism score
                    behav_scores_m(i,3) = nffi_data{strcmp(nffi_data.src_subject_id, conn_subj_array{i}),'sex'}; % Sex of the subject
                    behav_scores_m{i,4} = conn_mat(:,:,i);
                end
                if strcmp(nffi_data{strcmp(nffi_data.src_subject_id, conn_subj_array{i}),'sex'},'F')
                    behav_scores_f(i,1) = conn_subj_array{i};
                    behav_scores_f(i,2) = num2cell(nffi_data{strcmp(nffi_data.src_subject_id, conn_subj_array{i}),'neo2_score_ne'}); % Neuroticism score
                    behav_scores_f(i,3) = nffi_data{strcmp(nffi_data.src_subject_id, conn_subj_array{i}),'sex'}; % Sex of the subject
                    behav_scores_f{i,4} = conn_mat(:,:,i);
                end
            end
        else
            disp('error: please enter a valid behavioral parameter! (either ravlt, pcps, or nffi)')
        end

        behav_scores_m = behav_scores_m(~cellfun(@isempty, behav_scores_m(:,1)), :);
        behav_scores_f = behav_scores_f(~cellfun(@isempty, behav_scores_f(:,1)), :);
    
    % step 4:
        conn_mat_m = [];
        conn_mat_f = [];

        for i = 1:size(behav_scores_m,1)
            conn_mat_m = cat(3, conn_mat_m, behav_scores_m{i,4});
        end

        for j = 1:size(behav_scores_f,1)
            conn_mat_f = cat(3, conn_mat_f, behav_scores_f{j,4});
        end

    % step 5:
        cd ../../CPM/matlab/func/

        [y_hat_m,corr_m] = cpm_main(conn_mat_m, cell2mat(behav_scores_m(:,2)'));
        cpm_results_m = {behav_param, scan_type, behav_scores_m, y_hat_m, corr_m};
        disp('M')
        disp(cpm_results_m)
        size(cpm_results_m)
        disp(corr_m)

        [y_hat_f,corr_f] = cpm_main(conn_mat_f, cell2mat(behav_scores_f(:,2)'));
        cpm_results_f = {behav_param, scan_type, behav_scores_f, y_hat_f, corr_f};
        disp('F')
        disp(cpm_results_f)
        size(cpm_results_f)
        disp(corr_f)

        cd(CM_dir)
        cd /data23/mri_researchers/fredericks_data/shared/hcp_aging_analyses/hcp-a_cpm/
        
        all_results_m = cat(3, all_results_m, cpm_results_m);
        all_results_f = cat(3, all_results_f, cpm_results_f);
    end
end

% save('all_results.mat', 'all_results_m', 'all_results_f')

end