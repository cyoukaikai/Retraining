
%note, here we suppose the ground_truth is 0-index, as matlab is 1-index,
%so we need to perform the transformation. if this is not the case, we do
%not need to do this.
function accu_oracle = cal_oracle_accu( ensemble_result, truth )
    count = 0;
    for i = 1 : length( truth )
        if ( ensemble_result(i, truth(i) + 1 ) > 0 )
            count = count + 1;
        end
    end
    accu_oracle = count / length( truth ) * 100 ;  %chagne to percent%.
    