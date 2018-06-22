%the lowest level general function for all kinds of use, RI encoding or
%ECOC or N-ary ECOC encoding.
%Input: prediction_file_names, cell of strings of different length
%       groung_truth_file_name, one string 

%output: pred_phases, the predictions of the base models for making ensmeble
%       ground_truth, the ground_truth for making ensmeble
%       also report exceptions (10 / 20 files are not empty -> just report



function    [group_configure, pred_phases, ground_truth] = LoadPredictionGroundTruthEncoding_A( ...
        prediction_file_names,  ECOC_codeword_prototxt_file_name, ECOC_phases_complete, ...
            ECOC_phase_to_predict, groung_truth_file_name)
   
    %load the group configuration file from the overall configuration file
    if exist(ECOC_codeword_prototxt_file_name, 'file')
        data = load(ECOC_codeword_prototxt_file_name);
        group_configure_all_back = data.group_configure_all; 
        id =  (ECOC_phases_complete == ECOC_phase_to_predict); %if the ECOC phases of the ECOC_phases_complete is unique, this works
        if isempty(id)
            disp(['!!!, loadPredictionGroundTruthEncoding_A, ECOC_phase_to_predict is not' ...
                ' included in the ECOC_phases_complete , please revise the relavant .mat' ...
                ' file or modify the ECOC_phases_complete vector.']);
             ContinueOrTerminate_A
        end
        
        group_configure = group_configure_all_back{id}; %all information
        group_configure_tmp_id = 1;
    else
         disp(['!!!, loadPredictionGroundTruthEncoding_A, the group configure file does not exist']);
          ContinueOrTerminate_A
    end



    pred_phases = []; 
    ground_truth = [];
    for i = 1 : numel(prediction_file_names)
        tmp_file_name = prediction_file_names{i}; 
        if exist(tmp_file_name, 'file')
            pred_current =  load(tmp_file_name);
            
%             pred_current =  pred_current(:,1);  %only load the top-1 prediction
%             dlmwrite(tmp_file_name,pred_current ,'delimiter',' ');
            
            pred_phases = [ pred_phases pred_current];
            group_configure_tmp{ group_configure_tmp_id } = group_configure{i };
            group_configure_tmp_id = group_configure_tmp_id + 1;
        end
    end
    clear group_configure; 
    group_configure = group_configure_tmp; %only load the group configure where the prediction file exists

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
    elseif size(pred_phases,2)  ~= numel(group_configure)
          disp(['!!!, predictions and group_configure_all are of different number of phases']);
        ContinueOrTerminate_A  
    end

end



     
