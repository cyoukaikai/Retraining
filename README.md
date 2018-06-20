# This file explains how I trained deep neural networks for my proposed method "retraining" and several other ensemble learning methods. 
In the manuscript entitled "Retraining: A Simple Way to Improve the Ensemble Accuracy of Deep Neural Networks for Image Classification" (ICPR 2018, accepted for publication), we tested eight DNN models (MNIST-LeNet, CIFAR10-QUICK, CIFAR100-QUICK, SVHN, CIFAR100-NIN, CIFAR100-DenseNet40, FLOWER102-AlexNet and ILSVRC2012-NIN). 
We implemented the following methods in the Caffe framework: our retraining, the ensemble of DNNs trained with random initializations (RI), RI that uses the same number of iteration as retraining (RI-LongIters), Bagging, AdaBoost, error correcting output codes (ECOC), N-ary ECOC, horizontal voting (HV) and snapshot ensemble (SE).

Among the compared methods, (Group A) RI, RI-LongIters, Retraining, Bagging, AdaBoost, HV and SE do not need to change the output codes (i.e., change the class labels of data, for instance, by mering the classes into meta-classes), while (Group B) ECOC and N-ary ECOC needed. 


