# Retraining: A Simple Way to Improve the Ensemble Accuracy of Deep Neural Networks for Image Classification
This repository contains the code (Caffe + Shell + Matlab) for the conducted experiments in the paper "Retraining: A Simple Way to Improve the Ensemble Accuracy of Deep Neural Networks for Image Classification" (ICPR 2018, accepted for publication).

Ensemble learning is an often used technique to improve the classification accuracy of a single classifier. It trains
a number of classifiers called base models (or base learners) and combines them to make predictions.

We implemented the following ensemble learning methods in the Caffe framework: our retraining, the ensemble of DNNs trained with random initializations (RI), RI that uses the same number of iteration as retraining (RI-LongIters), Bagging, AdaBoost, error correcting output codes (ECOC), N-ary ECOC, horizontal voting (HV) and snapshot ensemble (SE).

We tested eight DNN models, MNIST-LeNet, CIFAR10-QUICK, CIFAR100-QUICK, SVHN, CIFAR100-NIN, CIFAR100-DenseNet40, FLOWER102-AlexNet and ILSVRC2012-NIN. 

An ensemble learning method typically consistes the following steps. 

1. Training base models using training data
2. Making predictions on test data for the trained base models 
3. Combining votes 

Below we will beriefly explain how we conducted these three steps. 

## Training base models using training data
There are two issues related to training a number of DNNs for the compared enesmble learning methods. 

1). efficiently training DNNs
2). preparing the training data for Bagging, AdaBoost, ECOC, N-ary ECOC

For Issue 1, Caffe is originally designed for training a single DNN rather than training a number of DNNs.
Let N_M be the number of models to train for an ensmble learning method. When $N_M$ is large (e.g., $N_M$ = 100), manully training N_M DNNs may not be a good idea.
To deal with this issue, we use a shell script (namely, create_benchmark_phase-prototxt.sh) to automatically geneate the prototxt files (i.e., solver.prototxt and train_val.prototxt), train N_M DNNs and save the parameters (snapshots) of the trained DNNs.
The idea of using a shell script is applied to all the compared methods.
By using the Shell script, we can set where to load the training data and their labels, the maximum number of iteratons (RI-LongIters ), the initial learning rates and its decay policy, the number ($N_M$) of base models to train, the number (N_R) of rounds to train (N_R = 1 in default, but for Retraining, Snapshot, RI-LongIters, N_R > 1) and so on.  


For Issue 2, Bagging, AdaBoost, ECOC, N-ary ECOChave different requirement for preparing the training. 
Bagging, AdaBoost sample the training data randomly with replacement and based on incorrect/correct predictions of the earilier models, respectively; ECOC and N-ary ECOC change the output codes. 
We provide the files to generate the training data for Bagging and AdaBoost in the directory bagging_100run and adaboost_100run, respectively. 

The base models of ECOC and N-ary ECOC are trained (estimating the loss and gradients) using meta-class labels rather than class labels. Each base model has different encoding information (the way of merging classes into meta-classes). 


## Making predictions on test data for the trained base models 

We can use the Caffe python interface to make predictions. However, we have to specify how to conduct the processing, which is defined in the train_val.prototxt file, in the resulting Python code for each DNNs. 

We instead can display and record the predictions of Caffe in a log file and later extract the predictions using the Shell script.
An advantage of this solution is that different DNNs can use the same precesses.


## Combining votes 

The files in  CombineVotes_Matlab  contains the following functionalities.


- majority voting
- weighted voting
- minimum Hamming distance
- weighted Hamming distance
- combined_voting
- extract_results (for comparing different methods).

The workflow is 
1. load the predictions into mat format 
2. make ensemble predictions 
3. save results 



