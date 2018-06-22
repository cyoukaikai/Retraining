%items is the sorted class_labels (are sorted before pass to here)
%given the predictions of different models for one examples, count the
%frequency for each class label, then select the most unlikely predictions
%as the final prediction. repeat this process for all the examples.


function [Y, ensemble_predictions] = MinorityVoting_A(X , items )
Y = zeros( size(X,1),1 );
% items = sort( unique( X(:) ) ); %we can not use this stence, because if
% the prediciton are ill (the net do not learn), e.g., all the predictions are
% identical, then the items will be only 1 or several class members (not
% all the class members, it cause later program bug), so here we explictly
% pass the class labels (sorted) to this function.


ensemble_predictions = zeros( size(X,1), length(items) );
for i = 1 : size( X, 1)
    frequency = hist(X(i,:), items );
    [max_freq, I ] = min(frequency);
    Y(i) = items(I);
    ensemble_predictions(i,:) = frequency;
end





% Y = zeros( size(X,1),1 );
% for i = 1 : size( X, 1)
%     [frequency,item]=hist(X,unique(X));
%     [max_freq, I ] = max(frequency);
%     Y(i) = item(I);
% end





