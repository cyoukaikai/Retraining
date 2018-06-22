% setting all the global variables in this script

NonEncodingEnsembleMethods = { 'RI', 'Retraining', 'Bagging', 'AdaBoosting', 'HV', ...
    'SnapshotEnsemble'};

EncodingEnsembleMethods = {'ECOC', 'N-aryECOC', 'ExtendN-aryECOC'};


%=========================================================================
%DNN models, Number of classes Nc, Number of models Nm,  max number of
%iterations of RI , Number of retrain Nr, Max number of iterations of 
%retraining,  ECOC_phases, Tested N, Best Tested N
%=========================================================================
%the following string is made by script
%"generate_global_configure_string.m"

DNN_MODELS_SETTINGS = { 
    {'MNIST',... %DNN
        10, ... %NUM_CLASSES 
        60, ... %TOTAL_NUM_PHASE
        10000, ... %MAX_NUM_ITERATION
        10000, ... %RETRAIN_MAX_NUM_ITERATION
        10, ... %NUM_RETRAIN
        [2 3 4 5 7 ],  ... %ECOC_PHASES
        3 ... % N_BEST
        }, ...
    {'SVHN-QUICK',... %DNN
        10, ... %NUM_CLASSES 
        100, ... %TOTAL_NUM_PHASE
        6000, ... %MAX_NUM_ITERATION
        6000, ... %RETRAIN_MAX_NUM_ITERATION
        10, ... %NUM_RETRAIN
        [2 3 4 5 10 7],  ... %ECOC_PHASES
        3 ... % N_BEST
        }, ...
    {'CIFAR10-FULL',... %DNN
        10, ... %NUM_CLASSES 
        100, ... %TOTAL_NUM_PHASE
        75000, ... %MAX_NUM_ITERATION
        75000, ... %RETRAIN_MAX_NUM_ITERATION
        0, ... %NUM_RETRAIN
        [2 3 4 5 7 ],  ... %ECOC_PHASES
        4 ... % N_BEST
        }, ...
    {'CIFAR10-QUICK',... %DNN
        10, ... %NUM_CLASSES 
        100, ... %TOTAL_NUM_PHASE
        5000, ... %MAX_NUM_ITERATION
        5000, ... %RETRAIN_MAX_NUM_ITERATION
        10, ... %NUM_RETRAIN
        [2 3 4 5 7 10],  ... %ECOC_PHASES
        7 ... % N_BEST
        }, ...
    {'CIFAR100-NIN',... %DNN
        100, ... %NUM_CLASSES 
        60, ... %TOTAL_NUM_PHASE
        50000, ... %MAX_NUM_ITERATION
        30000, ... %RETRAIN_MAX_NUM_ITERATION
        8, ... %NUM_RETRAIN
        [2, 3, 4,5, 25,33,50, 60,75,80,90,95],  ... %ECOC_PHASES
        95 ... % N_BEST
        }, ...
    {'CIFAR100-QUICK',... %DNN
        100, ... %NUM_CLASSES 
        100, ... %TOTAL_NUM_PHASE
        10000, ... %MAX_NUM_ITERATION
        10000, ... %RETRAIN_MAX_NUM_ITERATION
        10, ... %NUM_RETRAIN
        [95 75  50  33  25  10   5   4   3  2],  ... %ECOC_PHASES
        95 ... % N_BEST
        }, ...
    {'CIFAR100-DENSENET',... %DNN
        100, ... %NUM_CLASSES 
        10, ... %TOTAL_NUM_PHASE
        230000, ... %MAX_NUM_ITERATION
        30000, ... %RETRAIN_MAX_NUM_ITERATION
        4, ... %NUM_RETRAIN
        [2, 3, 4,5, 25,33,50, 60,75,80,90,95],  ... %ECOC_PHASES
        0 ... % N_BEST
        }, ...
    {'FLOWER102-ALEXNET-SCRATCH',... %DNN
        102, ... %NUM_CLASSES 
        60, ... %TOTAL_NUM_PHASE
        12000, ... %MAX_NUM_ITERATION
        12000, ... %RETRAIN_MAX_NUM_ITERATION
        4, ... %NUM_RETRAIN
        [102, 95, 51 , 34, 10, 5, 3, 2],  ... %ECOC_PHASES
        3 ... % N_BEST
        }, ...
    {'FLOWER102-NIN-FINETUNE',... %DNN
        102, ... %NUM_CLASSES 
        60, ... %TOTAL_NUM_PHASE
        12000, ... %MAX_NUM_ITERATION
        12000, ... %RETRAIN_MAX_NUM_ITERATION
        4, ... %NUM_RETRAIN
        [102, 95, 51 , 34, 10, 5, 3, 2],  ... %ECOC_PHASES
        95 ... % N_BEST
        }, ...
    {'ILSVRC2012-NIN',... %DNN
        1000, ... %NUM_CLASSES 
        10, ... %TOTAL_NUM_PHASE
        450000, ... %MAX_NUM_ITERATION
        250000, ... %RETRAIN_MAX_NUM_ITERATION 75000,
        4, ... %NUM_RETRAIN
        [2 3 5 10 34 51 95 ],  ... %ECOC_PHASES
        0 ... % N_BEST
        }, ...
      {'FLOWER102-ALEXNET-FINETUNE',... %DNN
        102, ... %NUM_CLASSES 
        60, ... %TOTAL_NUM_PHASE
        12000, ... %MAX_NUM_ITERATION
        12000, ... %RETRAIN_MAX_NUM_ITERATION
        4, ... %NUM_RETRAIN
        [102, 95, 51 , 34, 10, 5, 3, 2],  ... %ECOC_PHASES
        95 ... % N_BEST
        }, ...
        {'ILSVRC2012-ALEXNET',... %DNN
        1000, ... %NUM_CLASSES 
        5, ... %TOTAL_NUM_PHASE
        450000, ... %MAX_NUM_ITERATION
        200000, ... %RETRAIN_MAX_NUM_ITERATION 75000,
        1, ... %NUM_RETRAIN
        [2 3 5 10 34 51 95 ],  ... %ECOC_PHASES
        0 ... % N_BEST
        }, ... 
        {'ILSVRC2012-VGG-CNN-S',... %DNN
        1000, ... %NUM_CLASSES 
        1, ... %TOTAL_NUM_PHASE
        50000, ... %MAX_NUM_ITERATION
        200000, ... %RETRAIN_MAX_NUM_ITERATION 75000,
        1, ... %NUM_RETRAIN
        [],  ... %ECOC_PHASES
        0 ... % N_BEST
        }, ... 
        {'ILSVRC2012-VGG-16-layer',... %DNN
        1000, ... %NUM_CLASSES 
        1, ... %TOTAL_NUM_PHASE
        50000, ... %MAX_NUM_ITERATION
        100000, ... %RETRAIN_MAX_NUM_ITERATION 75000,
        1, ... %NUM_RETRAIN
        [],  ... %ECOC_PHASES
        0 ... % N_BEST
        } 
};


