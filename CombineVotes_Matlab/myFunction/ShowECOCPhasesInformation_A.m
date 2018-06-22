function ShowECOCPhasesInformation_A( DNN_MODELS  )


ECOC_INFORMATION = ['ECOC_INFORMATION --------------'];
for i = 1 : numel( DNN_MODELS )
    ECOC_INFORMATION = [ECOC_INFORMATION DNN_MODELS{i}.DNN ];
    
    ECOC_INFORMATION = [ ECOC_INFORMATION char(9) 'ECOC_PHASES = [' ];
    for j = 1 : length( DNN_MODELS{i}.ECOC_PHASES )
        ECOC_INFORMATION = [ ECOC_INFORMATION num2str( DNN_MODELS{i}.ECOC_PHASES(j) ) ' ' ];
    end
    ECOC_INFORMATION = [ECOC_INFORMATION char(9) ']' char(10) ];
end
disp(ECOC_INFORMATION);