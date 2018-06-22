
%cal the ensemble accuracy and oracle accu based on the minimum hamming
%distance
% function [accu_ensemble, accu_oracle, dist_record] = ensemble_accu_oracle_based_on_hamming_dist(preds, codewords, truth )
function [accu_ensemble, accu_oracle, ensemble_predictions] = MakeEnsembleBasedOnHammingDistanceEncoding_A(preds, codewords, truth )
% %check if a and b have the same length
% if size(preds,2) ~= size(codewords,2)
%     disp('caution: the length of two input vectors do not have the same length');
%     exit
% end
% 
% if ( size(preds,1) ~= length(truth) )
%     disp('caution: the length of two input vectors preds and truth do not match');
%     exit
% end

num_images = length( truth );
num_class = size(codewords, 1);
oracle_accu_count = 0;
ensemble_predictions = zeros( num_images, 1);
% dist_record = zeros( num_images, num_class );

for i = 1 : num_images
    dist_cals = zeros( num_class, 1 );
    for j = 1 : num_class
        %count the differences of each digit of a and b 
        dist_cals(j) = hamming_dist( codewords(j,:), preds(i,:) );
    end
    [Y, ensemble_predictions(i)] = min( dist_cals );
%     dist_record(i, :)  = dist_cals';
    
   if ~isempty( find( preds(i,:) == codewords(truth(i) + 1,:), 1 ))
        oracle_accu_count = oracle_accu_count + 1;
    end

%     if ~isempty( find( preds(i,:) == truth(i) ))
%         oracle_accu_count = oracle_accu_count + 1;
%     end
end
ensemble_predictions = ensemble_predictions - 1; %transfer to 0-index
% predict_color_map = (truth ==  ensemble_predictions);

accu_ensemble = sum(truth ==  ensemble_predictions)/ length( truth ) * 100;  %chagne to percent%.
accu_oracle = oracle_accu_count / length( truth ) * 100;  %chagne to percent%.
        
        






