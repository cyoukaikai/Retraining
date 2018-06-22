
clc; clear; close all;
global_configure
add_function

ShowECOCPhasesInformation_A( DNN_MODELS  );
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
                        {[ 33]}, ...  %'CIFAR100-QUICK'   10  50  33  25 5   4   3  2
                         {[2, 3,5, 25,33,50, 60,75,80,90,95]} ,... %'CIFAR100-DenseNet'
                         {[ 95, 5, 3, 2]} ,... %'FLOWER102-ALEXNET-Scratch'  51 , 34, 10, 102,
                    {[95 2]} ,... %'FLOWER102-NIN-finetune' 51 , 34, 10, 5, 3, 102,  95,
                    {} ...  %'ILSVRC2012-NIN'
                    };
                
                
% DATASET ={ 'MNIST','SVHN-QUICK','CIFAR10-FULL','CIFAR10-QUICK', ... %4
%    'CIFAR100-NIN', 'CIFAR100-QUICK', 'CIFAR100-DENSENET', ... %3
%    'FLOWER102-ALEXNET-SCRATCH', 'FLOWER102-NIN-FINETUNE',... %3
%     'ILSVRC2012-NIN' }; %2 %'
%     'CIFAR100-DENSENET','FLOWER102-ALEXNET-SCRATCH','FLOWER102-NIN-FINETUNE', 'CIFAR100-NIN', 'CIFAR100-QUICK','CIFAR100-DENSENET','FLOWER102-ALEXNET-SCRATCH','FLOWER102-NIN-FINETUNE', 'ILSVRC2012-NIN' 
DNNToTest = { 'CIFAR100-QUICK'}; % 'CIFAR100-NIN',
% ,'CIFAR100-NIN'

DIRECTORY_TEST_DIR = 'RITOECOCip2-1-number-output-100'; %RITOECOCip2-1

results = [];
for i = 1 : numel(DNNToTest)
    DNN_ID = getDNNIDByName( DNN_MODELS, DNNToTest{i} );
    disp(['Dataset = ' DNN_MODELS{DNN_ID}.DNN]);     
     
    totoal_num_phase = 23; % DNN_MODELS{DNN_ID}.TOTAL_NUM_PHASE; %60; %
%     dataset_dir = DNN_MODELS{DNN_ID}.DNN;
%     path_preprocessed_data_dir = DIR_PATHS.Preprocessed_Prediction_DIR;
%     experiment_flag = DIRECTORY_TEST_DIR;
    
    %generate the prediction file names, real label file.
    %all the predictions are in only one directory, the real label is in
    %the same directory
    ECOC_phases_complete = DNN_MODELS{DNN_ID}.ECOC_PHASES; %2 , 3 ,4 ,5 7
    ECOC_Phases_Test_Now = ECOC_Phases_To_Test{DNN_ID}{1};
    %because there is only one cell for each of the element of ECOC_Phases_To_Test{DNN_ID}
    
    for test_phase_id = 1 : length(ECOC_Phases_Test_Now)
        ECOC_phase_to_predict = ECOC_Phases_Test_Now(test_phase_id);
        disp(['ECOC phase = ' num2str(ECOC_phase_to_predict)]);   
        Ensemble_Learning_Method_Name = ['ECOC' num2str(ECOC_phase_to_predict) ];
            
        single_directory_name = [ DIR_PATHS.CAFFE_Prediction_DIR '/' ...
                DNN_MODELS{DNN_ID}.DNN '/'  DIRECTORY_TEST_DIR   '/' ... 
                Ensemble_Learning_Method_Name '/'] ;
        groung_truth_file_name = [single_directory_name 'real_label.txt'];
        
        %============================
        ECOC_codeword_prototxt_file_name = [ DIR_PATHS.Preprocessed_Prediction_DIR '/'...
             DNN_MODELS{DNN_ID}.DNN '/'  DIR_PATHS.BASELINE_TEST_DIR '/' ...
             'ECOC_NaryECOC_CODEWORD.mat' ];
       % if the group_configure file is in the BASELINE, else if the group_configure file is in its directory , then use DIRECTORY_TEST_DIR
       %============================
       
        prediction_file_names = cell(1,totoal_num_phase);
        for predition_id = 1 : totoal_num_phase 
            prediction_file_names{predition_id} = [single_directory_name 'prediction_' ...
                num2str(predition_id - 1 ) '.txt'];
                %the prediction file is 0-index, while matlab is 1-index
        end
        %load the predictions and ground truth    
        ResultingFile.root_dir = DIR_PATHS.Preprocessed_Prediction_DIR; %first root direcotry
        ResultingFile.dataset_dir =  DNN_MODELS{DNN_ID}.DNN; %second root direcotry
        ResultingFile.experiment_flag =  DIRECTORY_TEST_DIR; %third root direcotry
        ResultingFile.totoal_num_phase =  totoal_num_phase;
        ResultingFile.save_file_prefix = Ensemble_Learning_Method_Name  ;     
        ResultingFile.save_file_suffix = 'run_results.mat';


        [group_configure, pred_phases, ground_truth] = LoadSavePredictionGroundTruthEncoding_A( ...
            prediction_file_names, ECOC_codeword_prototxt_file_name, ECOC_phases_complete, ...
            ECOC_phase_to_predict,groung_truth_file_name, ResultingFile  );
        
        if (max( max(pred_phases) ) > ECOC_phase_to_predict )
               disp(['max value of pred_phases is ' num2str( max( max(pred_phases) ) )]);
               phases_involved =  max(pred_phases) == max( max(pred_phases) ) ;
               disp(['the phases are involved are: ']);
               disp(phases_involved);
               disp('predicted meta-class label are larger than actuall meta-class label, e.g., predict 9 for ECOC2, please check');
               ContinueOrTerminate_A;
        end
    
        ResultingFile.root_dir = DIR_PATHS.Results_DIR; %first root direcotry, save to "results/"
        ResultingFile.totoal_num_phase = size(pred_phases,2); %mofify the total number phase based on the real number of phases loaded.
        
        current_results  = MakeEnsembleLearningEncoding_B(pred_phases, group_configure,ground_truth,  ResultingFile, Ensemble_Results_Setting);

        results = [results;  DNN_ID ECOC_phase_to_predict ResultingFile.totoal_num_phase current_results];
    end
 end
disp('---------------------------------------------------------------------');
disp(results) %show the results

