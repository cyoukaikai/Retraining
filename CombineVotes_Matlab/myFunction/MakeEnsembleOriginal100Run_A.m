function [accu_ensemble, accu_oracle,final_pred] = MakeEnsembleOriginal100Run_A( pred_phases, ground_truth, detail_flag)


num_image = length( ground_truth );
num_class = length( unique(ground_truth) );
num_phase = size(pred_phases,2);
orderd_class_labels = sort( unique(ground_truth) );

if length(unique(ground_truth)) < length(unique(pred_phases(:)))
    disp('File, MakeEnsembleOriginal100Run_A the number of unique predicted class labels are more than the number of unique real class labels, please check');
%     disp('To make the program runing, just comment the checking sentence,. as it does not affect the further estimation');
%     

    
    orderd_class_labels = sort( unique(pred_phases(:) ) );
    num_class = length(orderd_class_labels);
end


ensemble_result = zeros( num_image , num_class, num_phase); 
accu_ensemble = zeros( num_phase, 1);
accu_oracle = zeros( num_phase, 1);
%==================================================================
%based on the majority_voting (count the frequecy for the predictions of
%each row (majority_voting is much fast than the minimum hamming distance
%becuase too many loops in the the minimum hamming distance methods.
%==================================================================
% for k = 1 : num_phase
StrNumberPhase = num_phase; %default, we only care the EA of all predicted phases.
% Interval = 1;  Interval :
 if strcmp(detail_flag,'all') % Ensemble_Results_Setting.Report_Last_OR_All = 'last'; %'all' or 'last' or with some interval.
     StrNumberPhase = 1;
 end
 

 disp('final ensemble accuracy:');    
 for k = StrNumberPhase:  num_phase
    random_order = randperm( num_phase );
%     random_order = 1: num_phase; %only for debug use
    preds =  pred_phases(:,random_order(1:k) ); %randomly select the predictions of k models
    % for k == 1, we can not use the minimum_hamming_dist, because the minimum dist 
     %[final_pred, ensemble_result(:,:,k) ] = minority_voting( preds ,orderd_class_labels);
     [final_pred, ensemble_result(:,:,k) ] = MajorityVoting_A( preds ,orderd_class_labels);
%     for i = 1 : num_image
%         label_pred = pred_phases(i,k) + 1; 
%         ensemble_result(i,label_pred, k:end  ) = ...
%             ensemble_result(i,label_pred, k:end) +  1;
%     end
    accu_ensemble(k) = sum(ground_truth ==  final_pred)/ length( ground_truth ) * 100;  %chagne to percent%.
%     accu_ensemble(k) = cal_ensemble_accu( ensemble_result(:,:,k), ground_truth );
    accu_oracle(k) = cal_oracle_accu( ensemble_result(:,:,k), ground_truth );   
    disp( [ num2str(k) ' ' num2str( accu_ensemble(k)  )]);
 end

%  dlmwrite('cifar10-quick-prediction-frequency.txt',ensemble_result(:,:,end),'delimiter',' ');

% voting_result = ceil( ensemble_result(:,:,k) );
% %  vote_record_file = load('results/CIFAR10-QUICK/RI_error_anasy_pred.txt');
% save_file_prefix = 'bottom_8_vote';
%  file_name_prediction_top_K = ['results/CIFAR10-QUICK/' save_file_prefix '_' num2str(num_phase) '_pred.txt']
%  dlmwrite(file_name_prediction_top_K ,voting_result,'delimiter',' ');
% % 
 
 
% 
% %==================================================================
% %based on minimum hamming distance
% %=================================================
% for k = 1 : num_phase
%     random_order = randperm( num_phase );
% % % % %     random_order = 1: num_phase; %only for debugging use
%     preds =  pred_phases(:,random_order(1:k) ); %randomly select the predictions of k models
%     codewords = [0:num_class-1]' * ones(1, k); % generate the codewords
%     [accu_ensemble(k),accu_oracle(k) ] =  ensemble_accu_oracle_based_on_hamming_dist(preds, codewords, ground_truth ); 
%     disp( [ num2str(k) ' ' num2str( accu_ensemble(k)  )]);
% end
