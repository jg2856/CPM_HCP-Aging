b = pmask_test(:,:,1)';

n=roots([1,1,-2*(numel(b))]);
n=n(n>0)+1;
% validateattributes(n,{'numeric'},{'positive', 'integer'}) %numel(b) must be a pyramidal number
C=tril(ones(267));
C(logical(C))=b;
C=C+C.'+eye(267);