% this script is used to make predictions for ensemble learning methods
% that do not use ECOC or N-ary ECOC based encoding.

%this script support to estimate the evalution measures (EA, BA, Q, Dis) of
%multiple DNNs, but not support doing that for multiple methods at a time,
%because the way of loading data is different
%=============================================================
%add_funtion load global configuration file
%=============================================================
clc; clear; close all;
add_function

global_configure


Training_Accu = [99.86 92.79 87.24 90.40 64.80 100.00 99.82 77.94]';
Other_accu = zeros(8,1);
Other_accu(4) = 66.51; Other_accu(5) = 50.32; 
%=============================================================
% setting of my usage
%============================================================
Ensemble_Learning_Method_Names = {'RI','LongIters','RI_RETRAIN','Bagging', 'AdaBoost', ...
    'ECOC2','N-aryECOC', 'HV', 'SnapshotEnsemble'}'; %

 % DATASET ={ 'MNIST','SVHN-QUICK','CIFAR10-FULL','CIFAR10-QUICK', ... %4
%    'CIFAR100-NIN', 'CIFAR100-QUICK', 'CIFAR100-DENSENET', ... %3
%    'FLOWER102-ALEXNET-SCRATCH', 'FLOWER102-NIN-FINETUNE',... %3
%     'ILSVRC2012-NIN' }; %2 %' 'CIFAR100-DENSENET','FLOWER102-ALEXNET-SCRATCH','FLOWER102-NIN-FINETUNE',
DNNToTest = { 'MNIST','SVHN-QUICK','CIFAR10-QUICK', ... %4
   'CIFAR100-NIN', 'CIFAR100-QUICK', 'CIFAR100-DENSENET', ... %3
   'FLOWER102-ALEXNET-SCRATCH',... %3}; %try to only use one DNN each time, otherwise, it will be very complecate
    'ILSVRC2012-NIN' };

results = []; 
%1, BA, 2 std(BA), 3 EA, 4 OA, 5 Q, 6 disagreementmeasure
extract_col = 3;
for i = 1 : numel(DNNToTest)
    result_current_DNN = [];

    DNN_ID = getDNNIDByName( DNN_MODELS, DNNToTest{i} );
    disp(['Dataset = ' DNN_MODELS{DNN_ID}.DNN]);
    totoal_num_phase = DNN_MODELS{DNN_ID}.TOTAL_NUM_PHASE;

    retrain_id = DNN_MODELS{DNN_ID}.NUM_RETRAIN;
    best_n = DNN_MODELS{DNN_ID}.N_BEST;
    for j = 1 : numel (Ensemble_Learning_Method_Names)
        experiment_flag = Ensemble_Learning_Method_Names{j};
        
        if strcmp(experiment_flag, 'RI_RETRAIN') 
            experiment_flag = ['RI_RETRAIN' num2str(retrain_id) ];
        elseif strcmp(experiment_flag, 'N-aryECOC') 
            experiment_flag = ['ECOC' num2str(best_n) ];    
        end
                
        global_save_file_prefix = [DIR_PATHS.Results_DIR '/' ...
        DNN_MODELS{DNN_ID}.DNN '/' DIR_PATHS.BASELINE_TEST_DIR '/' ...
        experiment_flag  '_' ...
        num2str(totoal_num_phase) ];
    

        ensemble_accuracy_diversity_file_name = [global_save_file_prefix '_paper_plus_diversity.txt'];
    
        if exist(ensemble_accuracy_diversity_file_name,'file')
            data_tmp = load(ensemble_accuracy_diversity_file_name);
            
            if strcmp(experiment_flag, 'RI') 
                result_current_DNN = [result_current_DNN data_tmp([1 extract_col])];
            else
                
                result_current_DNN = [result_current_DNN data_tmp(extract_col)];
            end
        else
            result_current_DNN = [result_current_DNN 0]; %if the file do not exist, just fill in a '0'.
        end   
    end
    results = [results; result_current_DNN];
end

results = [Training_Accu  results Other_accu];

disp('---------------------------------------------------------------------');
disp(results) %show the results

% Note that if I want to extract the results of multiple methods,
% I should make another separate script
