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

%suppose the ip2, ip1, conv3 are the last, the last but one and the last
%but two layer, respectively.
%two typical learning rates, 1 and 10 involved.
% Ensemble_Learning_Method_Names = {'ip2-1','ip2-2.5','ip2-5','ip2-7.5','ip2-10', ...
%     'ip1-1','ip1-10', 'ip1-1-ip2-1','ip1-10-ip2-10','ip1-1-ip2-1','ip1-10-ip2-10'...
%     'conv3-1-ip1-1-ip2-1','conv3-10-ip1-10-ip2-10'}'; %
Ensemble_Learning_Method_Names = {'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10', ...
    'ip1_1','ip1_10', 'ip1_1_ip2_1','ip1_10_ip2_10','ip1_1_ip2_1','ip1_10_ip2_10',...
    'ip1_1_ip2_10','ip1_10_ip2_1'}; %,'conv3_1_ip1_1_ip2_1','conv3_10_ip1_10_ip2_10'
Ensemble_Learning_Method_Retrain_Prefix = 'original_100run';
EXPERIMENTS_FLAG = 'IP1IP2Test';
IP1IP2Test_Num_Phases = [60, 100, 100, 100, 10, 60, 5, 10, 10, 5 ];
IP1IP2Test_Num_Retrain = [4, 8,  8,  8, 8, 8, 1,  1,  3, 1];

%'SVHN-QUICK' 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10', ...
%                'ip1_1','ip1_10', 'ip1_1_ip2_1','ip1_10_ip2_10','ip1_1_ip2_1','ip1_10_ip2_10'...
%             'ip1_1_ip2_10','ip1_10_ip2_1', 'conv3_1_ip1_1_ip2_1'  
%'CIFAR100-QUICK', 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10',...
%                'ip1_1','ip1_10', 'ip1_1_ip2_1','ip1_10_ip2_10','ip1_1_ip2_1','ip1_10_ip2_10'...
%             'ip1_1_ip2_10','ip1_10_ip2_1'

