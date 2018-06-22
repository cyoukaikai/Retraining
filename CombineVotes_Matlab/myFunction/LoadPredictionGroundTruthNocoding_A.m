%the lowest level general function for all kinds of use, RI encoding or
%ECOC or N-ary ECOC encoding.
%Input: prediction_file_names, cell of strings of different length
%       groung_truth_file_name, one string 

%output: pred_phases, the predictions of the base models for making ensmeble
%       ground_truth, the ground_truth for making ensmeble
%       also report exceptions (10 / 20 files are not empty -> just report
%       
function [pred_phases, ground_truth] = LoadPredictionGroundTruthNocoding_A(prediction_file_names, groung_truth_file_name )



    pred_phases = []; ground_truth = [];
    for i = 1 : numel(prediction_file_names)
        tmp_file_name = prediction_file_names{i}; 
        if exist(tmp_file_name, 'file')
            pred_current =  load(tmp_file_name);
            pred_phases = [ pred_phases pred_current];
        end
    end

    %=============================check exception
    if  (size(pred_phases,2) == 0 )
       disp(['!!!, none of the prediction files exist']);
       ContinueOrTerminate_A
    end
    
    
    tmp_file_name = groung_truth_file_name; %orginal_100run_prediction_0
    if exist(tmp_file_name, 'file')
        ground_truth =  load(tmp_file_name);
    else
        
        disp(['!!!,' groung_truth_file_name 'does not exist']);
        ContinueOrTerminate_A
    end

    if size(pred_phases,1)  ~= size(ground_truth,1)
        disp(['!!!, predictions and ground_truth are of different training examples']);
        ContinueOrTerminate_A
    end

end
