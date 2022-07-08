%% What this function should do:
% 1. 

%% Implementation
function all_corrs = cpm_output_stats(scan_type_list, cpm_output_struct)

% collect all corr (R and p) averages and standard deviations
all_corrs = struct();
for s = 1:length(scan_type_list)
    all_corrs.(char(scan_type_list{s})).('R').('avg') = mean(cpm_output_struct.corr_struct(s).corr(1,:));
    all_corrs.(char(scan_type_list{s})).('R').('stdev') = std(cpm_output_struct.corr_struct(s).corr(1,:));
    all_corrs.(char(scan_type_list{s})).('p').('avg') = mean(cpm_output_struct.corr_struct(s).corr(2,:));
    all_corrs.(char(scan_type_list{s})).('p').('stdev') = std(cpm_output_struct.corr_struct(s).corr(2,:));
end

end