# convert_mat_to_lmdb.py
# Modified by Alex King

# This file uses scipy and the pycaffe library to convert a .mat file
# (what SVHN provides) to LMDB, the filetype of choice for Caffe.

# Important: the output directory specified must be unique, or else
# data will be appended to existing files.

# Note: warnings are OK and may be ignored.

import scipy
from scipy import io
import math
import sys #use the exit() function
import numpy as np

def main():
    if len(sys.argv) != 6:
        print "Usage: python Adaboost_SAMME.py [pathDir] [base_learner_id]  [n_classes]  [predictionFilename] [realLabelFilename]"
        return 1

	#load prediction and real label
    y_predict = loadIntData( sys.argv[1] + '/' + sys.argv[4] )
    y = loadIntData( sys.argv[1] + '/' + sys.argv[5] )
    print "Prediction of training examples, y_predict[0:5]   = ", y_predict[0:5] 

    print  "GroundTruth of training examples,  y[0:5]   = ",y[0:5] 
    #check if weight is 'init', if yes, then create the initialize the weight and 
    if (int(sys.argv[2]) == 0):
        # Initialize weights to 1 / n_samples
        sample_weight = np.empty(y_predict.shape[0], dtype=np.float)
        sample_weight[:] = 1. / y_predict.shape[0]
    else:#otherwise, load the sample weights from weightFileName
        # Normalize existing weights
        sample_weight = loadFloatData( sys.argv[1] + '/D' + sys.argv[2] )

	#I should never normalize it when forward progating it, the normalization should be performed for only calculating the error (np.mean(np.average(, weights = sample_weight) aleady did it), not for updating the weights. If I do normalize it, it will causes round-off-error (too small that be discard during forward propagation). 
        #sample_weight = np.copy(sample_weight) / sample_weight.sum() 

    # Check that the sample weights sum is positive
    if sample_weight.sum() <= 0:
        raise ValueError("Attempting to fit with a non-positive "
                         "weighted number of samples.")
    print "sample_weight[0:5]  = ", sample_weight[0:5]   
    print "sample_weight.sum() = ", sample_weight.sum()  
    #estimate the new sample weights and base-learner-weight based on the prediction and real label
    n_classes = int(sys.argv[3])


    # Instances incorrectly classified
    incorrect = y_predict != y
    print "incorrect.sum() = ", incorrect.sum() 
    # Error fraction
    estimator_error = np.mean(np.average(incorrect, weights=sample_weight, axis=0))

    print "estimator_error = ", estimator_error 
    # Stop if classification is perfect
    if estimator_error <= 0:
        return 1

    # Stop if the error is at least as bad as random guessing
    if estimator_error >= 1. - (1. / n_classes):
        #self.estimators_.pop(-1)
        print "Stop, because the error is no good than random guessing" 
        return 1
    learning_rate = 1
    # Boost weight using multi-class AdaBoost SAMME alg
    estimator_weight = learning_rate * (
        np.log((1. - estimator_error) / estimator_error) +
        np.log(n_classes - 1.))
    print "estimator_weight = ", estimator_weight
    # Only boost the weights if I will fit again
    #if not iboost == self.n_estimators - 1:
    # Only boost positive weights
    sample_weight *= np.exp(estimator_weight * incorrect *
                                ((sample_weight > 0) |
                                 (estimator_weight < 0)))

    print " sample_weight.sum() = ", sample_weight.sum()
    #save the base-learner-weight and sample-weight
    base_learner_weight_file = ( sys.argv[1] + '/Alpha' + sys.argv[2] )
    print base_learner_weight_file
    print estimator_weight
    thefile = open(base_learner_weight_file, 'w')  
    thefile.write( str(estimator_weight)  + "\n")#+ "\t" + str(predicted_class)
    thefile.close()
    #np.savetxt(base_learner_weight_file, estimator_weight, fmt='%f')


    min_sample_weight = np.min(sample_weight)
    print " sample_weight.min() = ", min_sample_weight
    #decrease the sample weight in case they are too large to avoid overflow; as sample weight only increase, so do not need to avoid underflow.

    if min_sample_weight >  1  :
       print " min_sample_weight > 1  ", min_sample_weight
       sample_weight = np.copy(sample_weight) *  (1 / min_sample_weight)
    #else:
    #    print " min_sample_weight < 100  ", min_sample_weight
    #sample_weight[:] = np.copy(sample_weight) *  (1 / min_sample_weight)
    #min_sample_weight=np.min(sample_weight)
    print " sample_weight.min() = ", min_sample_weight


    sample_weight_file = ( sys.argv[1] + '/D' + str(int(sys.argv[2]) + 1 ))
    np.savetxt(sample_weight_file, sample_weight, fmt='%f')

    #sample_weight = np.copy(sample_weight) / sample_weight.sum()
    #sample_weight_file = ( sys.argv[1] + '/D' + str(int(sys.argv[2]) + 1 ) + '_normalized')
    #np.savetxt(sample_weight_file, sample_weight, fmt='%f')

    sample_weight = np.copy(sample_weight) / np.max(sample_weight)
    print " sample_weight.sum() before proper setting is  = ", sample_weight.sum()
    num_examples = y_predict.shape[0]
    iterate_num_min = 5 
    iterate_num_max = 200 #my setting, to speed up the process of generating the lmdb, I make the iteration number to be between iterate_num_min  and iterate_num_max. 

    #each time sampling at least push in 
    pushExamplesAtLeast = int( num_examples / iterate_num_max)
    pushExamplesAtMost = int( num_examples / iterate_num_min)
    print " pushExamplesAtLeast  = ", pushExamplesAtLeast, " pushExamplesAtMost  = ", pushExamplesAtMost

    if sample_weight.sum() <  pushExamplesAtLeast :
        ratio_amplify = math.ceil(pushExamplesAtLeast / sample_weight.sum() )
        sample_weight = np.copy(sample_weight) * ratio_amplify #set the max value to 10 based on relative weights

    if sample_weight.sum() >  pushExamplesAtMost :
        ratio_amplify = pushExamplesAtMost / sample_weight.sum() #must not a integer
        sample_weight = np.copy(sample_weight) * ratio_amplify #set the max value to 10 based on relative weights




    print " sample_weight.sum() after proper setting is  = ", sample_weight.sum()
    print " sample_weight.max() now is  = ", np.max(sample_weight)
    sample_weight_file = ( sys.argv[1] + '/D' + str(int(sys.argv[2]) + 1 )+ '_caffeUse')
    np.savetxt(sample_weight_file, sample_weight, fmt='%f')
    return 0