% %effect of different b values
SaveFlag = '';
% Directory = { 
%             {'ip2_0.1','ip2_0.5', 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10','ip2_25','ip2_50'}, ...  %MNIST done 2 3 4 5 7
%              {  'ip2_0.1','ip2_0.5', 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10','ip2_25','ip2_50'}, ... 'SVHN-QUICK' 
%                     {} ,... %'CIFAR10-FULL'
%                      {'ip2_0.1','ip2_0.5', 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10','ip2_25','ip2_50'} ,... %'CIFAR10-QUICK'  
%                      {'ccp6_0.1','ccp6_0.5', 'ccp6_1','ccp6_2.5','ccp6_5', 'ccp6_7.5','ccp6_10','ccp6_25','ccp6_50' ... %
%                     } ,... %'CIFAR100-NIN'
%                         {'ip2_0.1','ip2_0.5', 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10','ip2_25','ip2_50'}, ...  %'CIFAR100-QUICK' 75    10  50  33  25 5   4   3  2
%                          {'ip1_0.1','ip1_0.5','ip1_1','ip1_2.5','ip1_5','ip1_7.5','ip1_10','ip1_25','ip1_50' } ,... %'CIFAR100-DenseNet'
%                          {'fc8_0.1','fc8_0.5','fc8_1','fc8_2.5','fc8_5','fc8_7.5','fc8_10','fc8_25','fc8_50'} ,... %'FLOWER102-ALEXNET-Scratch' ,'fc8_7.5'
%                     {} ,... %'FLOWER102-NIN-finetune'
%                     {'ccp8-0.1','ccp8-0.5','ccp8-1','ccp8-2.5','ccp8-5','ccp8-7.5','ccp8-10', 'ccp8-25','ccp8-50'} ...  %'ILSVRC2012-NIN'
%                     };
% %

% replacing more layers.
SaveFlag = '-more-layers';
Directory = { 
            {'ip2_0.1','ip2_0.5', 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10','ip2_25','ip2_50'}, ...  %MNIST done 2 3 4 5 7
             { 'ip2_1','ip1_1_ip2_1','conv3_1_ip1_1_ip2_1', 'ip2_2.5','ip1_2.5_ip2_2.5','conv3_2.5_ip1_2.5_ip2_2.5','ip2_10','ip1_10_ip2_10','conv3_10_ip1_10_ip2_10'}, ... 'SVHN-QUICK' 
                    {} ,... %'CIFAR10-FULL'
                     {'ip2_0.1','ip2_0.5', 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10','ip2_25','ip2_50'} ,... %'CIFAR10-QUICK'  
                     {'ccp6_0.1','ccp6_0.5', 'ccp6_1','ccp6_2.5','ccp6_5', 'ccp6_7.5','ccp6_10','ccp6_25','ccp6_50' ... %
                    } ,... %'CIFAR100-NIN'
                        {'ip2_0.1','ip2_0.5', 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10','ip2_25','ip2_50'}, ...  %'CIFAR100-QUICK' 75    10  50  33  25 5   4   3  2
                         {'ip1_1','conv39-1-ip1-1', 'conv38-1-conv39-1-ip1-1','ip1_2.5','conv39-2.5-ip1-2.5','conv38-2.5-conv39-2.5-ip1-2.5','ip1_10','conv39-10-ip1-10','conv38-10-conv39-10-ip1-10' } ,... %'CIFAR100-DenseNet'
                         {'fc8_0.1','fc8_0.5','fc8_1','fc8_2.5','fc8_5','fc8_7.5','fc8_10','fc8_25','fc8_50'} ,... %'FLOWER102-ALEXNET-Scratch' ,'fc8_7.5'
                    {} ,... %'FLOWER102-NIN-finetune'
                    {'ccp8-1','ccp7-1-ccp8-1','conv4-1-ccp7-1-ccp8-1','ccp8-2.5','ccp7-2.5-ccp8-2.5','conv4-2.5-ccp7-2.5-ccp8-2.5','ccp8-10','ccp7-10-ccp8-10','conv4-10-ccp7-10-ccp8-10'} ...  %'ILSVRC2012-NIN'
                    };
%                 
%=============================================================
% setting of my usage
%============================================================


 % DATASET ={ 'MNIST','SVHN-QUICK','CIFAR10-FULL','CIFAR10-QUICK', ... %4
%    'CIFAR100-NIN', 'CIFAR100-QUICK', 'CIFAR100-DENSENET', ... %3
%    'FLOWER102-ALEXNET-SCRATCH', 'FLOWER102-NIN-FINETUNE',... %3
%     'ILSVRC2012-NIN' }; %2 %' 'MNIST','SVHN-QUICK','CIFAR100-DENSENET','FLOWER102-ALEXNET-SCRATCH','FLOWER102-NIN-FINETUNE',
% DNNToTest = {'MNIST','SVHN-QUICK','CIFAR10-QUICK','CIFAR100-NIN','CIFAR100-QUICK','CIFAR100-DENSENET','FLOWER102-ALEXNET-SCRATCH','ILSVRC2012-NIN'}; %try to only use one DNN each time, otherwise, it will be very complecate
DNNToTest = {'SVHN-QUICK','CIFAR100-DENSENET','ILSVRC2012-NIN'};
%============================================================='CIFAR100-QUICK',
% below sections do not need to modify
%=============================================================
% for one ensemble learning method, extract the result into one line (for 
% one DNN) or multiple lines (for multiple DNNs). 


results_EA = [];
results_BA = [];
results_Q = [];
for i = 1 : numel(DNNToTest)


    DNN_ID = getDNNIDByName( DNN_MODELS, DNNToTest{i} );
    disp(['Dataset = ' DNN_MODELS{DNN_ID}.DNN]);

    totoal_num_phase = IP1IP2Test_Num_Phases(DNN_ID);

    % ===============section need use to specify
    retrain_ids = 1 : IP1IP2Test_Num_Retrain(DNN_ID);
    iterations = [ ones(1,IP1IP2Test_Num_Retrain(DNN_ID) ) * DNN_MODELS{DNN_ID}.RETRAIN_MAX_NUM_ITERATION];
    
%    %for instance, useage
%    test_retrain_id = 3; %only get the result of retrain3
%    retrain_ids = retrain_ids( test_retrain_id + 1); %0-index to 1-index
%    iterations = iterations( test_retrain_id + 1);
    % =======================================
    test_ip1_ip2_names = Directory{DNN_ID};
    
    DNN_results = [];
    for j = 1 : numel(test_ip1_ip2_names) 
        ip1_ip2_test = test_ip1_ip2_names{j};
        
        for k = length(retrain_ids): length(retrain_ids)
            %generate the prediction file names, real label file.
            %all the predictions are in only one directory, the real label is in
            %the same directory
            retrain_id = retrain_ids( k );
            iter = iterations(k);

           
 
            ResultingFile.dataset_dir =  DNN_MODELS{DNN_ID}.DNN; %second root direcotry
            ResultingFile.experiment_flag =  EXPERIMENTS_FLAG; %third root direcotry
            ResultingFile.totoal_num_phase =  totoal_num_phase;
            ResultingFile.save_file_prefix = [ip1_ip2_test '_RETRAIN' num2str(retrain_id) ];
            ResultingFile.save_file_suffix = 'run_results_all_prediction.mat';

          ResultingFile.root_dir = DIR_PATHS.Results_DIR; %first root direcotry, save to "results/"
          
          
            global_save_file_prefix = [ResultingFile.root_dir  '/' ...
                ResultingFile.dataset_dir '/' ResultingFile.experiment_flag '/' ...
                ResultingFile.save_file_prefix  '_' ...
                num2str(ResultingFile.totoal_num_phase) ];

    
           
 
                ensemble_accuracy_diversity_file_name = [global_save_file_prefix '_paper_plus_diversity.txt'];
            
%             if ~(SimulateEAFlag) % normal use, only estimate the EA of all the phases, and the relevant Q and Dis
%                 current_results  = MakeEnsembleLearningNocoding_B(pred_phases, ground_truth, ResultingFile, Ensemble_Results_Setting);
%             else %simulate EA use, estimate the EA of N_m phases where N_m > 1 and the relevant Q and Dis
% 
%                 current_results  = MakeEnsembleLearningNocoding_B_SimulateEA(pred_phases, ground_truth, ResultingFile); %as the we need to 
%             end
            if exist(ensemble_accuracy_diversity_file_name, 'file')

                current_results = load(ensemble_accuracy_diversity_file_name);
            else
                current_results = zeros(1,6);
            end
            DNN_results = [DNN_results;  current_results];
            
        end 
    end

    results_EA = [results_EA DNN_results(:,3)]; %EA is the 3rd column
    results_BA = [results_BA DNN_results(:,1)]; %EA is the 3rd column
    results_Q = [results_Q DNN_results(:,5)]; %EA is the 3rd column
 
    
end

%two decimal
% results = [results;  current_results];
file_name = ['results/IP1-IP2-TEST-RESULTS' SaveFlag ];
disp('---------------------------------------------------------------------EA');
disp(results_EA) %show the results
 dlmwrite([file_name '-EA.txt'],results_EA,'delimiter',' ','precision','%.2f');



disp('---------------------------------------------------------------------BA');
disp(results_BA) %show the results
 dlmwrite([file_name '-BA.txt'],results_BA,'delimiter',' ','precision','%.2f');
disp('---------------------------------------------------------------------Q');
disp(results_Q) %show the results

 dlmwrite([file_name '-Q.txt'],results_Q,'delimiter',' ','precision','%.3f');

% Note that if I want to extract the results of multiple methods,
% I should make another separate script
