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
IP1IP2Test_Num_Retrain = [4, 8,  8,  8, 8, 8, 1,  3,  3, 1];

%%MNIST 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10', ...
%                'ip1_1','ip1_10', 'ip1_1_ip2_1','ip1_10_ip2_10','ip1_1_ip2_1','ip1_10_ip2_10'...
%             'ip1_1_ip2_10','ip1_10_ip2_1', 'conv2_1_ip1_1_ip2_1' 
%'SVHN-QUICK' 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10', ...
%                'ip1_1','ip1_10', 'ip1_1_ip2_1','ip1_10_ip2_10','ip1_1_ip2_1','ip1_10_ip2_10'...
%             'ip1_1_ip2_10','ip1_10_ip2_1', 'conv3_1_ip1_1_ip2_1'  
%'CIFAR100-QUICK', 'ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10',...
%                'ip1_1','ip1_10', 'ip1_1_ip2_1','ip1_10_ip2_10','ip1_1_ip2_1','ip1_10_ip2_10'...
%             'ip1_1_ip2_10','ip1_10_ip2_1'
% 'FLOWER102-ALEXNET-Scratch' 'fc8_1','fc8_2.5','fc8_5','fc8_10', ...
%     'fc7_1','fc7_10', 'fc7_1_fc8_1','fc7_10_fc8_10','fc7_1_fc8_1','fc7_10_fc8_10',...
%     'fc7_1_fc8_10','fc7_10_fc8_1'
% CIFAR100-NIN 'ccp6_1','ccp6_2.5','ccp6_5', 'ccp6_7.5','ccp6_10', ... %
%                     'ccp5_1','ccp5_10', 'ccp5_1_ccp6_1' 'ccp5_10_ccp6_10',... % 
%                     'ccp5_1_ccp6_10', 'ccp5_10_ccp6_1','ccp4_1_ccp5_1_ccp6_1'
Directory = { 
            {'ip1_2.5_ip2_2.5','conv2_1_ip1_1_ip2_1','conv2_2.5_ip1_2.5_ip2_2.5','conv2_10_ip1_10_ip2_10'  }, ...  %MNIST done 2 3 4 5 7
             { 'ip1_2.5_ip2_2.5','conv3_1_ip1_1_ip2_1','conv3_2.5_ip1_2.5_ip2_2.5','conv3_10_ip1_10_ip2_10' }, ... 'SVHN-QUICK' 'ip2_0.1','ip2_0.5','ip2_25','ip2_50'
                    {} ,... %'CIFAR10-FULL'
                     {'ip1_2.5_ip2_2.5', 'conv3_1_ip1_1_ip2_1', 'conv3_2.5_ip1_2.5_ip2_2.5', 'conv3_10_ip1_10_ip2_10'} ,... %'CIFAR10-QUICK'  'ip2_0.1','ip2_0.5','ip2_25','ip2_50'
                     {'ccp5_2.5_ccp6_2.5','conv3_1_ccp5_1_ccp6_1','conv3_2.5_ccp5_2.5_ccp6_2.5','conv3_10_ccp5_10_ccp6_10' } ,... %'CIFAR100-NIN' 'ccp6_10'
                        { 'ip1_2.5_ip2_2.5', 'conv3_1_ip1_1_ip2_1', 'conv3_2.5_ip1_2.5_ip2_2.5', 'conv3_10_ip1_10_ip2_10'}, ...  %'CIFAR100-QUICK'  'ip2_0.1','ip2_0.5','ip2_1','ip2_2.5','ip2_5','ip2_7.5','ip2_10','ip2_25','ip2_50'
                         {'conv39-1-ip1-1','conv39-2.5-ip1-2.5','conv39-10-ip1-10', 'conv38-1-conv39-1-ip1-1','conv38-2.5-conv39-2.5-ip1-2.5','conv38-10-conv39-10-ip1-10'} ,... %'CIFAR100-DenseNet' 'ip1_0.1','ip1_0.5','ip1_1','ip1_2.5','ip1_5','ip1_7.5','ip1_10','ip1_25','ip1_50' 
                         {'fc7-2.5-fc8-2.5','fc6-1-fc7-1-fc8-1','fc6-2.5-fc7-2.5-fc8-2.5','fc6-10-fc7-10-fc8-10'} ,... %'FLOWER102-ALEXNET-Scratch' ,'fc8_7.5'
                    {} ,... %'FLOWER102-NIN-finetune'
                    {'ccp7-1-ccp8-1','ccp7-10-ccp8-10'} ...  %'ILSVRC2012-NIN''ccp8-0.1','ccp8-0.5','ccp8-1','ccp8-2.5','ccp8-5','ccp8-7.5','ccp8-10', 'ccp8-25','ccp8-50''ccp7-2.5-ccp8-2.5','conv4-1-ccp7-1-ccp8-1','conv4-2.5-ccp7-2.5-ccp8-2.5','conv4-10-ccp7-10-ccp8-10'
                    };
                %svhn

