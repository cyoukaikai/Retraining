function [ensemble_performance, final_pred] = EstimateBAEAOAEncoding_B(pred_phases, EncodingInformation, ground_truth, Ensemble_Results_Setting)

[num_image,total_num_phase] = size(pred_phases);

random_num_phase = Ensemble_Results_Setting.Random_Num_Phase;
codewords =  EncodingInformation.codewords;
transferred_truth = EncodingInformation.transferred_truth;
 
%===============================================
% check the single phase accuracy
%===============================================
accu_single_phases = zeros(total_num_phase, 1);
for k = 1 : total_num_phase
   [accu_single_phases(k)] = sum(transferred_truth(:,k)  == pred_phases(:,k) ) / num_image * 100;
   disp([  num2str(k) ' ' num2str(  accu_single_phases(k) ) ]);
% % % 	printf ("%d %4.2f\n", k,  accu_single_phases(k) );
end


%===============================================================
%section 2, report the mean accuracy and std for each N number of single phases
%===============================================================

mean_accuracy = zeros( total_num_phase, 2);
for k = 1 : total_num_phase
        random_order = randperm( total_num_phase );
        accu = accu_single_phases ( random_order(1:k ) );
        mean_accuracy(k,:) = [mean( accu ), std(accu)];
end

%===============================================================
%section 3, ensemble accuracy
%===============================================================


ensmeble_accuracy = zeros( total_num_phase, random_num_phase);
oracle_accuracy = zeros( total_num_phase, random_num_phase);
for k = 1 : random_num_phase
%     tic
%     disp([ 'random_num_phase = ' num2str(k) ' ------------ ']);
    [ensmeble_accuracy(:,k), oracle_accuracy(:,k), final_pred] ...
        = MakeEnsembleEncoding100Run_A(pred_phases, codewords, ground_truth, Ensemble_Results_Setting.Report_Last_OR_All);
%     toc
end
ensemble_performance = MeanStdEnsemblePerformance_A(ensmeble_accuracy, oracle_accuracy);
ensemble_performance  = [mean_accuracy ensemble_performance accu_single_phases];
