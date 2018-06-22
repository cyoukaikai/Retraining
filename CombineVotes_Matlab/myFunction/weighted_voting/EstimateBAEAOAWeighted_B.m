
%input: Ensemble_Results_Setting 
%setting for estimating the ensemble accuracy, the results averaged by 10
%times run or only 1 time run, the result of n1 / n phases (where n1 = 1,
%2, 3 , ... n or n1 = n only).
%    Ensemble_Results_Setting.Random_Num_Phase = 1; %default setting is 1
%    Ensemble_Results_Setting.Report_Last_OR_All = 'last'; %'all' or 'last' or with some interval.
%default report only the last, do report all for N-ary ECOC or future predicting the Ensemble accuracy
function [ensemble_performance,final_pred] = EstimateBAEAOAWeighted_B(pred_phases, weights, ground_truth, Ensemble_Results_Setting)


truth = ground_truth;
num_image = length(truth);
total_number_phase = size(pred_phases,2);

random_num_phase = Ensemble_Results_Setting.Random_Num_Phase;


accu_original_run = zeros( total_number_phase, 1);
for i = 1 : total_number_phase
    accu_original_run(i) = sum(truth  == pred_phases(:,i) ) / num_image * 100;
    disp([  num2str(i) ' ' num2str( accu_original_run(i) ) ]);
end
%report the mean accuracy and std for each N number of single phases 
mean_accuracy = zeros( total_number_phase, 2);
for k = 1 : total_number_phase
        random_order = randperm( total_number_phase );
        accu = accu_original_run ( random_order(1:k ) );
        mean_accuracy(k,:) = [mean( accu ), std(accu)];
end


ensmeble_accuracy = zeros( total_number_phase, random_num_phase);
oracle_accuracy = zeros( total_number_phase, random_num_phase);
for k = 1 : random_num_phase
%     tic
%     disp([ 'random_num_phase = ' num2str(k) ' ------------ ']);
    [ensmeble_accuracy(:,k), oracle_accuracy(:,k), final_pred] ...
        = MakeEnsembleOriginal100RunWeighted_A(pred_phases, weights, truth, Ensemble_Results_Setting.Report_Last_OR_All);
%     toc
end


ensemble_performance = zeros( total_number_phase, 4);
ensemble_performance(:,1) = mean(ensmeble_accuracy,2);
ensemble_performance(:,2) =std(ensmeble_accuracy,0,2);  
ensemble_performance(:,3) = mean(oracle_accuracy,2); 
ensemble_performance(:,4) = std(oracle_accuracy,0,2); 
ensemble_performance  = [mean_accuracy ensemble_performance accu_original_run];
