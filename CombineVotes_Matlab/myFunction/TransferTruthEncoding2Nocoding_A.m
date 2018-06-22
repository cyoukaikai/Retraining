% transfer the ECOC predictions to RI prediction, where the positions of
% classes of the  predicted meta-class are marked as 1, while other
% positions are marked 0
% e.g., if predicted meta-class = 1 for only two meta-classes (0,1), and
% the given phase_configure = { [ 1 3], [0 2 ]} (0-index), then the
% RI-prediction are [0 1 0 1] where the (0 and 2th) + 1
% positions are marked 1, other positions are marked 0.
function predictions_RI =  TransferTruthEncoding2Nocoding_A(phase_configure, ECOC_pred_single_phase )

num_meta_classes = numel( phase_configure);

num_original_classes = 0;
for i = 1 : numel( phase_configure)
    num_original_classes = num_original_classes + length( phase_configure{i});
end
ECOC_pred_to_RI_check_table = zeros(num_meta_classes, num_original_classes);
for k = 1 :  num_meta_classes
    ECOC_pred_to_RI_check_table(k, phase_configure{ k }+1 ) = 1;
end

if max( ECOC_pred_single_phase ) > (num_meta_classes - 1)
   disp('predicted meta-class label are larger than actuall meta-class label, e.g., predict 9 for ECOC2, please check');
   ContinueOrTerminate_A;
    
end
predictions_RI = ECOC_pred_to_RI_check_table( ECOC_pred_single_phase + 1, : );
      