function ensemble_performance = MeanStdEnsemblePerformance_A(ensmeble_accuracy, oracle_accuracy)

ensemble_performance = zeros( size(ensmeble_accuracy,1), 4);
ensemble_performance(:,1) = mean(ensmeble_accuracy,2);
ensemble_performance(:,2) =std(ensmeble_accuracy,0,2);  
ensemble_performance(:,3) = mean(oracle_accuracy,2); 
ensemble_performance(:,4) = std(oracle_accuracy,0,2); 