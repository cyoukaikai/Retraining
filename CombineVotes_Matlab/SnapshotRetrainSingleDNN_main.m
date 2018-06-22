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


Ensemble_Learning_Method_Name = 'SnapshotRetrain';

Ensemble_Learning_Method_Prediction_DIR_Prefix = 'original_100run_retrain'; %,'original_100run'}; 
DNNToTest = {'CIFAR100-DENSENET'}; %,'FLOWER102-NIN-FINETUNE','ILSVRC2012-NIN','CIFAR100-DENSENET'}; %try to only use one DNN each time, otherwise, it will be very complecate
% ,'ILSVRC2012-NIN'
%=============================================================
% setting of my usage
%============================================================
NumberPhases = [20];



%=============================================================
% below sections do not need to modify
%=============================================================
% for one ensemble learning method, extract the result into one line (for 
% one DNN) or multiple lines (for multiple DNNs). 


results = [];
for i = 1 : numel(DNNToTest)
    DNN_ID = getDNNIDByName( DNN_MODELS, DNNToTest{i} );
    disp(['Dataset = ' DNN_MODELS{DNN_ID}.DNN]);
%     DIR_PATHS.CAFFE_Prediction_DIR = '..'; 
%     DIR_PATHS.Preprocessed_Prediction_DIR = 'preprocessed_data'; 
%     DIR_PATHS.Results_DIR = 'results'; 
%     DIR_PATHS.BASELINE_TEST_DIR = 'BASELINE'; 


    %===note that the number of phases for SnapshotRetrain may be different
    %from the original retraining.
    totoal_num_phase = NumberPhases(i);
    %this is the only difference with snapshot ensemble
    %-------------------------------------------------------------------
    
    
    
    
    
    %generate the prediction file names, real label file.
    %all the predictions are in only one directory, the real label is in
    %the same directory
    
    %if  'original_100run_retrain0' do not exist, then change to 'original_100run'
    parent_directory_name = [ DIR_PATHS.CAFFE_Prediction_DIR '/' ...
            DNN_MODELS{DNN_ID}.DNN '/'  DIR_PATHS.BASELINE_TEST_DIR '/' ...
            Ensemble_Learning_Method_Name '/'] ;
       

    prediction_file_names = cell(1,totoal_num_phase);
    for predition_id = 1 : totoal_num_phase 
        if ( predition_id == 1 )
             prediction_file_names{predition_id} = [parent_directory_name ...
                Ensemble_Learning_Method_Prediction_DIR_Prefix ...
                 num2str(predition_id - 1) '_' ...
                 num2str(DNN_MODELS{DNN_ID}.MAX_NUM_ITERATION) '/prediction_0.txt'];
        else
             prediction_file_names{predition_id} = [parent_directory_name ...
                Ensemble_Learning_Method_Prediction_DIR_Prefix ...
                 num2str(predition_id - 1) '_' ...
                 num2str(DNN_MODELS{DNN_ID}.RETRAIN_MAX_NUM_ITERATION) '/prediction_0.txt'];
        end
            %the prediction file is 0-index, while matlab is 1-index
    end
    groung_truth_file_name = [parent_directory_name ...
                Ensemble_Learning_Method_Prediction_DIR_Prefix ...
                 num2str(predition_id - 1) '_' ... 
                 num2str(DNN_MODELS{DNN_ID}.RETRAIN_MAX_NUM_ITERATION) '/real_label.txt'];
            
            
    %load the predictions and ground truth    
    ResultingFile.root_dir = DIR_PATHS.Preprocessed_Prediction_DIR; %first root direcotry
    ResultingFile.dataset_dir =  DNN_MODELS{DNN_ID}.DNN; %second root direcotry
    ResultingFile.experiment_flag =  DIR_PATHS.BASELINE_TEST_DIR; %third root direcotry
    ResultingFile.totoal_num_phase = totoal_num_phase; %
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
    current_results  = MakeEnsembleLearningNocoding_B(pred_phases, ground_truth, ResultingFile, Ensemble_Results_Setting);
   
    results = [results;  current_results];
end
disp('---------------------------------------------------------------------');
disp(results) %show the results

% Note that if I want to extract the results of multiple methods,
% I should make another separate script