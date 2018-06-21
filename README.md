# Retraining: A Simple Way to Improve the Ensemble Accuracy of Deep Neural Networks for Image Classification
This repository contains the Caffe code and Shell scripts for the conducted experiments in the paper "Retraining: A Simple Way to Improve the Ensemble Accuracy of Deep Neural Networks for Image Classification" (ICPR 2018, accepted for publication).

We implemented the following methods in the Caffe framework: our retraining, the ensemble of DNNs trained with random initializations (RI), RI that uses the same number of iteration as retraining (RI-LongIters), Bagging, AdaBoost, error correcting output codes (ECOC), N-ary ECOC, horizontal voting (HV) and snapshot ensemble (SE).

We tested eight DNN models (MNIST-LeNet, CIFAR10-QUICK, CIFAR100-QUICK, SVHN, CIFAR100-NIN, CIFAR100-DenseNet40, FLOWER102-AlexNet and ILSVRC2012-NIN). 

Ensemble learning trains a number of classifiers (called base models or base learners) and conbime them to make predictions. An ensemble learning method typically consistes the floowing steps. 

0. Training base models using training data
1. Making predictions on test data for the trained base models 
2. Combining votes

Here we only explain the first step, i.e., how I traine a large number of deep neural networks for my proposed method "retraining" and the compared methods. The codes for Step 2 and Step 3 are provided here [step 2 Caffe + Shell] [step 3 Matlab].
Below we use CIFAR10-QUICK as an example to explain the training processes.
 
Note that among the compared methods, (Group A) RI, RI-LongIters, Retraining, Bagging, AdaBoost, HV and SE do not need to change the output codes (i.e., change the class labels of data, for instance, by mering the classes into meta-classes), while (Group B) ECOC and N-ary ECOC needed. 

## Retraining 

## ECOC and N-ary ECOC

