%% What this function should do:
% 1. 

%% Implementation
function corrs = cpm_output_stats(scan_type_list, cpm_output_struct, allsubjs_or_sex)

% collect all corr (R and p) averages and standard deviations
all_corrs = struct();
if strcmp(allsubjs_or_sex, 'allsubjs') == 1
    for s = 1:length(scan_type_list)
        all_corrs.('R').('avg').(char(scan_type_list{s})) = mean(cpm_output_struct.corr_struct.(char(scan_type_list{s}))(1,:));
        all_corrs.('R').('stdev').(char(scan_type_list{s})) = std(cpm_output_struct.corr_struct.(char(scan_type_list{s}))(1,:));
        all_corrs.('p').('avg').(char(scan_type_list{s})) = mean(cpm_output_struct.corr_struct.(char(scan_type_list{s}))(2,:));
        all_corrs.('p').('stdev').(char(scan_type_list{s})) = std(cpm_output_struct.corr_struct.(char(scan_type_list{s}))(2,:));
    end
    corrs = all_corrs;
end

all_corrs_by_sex = struct();
if strcmp(allsubjs_or_sex, 'by_sex') == 1
    for s = 1:length(scan_type_list)
        all_corrs_by_sex.('F').('R').('avg').(char(scan_type_list{s})) = mean(cpm_output_struct.('F').corr_struct.(char(scan_type_list{s}))(1,:));
        all_corrs_by_sex.('F').('R').('stdev').(char(scan_type_list{s})) = std(cpm_output_struct.('F').corr_struct.(char(scan_type_list{s}))(1,:));
        all_corrs_by_sex.('F').('p').('avg').(char(scan_type_list{s})) = mean(cpm_output_struct.('F').corr_struct.(char(scan_type_list{s}))(2,:));
        all_corrs_by_sex.('F').('p').('stdev').(char(scan_type_list{s})) = std(cpm_output_struct.('F').corr_struct.(char(scan_type_list{s}))(2,:));
        
        all_corrs_by_sex.('M').('R').('avg').(char(scan_type_list{s})) = mean(cpm_output_struct.('M').corr_struct.(char(scan_type_list{s}))(1,:));
        all_corrs_by_sex.('M').('R').('stdev').(char(scan_type_list{s})) = std(cpm_output_struct.('M').corr_struct.(char(scan_type_list{s}))(1,:));
        all_corrs_by_sex.('M').('p').('avg').(char(scan_type_list{s})) = mean(cpm_output_struct.('M').corr_struct.(char(scan_type_list{s}))(2,:));
        all_corrs_by_sex.('M').('p').('stdev').(char(scan_type_list{s})) = std(cpm_output_struct.('M').corr_struct.(char(scan_type_list{s}))(2,:));
    end
    corrs = all_corrs_by_sex;
end

end