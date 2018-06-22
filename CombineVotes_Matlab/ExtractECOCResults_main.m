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
% ECOC_Phases_Complete = {
%                     {[2 3 4 5 7]}, ...  %MNIST done
%                     { [2 3 4 5 10 7]}, ... %'SVHN-QUICK' done
%                     {[2 3 4 5 7]} ,... %'CIFAR10-FULL'
%                      {[2 3 4 5 7 10]} ,... %'CIFAR10-QUICK'
%                      {[2, 3, 4,5, 25,33,50, 60,75,80,90,95]} ,... %'CIFAR100-NIN'
%                        {[2, 3, 4,5, 25,33,50, 60,75,80,90,95]} ,... %'CIFAR100-DenseNet'
%                         {[75  50  33  25  10   5   4   3  2]}, ...  %'CIFAR100-QUICK'
%                          {[102, 95, 51 , 34, 10, 5, 3, 2]} ,... %'FLOWER102-ALEXNET-FINETUNE' [2 95] 51 , 34, 10, 5 3
%                     {[102, 95, 51 , 34, 10, 5, 3, 2]} ,... %'FLOWER102-ALEXNET'
%                     {} ...  %'ILSVRC2012-NIN'
%                     };
%================================================================================== ==
%  
%================================================================================== ==
ECOC_Phases_To_Test = {
                    {[2 3 4 5 7]}, ...  %MNIST done
                    { [7]}, ... %'SVHN-QUICK' done 2 3 4 5 10 
                    {[2 3 4 5 7]} ,... %'CIFAR10-FULL'
                     {[5]} ,... %'CIFAR10-QUICK' 2 10
                     {[2]} ,... %'CIFAR100-NIN' 2, 3, 25,33,50,75,95
                        {[95 50 33 25 5   4   3  2]}, ...  %'CIFAR100-QUICK' 75    10  50  33  25 5   4   3  2
                         {[2, 3,5, 25,33,50, 60,75,80,90,95]} ,... %'CIFAR100-DenseNet'
                         {[ 95, 5, 3, 2]} ,... %'FLOWER102-ALEXNET-Scratch'  51 , 34, 10, 102,
                    {[95 2]} ,... %'FLOWER102-NIN-finetune' 51 , 34, 10, 5, 3, 102,  95,
                    {} ...  %'ILSVRC2012-NIN'
                    };
                
                
Ensemble_Learning_Method_Names = {'RI','RI_RETRAIN','Bagging', 'AdaBoosting', ...
    'ECOC2','N-aryECOC', 'HV', 'SnapshotEnsemble'}'; %

 % DATASET ={ 'MNIST','SVHN-QUICK','CIFAR10-FULL','CIFAR10-QUICK', ... %4
%    'CIFAR100-NIN', 'CIFAR100-QUICK', 'CIFAR100-DENSENET', ... %3
%    'FLOWER102-ALEXNET-SCRATCH', 'FLOWER102-NIN-FINETUNE',... %3
%     'ILSVRC2012-NIN' }; %2 %' 'CIFAR100-DENSENET','FLOWER102-ALEXNET-SCRATCH','FLOWER102-NIN-FINETUNE',
% DNNToTest = { 'MNIST','SVHN-QUICK','CIFAR10-QUICK', ... %4
%    'CIFAR100-NIN', 'CIFAR100-QUICK', 'CIFAR100-DENSENET', ... %3
%    'FLOWER102-ALEXNET-SCRATCH',... %3}; %try to only use one DNN each time, otherwise, it will be very complecate
%     'ILSVRC2012-NIN' };
DNNToTest = { 'CIFAR100-QUICK'}; % 'CIFAR100-NIN',
results = []; 
%1, BA, 2 std(BA), 3 EA, 4 OA, 5 Q, 6 disagreementmeasure
% extract_col = [1:end];
for i = 1 : numel(DNNToTest)
    result_current_DNN = [];

    DNN_ID = getDNNIDByName( DNN_MODELS, DNNToTest{i} );
    disp(['Dataset = ' DNN_MODELS{DNN_ID}.DNN]);
    totoal_num_phase = DNN_MODELS{DNN_ID}.TOTAL_NUM_PHASE;

    
    ECOC_phases_complete = DNN_MODELS{DNN_ID}.ECOC_PHASES; %2 , 3 ,4 ,5 7
    ECOC_Phases_Test_Now = ECOC_Phases_To_Test{DNN_ID}{1};
    for test_phase_id = 1 : length(ECOC_Phases_Test_Now)
        ECOC_phase_to_predict = ECOC_Phases_Test_Now(test_phase_id);
        disp(['ECOC phase = ' num2str(ECOC_phase_to_predict)]);   
        Ensemble_Learning_Method_Name = ['ECOC' num2str(ECOC_phase_to_predict) ];
        
        
        experiment_flag = Ensemble_Learning_Method_Name;
        
        global_save_file_prefix = [DIR_PATHS.Results_DIR '/' ...
        DNN_MODELS{DNN_ID}.DNN '/' DIR_PATHS.BASELINE_TEST_DIR '/' ...
        experiment_flag  '_' ...
        num2str(totoal_num_phase) ];
    

        ensemble_accuracy_diversity_file_name = [global_save_file_prefix '_paper_plus_diversity.txt'];
    
        if exist(ensemble_accuracy_diversity_file_name)
            data_tmp = load(ensemble_accuracy_diversity_file_name);
             result_current_DNN = [result_current_DNN; ECOC_phase_to_predict data_tmp]; %(extract_col)
%         else
%             result_current_DNN = [result_current_DNN 0]; %if the file do not exist, just fill in a '0'.
        end   
    end
    results = [results; result_current_DNN];
end

results = [ results Other_accu];

disp('---------------------------------------------------------------------');
disp(results) %show the results

% Note that if I want to extract the results of multiple methods,
% I should make another separate script
