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


Ensemble_Learning_Method_Names = {'RI' 'Bagging', 'LongIters'}'; %'RI' 'Bagging', 'AdaBoosting'
Ensemble_Learning_Method_Prediction_DIRs = {'original_100run','bagging_100run','LongIters'};
%=============================================================
% setting of my usage
%============================================================

for MethodID = 1: 1
    Ensemble_Learning_Method_ID = MethodID;

    % DATASET ={ 'MNIST','SVHN-QUICK','CIFAR10-FULL','CIFAR10-QUICK', ... %4
    %    'CIFAR100-NIN', 'CIFAR100-QUICK', 'CIFAR100-DENSENET', ... %3
    %    'FLOWER102-ALEXNET-SCRATCH', 'FLOWER102-NIN-FINETUNE',... %3
    %     'ILSVRC2012-NIN' }; %2 %' 'CIFAR100-DENSENET','FLOWER102-ALEXNET-SCRATCH','FLOWER102-NIN-FINETUNE',
    % 'MNIST','SVHN-QUICK','CIFAR10-FULL','CIFAR10-QUICK','CIFAR100-NIN', 'CIFAR100-QUICK','CIFAR100-DENSENET','FLOWER102-ALEXNET-SCRATCH','FLOWER102-NIN-FINETUNE', 

%     NumberOfFoldForCrossValidation = [7, 4, 6, 6 , 1, 6]; %FLOWER102 should be set indepentaly
    DNNToTest = {'ILSVRC2012-ALEXNET'}; %try to only use one DNN each time, otherwise, it will be very complecate
    %=============================================================
    % below sections do not need to modify
    %=============================================================
    % for one ensemble learning method, extract the result into one line (for 
    % one DNN) or multiple lines (for multiple DNNs). 

    Ensemble_Learning_Method_Name = Ensemble_Learning_Method_Names{Ensemble_Learning_Method_ID}
    Ensemble_Learning_Method_Prediction_DIR = Ensemble_Learning_Method_Prediction_DIRs{Ensemble_Learning_Method_ID}
    results = [];
    for i = 1 : numel(DNNToTest)



        DNN_ID = getDNNIDByName( DNN_MODELS, DNNToTest{i} );
        disp(['Dataset = ' DNN_MODELS{DNN_ID}.DNN]);
    %     DIR_PATHS.CAFFE_Prediction_DIR = '..'; 
    %     DIR_PATHS.Preprocessed_Prediction_DIR = 'preprocessed_data'; 
    %     DIR_PATHS.Results_DIR = 'results'; 
    %     DIR_PATHS.BASELINE_TEST_DIR = 'BASELINE'; 

        totoal_num_phase = DNN_MODELS{DNN_ID}.TOTAL_NUM_PHASE;
    %     dataset_dir = DNN_MODELS{DNN_ID}.DNN;
    %     path_preprocessed_data_dir = DIR_PATHS.Preprocessed_Prediction_DIR;
    %     experiment_flag = DIR_PATHS.BASELINE_TEST_DIR;


%         for foldID = 2 :4 %NumberOfFoldForCrossValidation(DNN_ID)
            DIR_PATHS.BASELINE_TEST_DIR = 'BASELINE'; 
%             DIR_PATHS.BASELINE_TEST_DIR =['Fold' num2str(foldID)]
%             DIR_PATHS.BASELINE_TEST_DIR =['ImbalancedClass' num2str(foldID)]
            %generate the prediction file names, real label file.
            %all the predictions are in only one directory, the real label is in
            %the same directory
            single_directory_name = [ DIR_PATHS.CAFFE_Prediction_DIR '/' ...
                    DNN_MODELS{DNN_ID}.DNN '/'  DIR_PATHS.BASELINE_TEST_DIR '/' ...
                    Ensemble_Learning_Method_Prediction_DIR '/'] ;
            groung_truth_file_name = [single_directory_name 'real_label.txt'];
            prediction_file_names = cell(1,totoal_num_phase);
            for predition_id = 1 : totoal_num_phase 
                prediction_file_names{predition_id} = [single_directory_name 'prediction_' ...
                    num2str(predition_id - 1 ) '.txt'];
                    %the prediction file is 0-index, while matlab is 1-index
            end



            %load the predictions and ground truth    
            ResultingFile.root_dir = DIR_PATHS.Preprocessed_Prediction_DIR; %first root direcotry
            ResultingFile.dataset_dir =  DNN_MODELS{DNN_ID}.DNN; %second root direcotry
            ResultingFile.experiment_flag =  DIR_PATHS.BASELINE_TEST_DIR; %third root direcotry
            ResultingFile.totoal_num_phase =  DNN_MODELS{DNN_ID}.TOTAL_NUM_PHASE;
            ResultingFile.save_file_prefix = Ensemble_Learning_Method_Name;
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
%     end
    disp('---------------------------------------------------------------------');
    disp(results) %show the results
end

% Note that if I want to extract the results of multiple methods,
% I should make another separate script