DATASET = cell(1,numel(DNN_MODELS_SETTINGS) ); 
NUM_CLASSES = size(1,numel(DNN_MODELS_SETTINGS) ); 
TOTAL_NUM_PHASE = size(1,numel(DNN_MODELS_SETTINGS) ); 
MAX_NUM_ITERATION = size(1,numel(DNN_MODELS_SETTINGS) ); 
RETRAIN_MAX_NUM_ITERATION = size(1,numel(DNN_MODELS_SETTINGS) ); 
NUM_RETRAIN = size(1,numel(DNN_MODELS_SETTINGS) ); 
ECOC_PHASES = cell(1,numel(DNN_MODELS_SETTINGS) ); 
N_BEST = size(1,numel(DNN_MODELS_SETTINGS) ); 
for item_id = 1 : numel(DNN_MODELS_SETTINGS)
    DATASET{item_id} = DNN_MODELS_SETTINGS{item_id}{1};
    NUM_CLASSES(item_id) = DNN_MODELS_SETTINGS{item_id}{2};
    TOTAL_NUM_PHASE(item_id) = DNN_MODELS_SETTINGS{item_id}{3};
    MAX_NUM_ITERATION(item_id) = DNN_MODELS_SETTINGS{item_id}{4};
    
    %retraining settings
    RETRAIN_MAX_NUM_ITERATION(item_id) = DNN_MODELS_SETTINGS{item_id}{5};
    NUM_RETRAIN(item_id) = DNN_MODELS_SETTINGS{item_id}{6};
    
    %N-ary ECOC settings
    ECOC_PHASES{item_id} = DNN_MODELS_SETTINGS{item_id}{7};
    N_BEST(item_id) = DNN_MODELS_SETTINGS{item_id}{8};
end
DNN = DATASET; %this sentence is to cooperate with the previous version


%=========================================================================
% create the structure from the manual cell configure of  DNN_MODELS_SETTINGS
% for each access
%=========================================================================
DNN_MODELS = cell(1,numel(DNN_MODELS_SETTINGS) );  %each cell is a structure
for item_id = 1 : numel(DNN_MODELS_SETTINGS)
    DNN_MODELS{item_id}.DNN = DNN_MODELS_SETTINGS{item_id}{1};
    DNN_MODELS{item_id}.DATASET = DNN_MODELS_SETTINGS{item_id}{1};
    DNN_MODELS{item_id}.NUM_CLASSES = DNN_MODELS_SETTINGS{item_id}{2};
    DNN_MODELS{item_id}.TOTAL_NUM_PHASE = DNN_MODELS_SETTINGS{item_id}{3};
    DNN_MODELS{item_id}.MAX_NUM_ITERATION = DNN_MODELS_SETTINGS{item_id}{4};
    
    %retraining settings
    DNN_MODELS{item_id}.RETRAIN_MAX_NUM_ITERATION = DNN_MODELS_SETTINGS{item_id}{5};
    DNN_MODELS{item_id}.NUM_RETRAIN = DNN_MODELS_SETTINGS{item_id}{6};
    
    %N-ary ECOC settings
    DNN_MODELS{item_id}.ECOC_PHASES = DNN_MODELS_SETTINGS{item_id}{7};
    DNN_MODELS{item_id}.N_BEST = DNN_MODELS_SETTINGS{item_id}{8};
end


% the reletive path of the files in matlab_code/ directory
DIR_PATHS.CAFFE_Prediction_DIR = '..'; 
DIR_PATHS.Preprocessed_Prediction_DIR = 'preprocessed_data'; 
DIR_PATHS.Results_DIR = 'results'; 
DIR_PATHS.BASELINE_TEST_DIR = 'BASELINE'; 


%setting for estimating the ensemble accuracy, the results averaged by 10
%times run or only 1 time run, the result of n1 / n phases (where n1 = 1,
%2, 3 , ... n or n1 = n only).
Ensemble_Results_Setting.Random_Num_Phase = 1; %default setting is 1
Ensemble_Results_Setting.Report_Last_OR_All = 'last'; %'all' or 'last' or with some interval.
%default report only the last, do report all for N-ary ECOC or future predicting the Ensemble accuracy


SimulateEAFlag = 0;

NumberOfFoldForCrossValidation = [7, 4, 6, 6 , 4, 6, 0,0,0,0,2]; %FLOWER102 should be set indepentaly
