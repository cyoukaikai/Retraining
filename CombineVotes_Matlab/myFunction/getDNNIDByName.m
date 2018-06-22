function DNN_ID = getDNNIDByName(DNN_MODELS, DNNToTest )

DNN_ID = [];
for i = 1 : numel( DNN_MODELS )
    if strcmp( DNN_MODELS{i}.DNN, DNNToTest )
        DNN_ID = i;
        break;
    end
end

if isempty(DNN_ID)
    disp('DNNToTest is empty, please assign the value');
end