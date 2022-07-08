%% What this function should do:
% 1. 

%% Implementation
function corrs = cpm_output_stats(scan_type_list, cpm_output_struct, allsubjs_or_sex)

% collect all corr (R and p) averages and standard deviations
all_corrs = struct();
if strcmp(allsubjs_or_sex, 'allsubjs') == 1
    for s = 1:length(scan_type_list)
        corr_sorted = sort(cpm_output_struct.corr_struct.(char(scan_type_list{s}))(1,:));
        median_R = corr_sorted(51);
        all_corrs.('R_median').(char(scan_type_list{s})) = median_R;
        all_corrs.('R_median_index').(char(scan_type_list{s})) = find(cpm_output_struct.corr_struct.(char(scan_type_list{s}))(1,:) == median_R);
        all_corrs.('p_median').(char(scan_type_list{s})) = cpm_output_struct.corr_struct.(char(scan_type_list{s}))(2,all_corrs.('R_median_index').(char(scan_type_list{s})));
    end
    corrs = all_corrs;
end

all_corrs_by_sex = struct();
if strcmp(allsubjs_or_sex, 'by_sex') == 1
    for s = 1:length(scan_type_list)
        corr_sorted = sort(cpm_output_struct.F.corr_struct.(char(scan_type_list{s}))(1,:));
        median_R_F = corr_sorted(51);
        all_corrs_by_sex.('F').('R_median').(char(scan_type_list{s})) = median_R_F;
        all_corrs_by_sex.('F').('R_median_index').(char(scan_type_list{s})) = find(cpm_output_struct.F.corr_struct.(char(scan_type_list{s}))(1,:) == median_R_F);
        all_corrs_by_sex.('F').('p_median').(char(scan_type_list{s})) = cpm_output_struct.F.corr_struct.(char(scan_type_list{s}))(2,all_corrs_by_sex.F.('R_median_index').(char(scan_type_list{s})));
        
        corr_sorted = sort(cpm_output_struct.('M').corr_struct.(char(scan_type_list{s}))(1,:));
        median_R_M = corr_sorted(51);
        all_corrs_by_sex.('M').('R_median').(char(scan_type_list{s})) = median_R_M;
        all_corrs_by_sex.('M').('R_median_index').(char(scan_type_list{s})) = find(cpm_output_struct.M.corr_struct.(char(scan_type_list{s}))(1,:) == median_R_M);
        all_corrs_by_sex.('M').('p_median').(char(scan_type_list{s})) = cpm_output_struct.M.corr_struct.(char(scan_type_list{s}))(2,all_corrs_by_sex.M.('R_median_index').(char(scan_type_list{s})));
    end
    corrs = all_corrs_by_sex;
end

end