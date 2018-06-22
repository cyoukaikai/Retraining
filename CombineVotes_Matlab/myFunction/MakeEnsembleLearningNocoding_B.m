
%make the ensemble prediction, save the results, the file names of the
%results are generated in this function, by the following polify
% file_name_prediction = [ResultingFile.root_dir  '/' ...
%     ResultingFile.dataset_dir '/' ResultingFile.experiment_flag '/' ...
%     ResultingFile.save_file_prefix  '_' ...
%     num2str(ResultingFile.totoal_num_phase) ...
%     + '_paper.txt' or '_paper_plus_diversity.txt'
%resulting files: '_paper.txt' one file for the BA, std(BA), EA, OA
%                   another file ('_paper_plus_diversity.txt') for th Q and DisagreementMeasure


%input: Ensemble_Results_Setting 
%setting for estimating the ensemble accuracy, the results averaged by 10
%times run or only 1 time run, the result of n1 / n phases (where n1 = 1,
%2, 3 , ... n or n1 = n only).
%    Ensemble_Results_Setting.Random_Num_Phase = 1; %default setting is 1
%    Ensemble_Results_Setting.Report_Last_OR_All = 'last'; %'all' or 'last' or with some interval.
%default report only the last, do report all for N-ary ECOC or future predicting the Ensemble accuracy

%output: BA, std(BA), EA, OA,  Q, Dis (one row, six columns)
%note that the output is not BA, std(BA), EA, std(EA), OA, std(OA) Q, Dis ,
%because we do not need std(EA),  std(OA)

%final_results = zeros(1, 6);
function final_results  = MakeEnsembleLearningNocoding_B(pred_phases, ground_truth, ResultingFile,  Ensemble_Results_Setting) 

    %create the directory if they ar not existing
    CreateDirThreeLevel_A(ResultingFile.root_dir, ResultingFile.dataset_dir, ResultingFile.experiment_flag);
    
    
    %write the base model accuracy, Ensemble accuracy, Oracle accuracy with
    %respect to the number of phases
    global_save_file_prefix = [ResultingFile.root_dir  '/' ...
        ResultingFile.dataset_dir '/' ResultingFile.experiment_flag '/' ...
        ResultingFile.save_file_prefix  '_' ...
        num2str(ResultingFile.totoal_num_phase) ];
    ensemble_results_file_name =  [global_save_file_prefix '_paper.txt'];
        
    
    %estimate the  BA, std(BA), EA, std(EA), OA, std(OA), (one row only, or multiple rows, based on the setting of  Ensemble_Results_Setting
    [ensemble_performance,final_pred] = EstimateBAEAOA_B(pred_phases, ground_truth, Ensemble_Results_Setting);
    dlmwrite(ensemble_results_file_name,ensemble_performance,'delimiter',' ');
    
    ensemble_results_prediction_file_name =  [global_save_file_prefix '_prediction.txt'];
   dlmwrite(ensemble_results_prediction_file_name,final_pred,'delimiter',' ');
       
    
    
    %write the base model accuracy, Ensemble accuracy, Oracle accuracy
    %together with the Q statistics, and disagreement measure.
    ensemble_accuracy_diversity_file_name = [global_save_file_prefix '_paper_plus_diversity.txt'];
    
     Q = QMeasure_A( pred_phases, ground_truth );
     DisagreementMeasure = DisaggrementMeasure_A( pred_phases );
%     [Q, DisagreementMeasure ] = EstimateQDisagreementMeasure_B(pred_phases, ground_truth);
    
    %note that the output is not BA, std(BA), EA, std(EA), OA, std(OA) Q, Dis ,
    %because we do not need std(EA),  std(OA), thus only extract the
    %1,2,3, 5 columns of ensemble_performance(end,:).
    final_results = [ensemble_performance(end,[1:3,5])  Q, DisagreementMeasure];
    dlmwrite(ensemble_accuracy_diversity_file_name, final_results ,'delimiter',' ');
    
    
    


