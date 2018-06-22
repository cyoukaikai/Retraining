%calculate the hamming dist between two vectors a and b.

%input: preds, only one row, are the predictions of all classifiers for one
%single example
%codewords: the ground_truth for each class of this single example
%output: the class_id (1-index) what ever the input is 0-index or 1-index
function [Y, I] = minimum_hamming_dist( preds , codewords )

%check if a and b have the same length
if size(preds,2) ~= size(codewords,2)
    disp('caution: the length of two input vectors do not have the same length');
    exit
end



num_class = size(codewords, 1);
dist_cals = zeros( num_class, 1 );
for i = 1 : num_class
    %count the differences of each digit of a and b 
    dist_cals(i) = hamming_dist( codewords(i,:), preds );
end
[Y, I] = min( dist_cals );

