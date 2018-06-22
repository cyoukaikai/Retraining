
%pred_phases are 0-index, group_configure is 0-index, ground_truth,
%0-index.
function  [Disagree_value_avg, disagreement_matrix] = DisaggrementMeasureEncodingFromGroupConfigure_A(pred_phases, group_configure, ground_truth)
 [num_example,  num_model ]= size(pred_phases);
%map the ECOC prediction to RI labels 
classes = unique( ground_truth );


%for each pahse, map it back to the RI predictions where the classes
%predicted in ECOC mare marked 1, otherwise, marked 0.

% disp('fast implementation result');
% tic
predictions_RI = zeros(num_example, length(classes), num_model); 
for i = 1 : num_model
     phase_configure = group_configure{i};
     predictions_RI(:, :, i) = TransferTruthEncoding2Nocoding_A(phase_configure,  pred_phases(:, i) );
end
% toc
% ==================================debug
% disp('slow implementation result');
% tic
% %slow version, now give up this version
% predictions_RI_older_version = zeros(num_example, length(classes), num_model);
% for i = 1 : num_model
%      phase_configure = group_configure{i};
%      
%       for j = 1 : num_example %transfer the prediction of this example to an array with only 1 or 0 values.
%          pred_tmp = zeros( 1, length( classes ) );
%          predicted_label_ECOC = pred_phases(j, i);
%          predicted_labels_RI = phase_configure{ predicted_label_ECOC + 1};
%          pred_tmp( predicted_labels_RI + 1 ) = 1;
%          predictions_RI_older_version(j, :, i) = pred_tmp;
%       end
% end
% toc
% 
% count_unequal_elements = sum( predictions_RI(:) ~= predictions_RI_older_version(:) )
%debug results - ------------------------------2017-12-19
% fast implementation result
% Elapsed time is 1.740476 seconds.
% slow implementation result
% Elapsed time is 22.173598 seconds.
% count_unequal_elements =
% 
%      0
% ==================================debug over



%average the Disagree_value
    diversity_measure = [];
    
    disagreement_matrix = zeros(num_model,num_model) ;
    Normalized_count =  0;
  
    for i = 1 : num_model
        for j = i + 1 : num_model
            Disagree_value =  sum( sum( predictions_RI(:,:, i) ~= predictions_RI(:,:, j) ) ) / ( num_example * length(classes) ) ;
            disagreement_matrix(i,j) = Disagree_value;
            
             diversity_measure = [diversity_measure  Disagree_value];
             Normalized_count =  Normalized_count + 1;
    %         disp( ['i =' num2str(i) ', j = ' num2str(j) ]);
        end
    end
    Disagree_value_avg = sum(  diversity_measure ) / Normalized_count ;


end
