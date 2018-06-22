
%make the ensemble prediction for the ECOC or N-ary ECOC encoding, save the results, the file names of the
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
function final_results  = MakeEnsembleLearningEncoding_B(pred_phases, group_configure,ground_truth, ResultingFile, Ensemble_Results_Setting)



   %create the directory if they ar not existing
    CreateDirThreeLevel_A(ResultingFile.root_dir, ResultingFile.dataset_dir, ResultingFile.experiment_flag);
    
    
    %write the base model accuracy, Ensemble accuracy, Oracle accuracy with
    %respect to the number of phases
    global_save_file_prefix = [ResultingFile.root_dir  '/' ...
        ResultingFile.dataset_dir '/' ResultingFile.experiment_flag '/' ...
        ResultingFile.save_file_prefix  '_' ...
        num2str(ResultingFile.totoal_num_phase) ];
    ensemble_results_file_name =  [global_save_file_prefix '_paper.txt'];
        
    
    
    %the following are public variables used all through this script
    classes = sort( unique(ground_truth) );
    if length(unique(ground_truth)) < length(unique(pred_phases(:)))
        disp('the number of unique predicted class labels are more than the number of unique real class labels, please check');
        ContinueOrTerminate_A;
    end
    %codewords  size : num_class by number_phases
    codewords = GroupConfigure2Codeword(group_configure, classes); 
    
     %from the original classes of 'ground_truth' to the ECOC coding truth
     %note that there are multiple phases of transferred ground, not a
     %single phase
    transferred_truth = zeros( length(ground_truth),  size(pred_phases,2));

    for i = 1 : size(pred_phases,2)
        transferred_truth(:,i) =  TransferTruthNocoding2Encoding_A(ground_truth, codewords(:,i));
    end
    EncodingInformation.codewords = codewords;
    EncodingInformation.transferred_truth = transferred_truth;
    
    %estimate the  BA, std(BA), EA, std(EA), OA, std(OA), (one row only, or multiple rows, based on the setting of  Ensemble_Results_Setting
    [ensemble_performance,final_pred] = EstimateBAEAOAEncoding_B(pred_phases, EncodingInformation, ground_truth, Ensemble_Results_Setting);
    dlmwrite(ensemble_results_file_name,ensemble_performance,'delimiter',' ');
    
    
    
   ensemble_results_prediction_file_name =  [global_save_file_prefix '_prediction.txt'];
   dlmwrite(ensemble_results_prediction_file_name,final_pred,'delimiter',' ');
    
    
    %write the base model accuracy, Ensemble accuracy, Oracle accuracy
    %together with the Q statistics, and disagreement measure.
    ensemble_accuracy_diversity_file_name = [global_save_file_prefix '_paper_plus_diversity.txt'];
    
    Q = QMeasureEncodingFromTransferredTruth_A( pred_phases, transferred_truth); 
    %we do not need the QMeasureEncodingFromTransferredTruth_A( pred_phases, group_configure,
    %ground_truth) since we know the transferred ground truth

        tic;
     DisagreementMeasure = DisaggrementMeasureEncodingFromGroupConfigure_A( pred_phases, group_configure, ground_truth );
     toc;
     
%     [Q, DisagreementMeasure ] = EstimateQDisagreementMeasure_B(pred_phases, ground_truth);
    
    %note that the output is not BA, std(BA), EA, std(EA), OA, std(OA) Q, Dis ,
    %because we do not need std(EA),  std(OA), thus only extract the
    %1,2,3, 5 columns of ensemble_performance(end,:).
    final_results = [ensemble_performance(end,[1:3,5])  Q, DisagreementMeasure];
    dlmwrite(ensemble_accuracy_diversity_file_name, final_results ,'delimiter',' ');
    

    