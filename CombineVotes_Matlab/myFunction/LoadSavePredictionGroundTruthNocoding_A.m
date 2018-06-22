
% 
%     ResultingFile.root_dir  = DIR_PATHS.Preprocessed_Prediction_DIR; %first root direcotry
%     ResultingFile.dataset_dir =  DNN_MODELS{DNN_ID}.DNN; %second root direcotry
%     ResultingFile.experiment_flag =  DIR_PATHS.BASELINE_TEST_DIR; %third root direcotry
%     ResultingFile.totoal_num_phase =  DNN_MODELS{DNN_ID}.TOTAL_NUM_PHASE;
%     ResultingFile.save_file_prefix = Ensemble_Learning_Method_Name;
function [pred_phases, ground_truth] = LoadSavePredictionGroundTruthNocoding_A( prediction_file_names, groung_truth_file_name, ResultingFile  )

file_name_prediction = [ResultingFile.root_dir  '/' ...
    ResultingFile.dataset_dir '/' ResultingFile.experiment_flag '/' ...
    ResultingFile.save_file_prefix  '_' ...
    num2str(ResultingFile.totoal_num_phase) ...
    ResultingFile.save_file_suffix];

if exist(file_name_prediction, 'file') 
    data = load(file_name_prediction);
    pred_phases = data.pred_phases;
    ground_truth =  data.ground_truth;
    disp( 'the target prediction_all files already exist, please delete it to generate new file');
else
    [pred_phases, ground_truth] = LoadPredictionGroundTruthNocoding_A( prediction_file_names, groung_truth_file_name );
    
     %create the directory if they ar not existing
    CreateDirThreeLevel_A(ResultingFile.root_dir, ResultingFile.dataset_dir, ResultingFile.experiment_flag);
   

    
    if  (size(pred_phases,2) == 0) || (size(ground_truth,2) == 0  )
         disp(['Function LoadSavePredictionGroundTruthNocoding_A caution, prediction files or real_label.txt  do not exist, skip creating the .mat file']);
         ContinueOrTerminate_A
    end
    
    %if the loaded files are less than the given
    %ResultingFile.totoal_num_phase, the predictions of some phases missing
    if size(pred_phases,2) < ResultingFile.totoal_num_phase
        real_num_phase = size(pred_phases,2); %count the real number of phases loaded
        disp(['loaded ' num2str(real_num_phase) 'files from the given ' num2str(ResultingFile.totoal_num_phase) ' file names']);
        
        file_name_prediction = [ResultingFile.root_dir  '/' ...
            ResultingFile.dataset_dir '/' ResultingFile.experiment_flag '/' ...
            ResultingFile.save_file_prefix  '_' ...
            num2str(real_num_phase) ...
            'run_results_all_prediction.mat'];
    end
    save(file_name_prediction, 'pred_phases','ground_truth');
%   dlmwrite(file_name_prediction ,pred_phases,'delimiter',' ');
end