%items is the sorted class_labels (are sorted before pass to here)
function [Y, ensemble_predictions] = WeightedMajorityVoting_A(X , vote_weights, items )
Y = zeros( size(X,1),1 );
% items = sort( unique( X(:) ) ); %we can not use this stence, because if
% the prediciton are ill (the net do not learn), e.g., all the predictions are
% identical, then the items will be only 1 or several class members (not
% all the class members, it cause later program bug), so here we explictly
% pass the class labels (sorted) to this function.


ensemble_predictions = zeros( size(X,1), length(items) );
for i = 1 : size( X, 1)
    %frequency = hist(X(i,:), items );
	% for the weighted voting, I have to count the frequency (combine with the weights) by myself.
	frequency = zeros(1, length(items) );
	for j = 1 : length( items)
		inds = find( X(i,:) == items(j) );
		frequency(j) = sum ( vote_weights(inds) );
	end
    [max_freq, I ] = max(frequency);
    Y(i) = items(I);
    ensemble_predictions(i,:) = frequency;
end





% Y = zeros( size(X,1),1 );
% for i = 1 : size( X, 1)
%     [frequency,item]=hist(X,unique(X));
%     [max_freq, I ] = max(frequency);
%     Y(i) = item(I);
% end





