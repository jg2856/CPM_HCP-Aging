arr = [];
for i = 1:7
    arr = [arr; neon_by_sex_corrs.F.R.stdev.(char(f{i}))];
end
% disp(arr)