% 

                
%=============================================================
% setting of my usage
%============================================================


 % DATASET ={ 'MNIST','SVHN-QUICK','CIFAR10-FULL','CIFAR10-QUICK', ... %4
%    'CIFAR100-NIN', 'CIFAR100-QUICK', 'CIFAR100-DENSENET', ... %3
%    'FLOWER102-ALEXNET-SCRATCH', 'FLOWER102-NIN-FINETUNE',... %3
%     'ILSVRC2012-NIN' }; %2 %' 'MNIST','SVHN-QUICK','CIFAR100-DENSENET','FLOWER102-ALEXNET-SCRATCH','FLOWER102-NIN-FINETUNE',
DNNToTest = {'CIFAR10-QUICK','CIFAR100-NIN'}; %try to only use one DNN each time, otherwise, it will be very complecate
%============================================================='CIFAR100-QUICK',
% below sections do not need to modify
%=============================================================
% for one ensemble learning method, extract the result into one line (for 
% one DNN) or multiple lines (for multiple DNNs). 


results = [];
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
    for j = 1 : numel(test_ip1_ip2_names) 
        ip1_ip2_test = test_ip1_ip2_names{j};
        
        for k = 1: length(retrain_ids)
            %generate the prediction file names, real label file.
            %all the predictions are in only one directory, the real label is in
            %the same directory
            retrain_id = retrain_ids( k );
            iter = iterations(k);

            single_directory_name = [ DIR_PATHS.CAFFE_Prediction_DIR '/' ...
                    DNN_MODELS{DNN_ID}.DNN '/'  EXPERIMENTS_FLAG '/' ...
                    ip1_ip2_test '/' ...
                    Ensemble_Learning_Method_Retrain_Prefix '_retrain' num2str(retrain_id) ...
                    '_' num2str(iter) '/'] 

            groung_truth_file_name = [single_directory_name 'real_label.txt'];
            prediction_file_names = cell(1,totoal_num_phase);
            for predition_id = 1 : totoal_num_phase 
                prediction_file_names{predition_id} = [single_directory_name ...
                    'prediction_' ...
                    num2str(predition_id - 1 ) '.txt'];
                    %the prediction file is 0-index, while matlab is 1-index
            end
            %load the predictions and ground truth    
            ResultingFile.root_dir = DIR_PATHS.Preprocessed_Prediction_DIR; %first root direcotry
            ResultingFile.dataset_dir =  DNN_MODELS{DNN_ID}.DNN; %second root direcotry
            ResultingFile.experiment_flag =  EXPERIMENTS_FLAG; %third root direcotry
            ResultingFile.totoal_num_phase =  totoal_num_phase;
            ResultingFile.save_file_prefix = [ip1_ip2_test '_RETRAIN' num2str(retrain_id) ];
            ResultingFile.save_file_suffix = 'run_results_all_prediction.mat';

        %     real_num_phase =size(pred_phases,2); %count the real number of phases loaded
        %     file_name_prediction = [path_preprocessed_data_dir '/' dataset_dir '/' experiment_flag '/' save_file_prefix  '_' num2str(real_num_phase) 'run_results_all_prediction.mat'];
        %     
            [pred_phases, ground_truth] = LoadSavePredictionGroundTruthNocoding_A( prediction_file_names, groung_truth_file_name, ResultingFile  );

            %=============================================================
            % section 2, make ensemble learning, report the ensemble accuracy, oracle accuracy,
            %average base model accuracy, Q statistics, disagreement measure (and so
            %on)
            %=============================================================
            %note, once the predictions and real labels are given, this section is same
            %even for different methods.
            % the format of the current_results, BA, std(BA), Q, Dis, EA, OA. 
            %make the ensemble predictions
            ResultingFile.root_dir = DIR_PATHS.Results_DIR; %first root direcotry, save to "results/"
            ResultingFile.totoal_num_phase = size(pred_phases,2); %mofify the total number phase based on the real number of phases loaded.
            
            
            if ~(SimulateEAFlag) % normal use, only estimate the EA of all the phases, and the relevant Q and Dis
                current_results  = MakeEnsembleLearningNocoding_B(pred_phases, ground_truth, ResultingFile, Ensemble_Results_Setting);
            else %simulate EA use, estimate the EA of N_m phases where N_m > 1 and the relevant Q and Dis

                current_results  = MakeEnsembleLearningNocoding_B_SimulateEA(pred_phases, ground_truth, ResultingFile); %as the we need to 
            end
            

            results = [results;  current_results];
        end
    end
end
disp('---------------------------------------------------------------------');
disp(results) %show the results

% Note that if I want to extract the results of multiple methods,
% I should make another separate script
