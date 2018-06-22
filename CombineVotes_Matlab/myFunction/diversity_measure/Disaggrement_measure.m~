function  [Disagree_value_avg,disagreement_matrix]= Disaggrement_measure( preds )
    diversity_measure = [];
    Normalized_count =  0;

   [num_example,  num_model ]= size(preds);
 disagreement_matrix = zeros(num_model,num_model) ;
    for i = 1 : num_model
        for j = i + 1 : num_model
            Disagree_value =  sum( preds(:,i) ~= preds(:,j) ) / num_example ;
		disagreement_matrix(i,j) = Disagree_value;
             diversity_measure = [diversity_measure  Disagree_value];
             Normalized_count =  Normalized_count + 1;
    %         disp( ['i =' num2str(i) ', j = ' num2str(j) ]);
        end
    end
    Disagree_value_avg = sum(  diversity_measure ) / Normalized_count ;
    %      Qmean = mean( diversity_measure (:) );
    %      Qmax = max( diversity_measure (:) );
    %      Qmin = min( diversity_measure (:) );
    %      Qstd = std( diversity_measure (:) );

    %      Q  = Qmean;
    % disp( [save_file_prefix ' ,avg =' num2str( Qavg) ',  mean = ' num2str(Qmean)...
    %     ',  max = ' num2str(Qmax) ',  min = ' num2str(Qmin) ',  std = ' num2str(Qstd)]);
    % save([save_file_prefix '_Q_sta.mat'], 'diversity_measure');

end
