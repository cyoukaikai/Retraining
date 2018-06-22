#!/bin/sh


dataset=cifar10
EXAMPLE=examples/$dataset
source_dir=~/caffe/examples/$dataset/benchmark
phase_name_dir=adaboost_100run

num_class=10

phase_id_str=0
phase_id_end=100 #99
	
	phase_id=$phase_id_str
	while [ $phase_id -lt $phase_id_end ]
	do
		#echo $phase_id
		echo $phase_id/$phase_id_end = "$phase_id" 
		#run 
		cd ~/caffe-worked
		chmod +x ./examples/$dataset/benchmark/adaboost_100run/create_benchmark_phase-prototxt.sh
		./examples/$dataset/benchmark/adaboost_100run/create_benchmark_phase-prototxt.sh $phase_id

		cd ~/caffe-predict
		chmod +x ./examples/cifar100/benchmark/classify_caffe/predict_adaboost.sh
		./examples/cifar100/benchmark/classify_caffe/predict_adaboost.sh cifar10-quick $phase_id

		#based on the prediction and real label, generate the new sample weights
		cd ~/caffe-worked
		python ./examples/cifar100/benchmark/classify_caffe/Adaboost_SAMME.py ./examples/cifar100/benchmark/classify_caffe/CIFAR10-QUICK/adaboost_100run $phase_id $num_class prediction_"$phase_id".txt real_label.txt 
	

		phase_id=$(($phase_id + 1)) #x=$($x+1) means x=$(0+1), while 0+1 is not a variable name
		
		cd ~/caffe-cross-validation
		chmod +x ./examples/$dataset/create_"$dataset"_adaboost.sh
		./examples/$dataset/create_"$dataset"_adaboost.sh $phase_id ./examples/cifar100/benchmark/classify_caffe/CIFAR10-QUICK/adaboost_100run/D"${phase_id}"_caffeUse

	done



