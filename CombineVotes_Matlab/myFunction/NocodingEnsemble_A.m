
% original_100run, report the single phase performance and and 
% ensemble performance (note, the ensemble performance should randomly
% select n phases to ensemble, cal the average accuracy and std 

function RI_general(ground_truth, pred_phases,random_num_phase, num_phase_original_run, resulting_dir_and_prefix)

%%===============================================

truth = ground_truth;
num_image = length(truth);
num_class = length( unique(truth) );

log_filename = [ resulting_dir_and_prefix '_' num2str(num_phase_original_run) '_ensemble_performance.txt'];

%the results for putting in the paper]
ensemble_results_file_name = [resulting_dir_and_prefix '_' num2str(num_phase_original_run) '_paper.txt'];



LOG_INFOR = []; 
% LOG_INFOR = log_write_text(LOG_INFOR, ['original_100run: total ' num2str(num_phase_original_run) ]);


% LOG_INFOR = log_write_text(LOG_INFOR, 'show the accuracy of each single phase');
accu_original_run = zeros( num_phase_original_run, 1);


for i = 1 : num_phase_original_run
    accu_original_run(i) = sum(truth  == pred_phases(:,i) ) / num_image * 100;
    disp([  num2str(i) ' ' num2str( accu_original_run(i) ) ]);
end
LOG_INFOR = log_write_single_phase_accuracy(LOG_INFOR, accu_original_run);
% file_name_tmp = ['results/paper_use/original_100run_single_' save_file_prefix '.txt']; %num2str(iters) 
% dlmwrite(file_name_tmp ,accu_original_run,'delimiter',' ');

 
%report the mean accuracy and std for each N number of single phases 
mean_accuracy = zeros( num_phase_original_run, 2);
for k = 1 : num_phase_original_run
        random_order = randperm( num_phase_original_run );
        accu = accu_original_run ( random_order(1:k ) );
        mean_accuracy(k,:) = [mean( accu ), std(accu)];
end
LOG_INFOR = log_write_matrix( LOG_INFOR, [ [ 1:num_phase_original_run]' mean_accuracy], 'the mean accuracy for k phases: N accuracy'); 



%report the accuracy of averge ensemble accuracy and std of single phases 
% at the same time, prepare some public files for later use.
% public_original_100run_ensemble = cell( random_num_phase , 1);

ensmeble_accuracy = zeros( num_phase_original_run, random_num_phase);
oracle_accuracy = zeros( num_phase_original_run, random_num_phase);
for k = 1 : random_num_phase
%     tic
%     disp([ 'random_num_phase = ' num2str(k) ' ------------ ']);
    [ensmeble_accuracy(:,k), oracle_accuracy(:,k),final_pred] ...
        = make_ensemble_original_100run(  pred_phases, truth);
%     toc
end
% LOG_INFOR = log_write_ensemble_performance( LOG_INFOR, ensmeble_accuracy,oracle_accuracy);
% fid = fopen(log_filename, 'w'); fprintf(fid, '%s',  LOG_INFOR );  fclose(fid);

%the results for putting in the paper]


% file_name_prediction_top_K = [resulting_dir_and_prefix '_' num2str(num_phase_original_run) '_pred.txt'];
%  dlmwrite(file_name_prediction_top_K ,final_pred,'delimiter',' ');

ensemble_performance  = get_ensemble_performance(ensmeble_accuracy,oracle_accuracy );
ensemble_performance  = [mean_accuracy ensemble_performance];
dlmwrite(ensemble_results_file_name,ensemble_performance,'delimiter',' ', 'precision','%.2f');

% if ~exist(public_use_original_100run_ensemble_file_name, 'file') %save the file only when it does not exist
%     save(public_use_original_100run_ensemble_file_name , 'public_original_100run_ensemble');
% end
