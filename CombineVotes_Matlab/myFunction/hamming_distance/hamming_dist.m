%calculate the hamming dist between two vectors a and b.

function dist = hamming_dist( a , b )

%check if a and b have the same length
if length(a) ~= length(b)
    disp('caution: the length of two input vectors do not have the same length');
    exit
end


%count the differences of each digit of a and b 
dist = sum( a ~= b);
