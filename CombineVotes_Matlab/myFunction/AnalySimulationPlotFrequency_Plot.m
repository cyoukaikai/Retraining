
%         ResultingFile.root_dir = DIR_PATHS.Preprocessed_Prediction_DIR; %first root direcotry
%     ResultingFile.dataset_dir =  DNN_MODELS{DNN_ID}.DNN; %second root direcotry
%     ResultingFile.experiment_flag =  DIR_PATHS.BASELINE_TEST_DIR; %third root direcotry
%     ResultingFile.totoal_num_phase =  DNN_MODELS{DNN_ID}.TOTAL_NUM_PHASE;
%     ResultingFile.save_file_prefix = Ensemble_Learning_Method_Name;
%     ResultingFile.save_file_suffix = 'run_results_all_prediction.mat';
%     ResultingFile.root_dir = DIR_PATHS.Results_DIR ; %first root direcotry, save to "results/"
%     ResultingFile.totoal_num_phase = size(pred_phases,2); %mofify the total number phase based on the real number of phases loaded.

function  AnalySimulationPlotFrequency_Plot(prediction_frequency, ground_truth,ResultingFile)

close all; 

dlmwrite([ResultingFile.root_dir '/SimulateEA/' ResultingFile.dataset_dir '-prediction-frequency.txt'],prediction_frequency,'delimiter',' ');
%count how many times the real labels are predicted
% plot the frequency 
Frequency = zeros(1,length(ground_truth));
for i = 1 : length(ground_truth)
    Frequency(i) = prediction_frequency (i, ground_truth(i) + 1);
end
x = 1: length(ground_truth);
hist(Frequency, 100)

xlabel('Number of classifier predicted correctly','FontSize', 30);
ylabel('Frequency','FontSize', 30);
save_prefix = [ResultingFile.root_dir '/SimulateEA/' ResultingFile.dataset_dir '-real-label-prediction-frequency'];
figure_name = [save_prefix '.jpg'];
saveas(gcf,figure_name)




% sort the prediction_freqency (without care about the real label or not)
% just plot the top-1 prediction fruency and top 2, ... frequency

[Y,I] = sort(prediction_frequency,2,'descend') ;
% for i = 1 : size(Y,2);
for i = 1 : 10
    hist(Y(:,i), 100)
    xlabel(['Top '  num2str(i) ' predictions '],'FontSize', 30);
    ylabel('Frequency','FontSize', 30);
%     title('';
    save_prefix = [ResultingFile.root_dir '/SimulateEA/' ResultingFile.dataset_dir '-top'  num2str(i) '-prediction-frequency'];
    figure_name = [save_prefix '.jpg'];
    saveas(gcf,figure_name)
end