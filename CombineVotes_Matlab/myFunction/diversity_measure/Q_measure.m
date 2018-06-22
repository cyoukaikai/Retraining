% preds : number_of_examples by number_of_models
function Qavg = Q_measure( preds, truth )


True_or_False_Flages  =  ( preds ==  truth * ones(1, size( preds,2) ) );
num_model = size(preds,2 );
% diversity_measure = zeros(num_original_run, num_original_run, result_dim );
diversity_measure = [];
Normalized_count =  0;
for i = 1 : num_model
    for j = i + 1 : num_model
        Q_value =  Q_sta(  True_or_False_Flages(:,i),   True_or_False_Flages(:,j) );
        
         diversity_measure = [diversity_measure  Q_value];
         Normalized_count =  Normalized_count + 1;
%         disp( ['i =' num2str(i) ', j = ' num2str(j) ]);
    end
end
Qavg = sum(  diversity_measure ) / Normalized_count ;
%      Qmean = mean( diversity_measure (:) );
%      Qmax = max( diversity_measure (:) );
%      Qmin = min( diversity_measure (:) );
%      Qstd = std( diversity_measure (:) );
     
%      Q  = Qmean;
% disp( [save_file_prefix ' ,avg =' num2str( Qavg) ',  mean = ' num2str(Qmean)...
%     ',  max = ' num2str(Qmax) ',  min = ' num2str(Qmin) ',  std = ' num2str(Qstd)]);
% save([save_file_prefix '_Q_sta.mat'], 'diversity_measure');

end