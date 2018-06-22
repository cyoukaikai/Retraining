

function Q = Q_statistics(RaRd_original100Run ) %, save_file_prefix
% result_dim = 1; %only report the Q_statistics
num_original_run = numel( RaRd_original100Run );
% diversity_measure = zeros(num_original_run, num_original_run, result_dim );
diversity_measure = [];
Normalized_count =  0;
for i = 1 : num_original_run
    for j = i + 1 : num_original_run
        Q_value =  Q_sta( RaRd_original100Run{i}, RaRd_original100Run{j} );
        
         diversity_measure = [diversity_measure  Q_value];
         Normalized_count =  Normalized_count + 1;
%         disp( ['i =' num2str(i) ', j = ' num2str(j) ]);
    end
end
Qavg = sum(  diversity_measure ) / Normalized_count ;
     Qmean = mean( diversity_measure (:) );
     Qmax = max( diversity_measure (:) );
     Qmin = min( diversity_measure (:) );
     Qstd = std( diversity_measure (:) );
     
     Q  = Qmean;
% disp( [save_file_prefix ' ,avg =' num2str( Qavg) ',  mean = ' num2str(Qmean)...
%     ',  max = ' num2str(Qmax) ',  min = ' num2str(Qmin) ',  std = ' num2str(Qstd)]);
% save([save_file_prefix '_Q_sta.mat'], 'diversity_measure');
