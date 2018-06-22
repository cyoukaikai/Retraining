%now we just report the Q_statistics, later, we can calculate the
%Disagreement measure, F measure, adn ytmy two divesity measure

%input : pred_phases, transferred_truth, both are two dimensional matrix.
    % number_image by number_phase
function  Qavg = QMeasureEncodingFromTransferredTruth_A( pred_phases, transferred_truth)
% accu_map_back = zeros(1,2);
% Q = zeros(1,3);

%===================================================================
%only this sentence is different from QMeasure_A
True_or_False_Flages  =  ( pred_phases == transferred_truth );
%===================================================================

num_model = size(pred_phases,2 );
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
    

% 
% 
% 
% 
% 
% total_num_phase_ECOC = size( ECOC_N_preds, 2); %number of predictions of ECOC Phases 
% 
% % disp([save_file_prefix ' calculate the Q measure ===================']);
% 
% 
% %===================ECOC_N
% RaRd_ECOCN_original = cell( total_num_phase_ECOC,1 );
% for i = 1 : total_num_phase_ECOC
%         R1_inds =  RaRd_analysis_ECOC( ground_truth, ...
%             ECOC_N_preds(:,i), group_configures{i} );
%          RaRd_ECOCN_original{i} =  R1_inds;
% end
% %save([save_file_prefix '_RaRd_ECOCN_original.mat'], 'RaRd_ECOCN_original');
% 
% Q = Q_statistics(RaRd_ECOCN_original); 
% % disp([ '    Q_statistics for ECOCN_original done ... ']);
% 
% 
% % clear RaRd_ECOCN_original
% % 
% % %===================ECOC_N
% % total_num_phase_ECOC = size(pred_phases,2);
% % RaRd_ECOCN_original = cell( total_num_phase_ECOC ,1);
% % for i = 1 : total_num_phase_ECOC
% %    
% %         R1_inds =  RaRd_analysis_ECOC( ground_truth, ...
% %             pred_phases(:,i), group_configures{i} );
% %          RaRd_ECOCN_original{i} =  R1_inds;
% % %         disp( ['i =' num2str(i) ]);
% % end
% % %save([save_file_prefix '_RaRd_ECOCN_original_mapped_back.mat'], 'RaRd_ECOCN_original');
% % 
% % Q(2) = Q_statistics(RaRd_ECOCN_original, [save_file_prefix '_ECOCN']); 
% % disp([ '    Q_statistics for original mapped-back ECOCN done ... ']);