def loadIntData(filename) :
    print "load data from %s...\n" % filename
    data = []
    f = open(filename, "r")
    for line in f:
        #print line.split("\n")
        num = line.split("\n")[0] #the first element of the line is image name, and second element is the prediction label
        data.append( int(num) )
    f.close()
    return np.asarray( data ) 

def loadFloatData(filename) :
    print "load data from %s...\n" % filename
    data = []
    f = open(filename, "r")
    for line in f:
        #print line.split("\n")
        num = line.split("\n")[0] #the first element of the line is image name, and second element is the prediction label
        data.append( float(num) )
    f.close()
    return np.asarray( data ) 

if __name__ == '__main__':
    main()


#the following code is from /usr/share/pyshared/sklearn/ensemble/weight_boosting.py
'''
    def _boost_discrete(self, iboost, X, y, sample_weight):
        """Implement a single boost using the SAMME discrete algorithm."""
        estimator = self._make_estimator()

        try:
            estimator.set_params(random_state=self.random_state)
        except ValueError:
            pass

        estimator.fit(X, y, sample_weight=sample_weight)

        y_predict = estimator.predict(X)

        if iboost == 0:
            self.classes_ = getattr(estimator, 'classes_', None)
            self.n_classes_ = len(self.classes_)

        # Instances incorrectly classified
        incorrect = y_predict != y

        # Error fraction
        estimator_error = np.mean(
            np.average(incorrect, weights=sample_weight, axis=0))

        # Stop if classification is perfect
        if estimator_error <= 0:
            return sample_weight, 1., 0.

        n_classes = self.n_classes_

        # Stop if the error is at least as bad as random guessing
        if estimator_error >= 1. - (1. / n_classes):
            self.estimators_.pop(-1)
            return None, None, None

        # Boost weight using multi-class AdaBoost SAMME alg
        estimator_weight = self.learning_rate * (
            np.log((1. - estimator_error) / estimator_error) +
            np.log(n_classes - 1.))

        # Only boost the weights if I will fit again
        if not iboost == self.n_estimators - 1:
            # Only boost positive weights
            sample_weight *= np.exp(estimator_weight * incorrect *
                                    ((sample_weight > 0) |
                                     (estimator_weight < 0)))

        return sample_weight, estimator_weight, estimator_error
'''
