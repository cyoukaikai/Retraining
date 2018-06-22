function    [ensmeble_accuracy, oracle_accuracy, ensmeble_pred] ...
        = MakeEnsembleEncoding100Run_A(pred_phases, codewords,...
        ground_truth, detail_flag)
    

total_num_phase = size(pred_phases,2);
%===============================================================
%section 3, cal the ensemble accuracy, oracle accuracy of the ensemble, randomly
%run 10 times, and average over the 10 run.
%===============================================================  
StrNumberPhase = total_num_phase; %default, we only care the EA of all predicted phases.
% Interval = 1;  Interval :
 if strcmp(detail_flag,'all') % Ensemble_Results_Setting.Report_Last_OR_All = 'last'; %'all' or 'last' or with some interval.
     StrNumberPhase = 1;
 end


ensmeble_pred = zeros(total_num_phase,1);  %only save the prediction of all the phases
ensmeble_accuracy = zeros(total_num_phase,1);
oracle_accuracy = zeros(total_num_phase,1);

disp('final ensemble accuracy:');    
for k = StrNumberPhase:  total_num_phase
    random_order = randperm( total_num_phase );
    %     random_order = 1: total_num_phase; %only for debug use
    preds =  pred_phases(:,random_order(1:k) ); %randomly select the predictions of k models
    % for k == 1, we can not use the minimum_hamming_dist, because the minimum dist 
     %[final_pred, ensemble_result(:,:,k) ] = minority_voting( preds ,orderd_class_labels);

    codewords_tmp = codewords(:,random_order(1:k) );  % generate the codewords
     [ensmeble_accuracy(k), oracle_accuracy(k), ensmeble_pred] = ...
       MakeEnsembleBasedOnHammingDistanceEncoding_A(preds, codewords_tmp , ground_truth); %make_ensemble_hamming_distance
   
    disp( [ num2str(k) ' ' num2str(ensmeble_accuracy(k )) ' ' num2str(oracle_accuracy(k) ) ]);
end
    
    
    
    
    
    





