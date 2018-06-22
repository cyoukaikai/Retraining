
%create dir if then do not exist
% usage: CreateDirThreeLevel_A(ResultingFile.root_dir, ResultingFile.dataset_dir, ResultingFile.experiment_flag)
function CreateDirThreeLevel_A(root_dir, second_level_dir, third_level_dir)
    %create the directory if they ar not existing
    dir_to_create = root_dir ;
    if ~exist(dir_to_create,'dir')
        mkdir(dir_to_create)
    end
    dir_to_create = [dir_to_create '/' second_level_dir];
    if ~exist(dir_to_create,'dir')
        mkdir(dir_to_create)
    end
    dir_to_create = [dir_to_create '/' third_level_dir];
    if ~exist(dir_to_create,'dir')
        mkdir(dir_to_create)
    end
    