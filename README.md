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
Caffe is typically designed for training a single DNN, rather than ensemble learning of DNNs, in which a large number of DNN base models may be needed to train.
Let N_M be the number of models to train for an ensmble learning method. When N_M is large (e.g., N_M = 100), manully training N_M DNNs may not be a good idea.
To deal with this issue, we use a shell script (namely, ) to automatically geneate the prototxt files (i.e., solver.prototxt and train_val.prototxt), train N_M DNNs and save the parameters (snapshots) of the trained DNNs.

 
Because of the following reasons, each method has a spearate file to configure the training data and their labels, the maximum number of iteratons, 
Different methods may have different requirement for preparing the training. For instance, Bagging, AdaBoost sample the training data randomly with replacement and based on incorrect/correct predictions of the earilier models, respectively; ECOC and N-ary ECOC change the output codes. 
Different methods may have different setting for the learning rate and its decay policy.


## Making predictions on test data for the trained base models 

## Combining votes 

Note that among the compared methods, (Group A) RI, RI-LongIters, Retraining, Bagging, AdaBoost, HV and SE do not need to change the output codes (i.e., change the class labels of data by, for instance,merging the classes into meta-classes), while (Group B) ECOC and N-ary ECOC needed. 

Basically, we do not need to modify the code to implement the Group A methods.

## Retraining 

## ECOC and N-ary ECOC

