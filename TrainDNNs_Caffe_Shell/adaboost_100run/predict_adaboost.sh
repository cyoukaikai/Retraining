#!/bin/bash

global_source_dir=~/caffe/examples/cifar100/benchmark/classify_caffe
global_record_date=2018-3-5
#$script_file $results_save_dir $results_save_file

phase_id_to_predict=$2
echo "[ the phase_id to run is " $phase_id_to_predict " ]"


extract_accuracy_loss() {
	script_file=$1 #5000, 10000 iter and so on
	results_save_dir_t=$2 #original_100run, bagging_100run and so on
	results_save_file_prefix_t=$3
	
	echo "[Extract the training accuracy for $script_file BEGIN.]"

	if [ ! -d $results_save_dir_t ]; then

		#echo "create $des_dir "
		echo "================================================================"
		mkdir $results_save_dir_t
		echo "create $results_save_dir_t done"
		echo "================================================================"
	fi

	grep 'caffe.cpp:292] accuracy =' < $script_file|  cut -d'=' -f2 | sed 's/ //' > $results_save_dir_t/"$results_save_file_prefix_t"-train-accu
	grep 'caffe.cpp:292] loss =' < $script_file|  cut -d'=' -f2 |  cut -d' ' -f2 | sed 's/ //' > $results_save_dir_t/"$results_save_file_prefix_t"-train-loss


	echo "[ Done ]"
	
}

predict() {
	test_source_dir=$1
	test_method_dir=$2 #original_100run, bagging_100run and so on
	test_iter_id=$3 #5000, 10000 iter and so on
	phase_id=$4 #test phases begin from (usually from 0)
	phase_id_end=$5 #test phases ends with (the maximum phase, mnist, 60; cifar10 100; svhn 200, and so on)
	test_total_iter=$6  #this equals to the (total number of test data) / (test batch-size)
	train_test_prototxt_file=$7 #e.g., train_val_cifar100_nin.prototxt
	echo "================================================================"
	echo "[TESTING $test_method_dir BEGIN, for the iteration of $test_iter_id.]"
	echo "Total number of phases is $phase_id_end"
	echo "================================================================"

	

	#solver_cifar100_nin_original_100run_99_num_output_100_iter_50000.caffemodel

	while [ $phase_id -lt $phase_id_end ]
	do
		echo "[Current phase_id is $phase_id, $phase_id/$phase_id_end]" #num_output =$num_output


		#./build/tools/caffe test -model examples/cifar100/benchmark/original_100run/train_val_cifar100_nin.prototxt -weights examples/cifar100/benchmark/original_100run/phase0/solver_cifar100_nin_original_100run_0_num_output_100_iter_30000.caffemodel -gpu 0 -iterations 2

		#this is for cifar10-full only
		# 

		#fine the train val prototxt file first, if 
		caffe_weight_file=`ls $test_source_dir/$test_method_dir/phase$phase_id/*_$test_iter_id.caffemodel*`
		echo $caffe_weight_file 
		#if [ -f  $caffe_weight_file ]
		#	echo 
		#else

		#fi
		./build/tools/caffe test -model $test_source_dir/$test_method_dir/$train_test_prototxt_file -weights $caffe_weight_file -gpu 0 -iterations $test_total_iter
		#---------------------------does not work
		#here we use a comom fixed $train_test_prototxt_file for the different phase_name_dir, now the prototxt file is for RI-encoding
		#and the prototxt file should be in the benchmark/ directory exactly.
		#./build/tools/caffe test -model $train_test_prototxt_file -weights $caffe_weight_file -gpu 0 -iterations $test_total_iter
		#-------------------------------------
		#for cifar10-full only
		#train_test_prototxt_file=`ls $test_source_dir/$test_method_dir/phase$phase_id/*cifar10_full_train_test*.prototxt`
		#./build/tools/caffe test -model $train_test_prototxt_file -weights $caffe_weight_file -gpu 0 -iterations $test_total_iter
		phase_id=$(($phase_id + 1)) #x=$($x+1) means x=$(0+1), while 0+1 is not a variable name
		
	done

	echo "================================================================"
	echo "[TESTING $test_method_dir END, for the iteration of $test_iter_id, Total number of phases $phase_id_end done.]"
	echo "================================================================"
}


#"Total number of phases is" and "Current phase_id is" are the symbols (signs) I put in the script to extract
extract_results() {
	output_dir=$1
	prediction_record_file=$2
	phase_id=$3
	total_phase=$4
	num_example=$5
	
	################################extract total phase from the script, not use this method any more
	#total_phase=`grep 'Total number of phases is' < $prediction_record_file | cut -d' ' -f6`
	#echo "total_phase = $total_phase"
	###############################$


	if [ -d $global_source_dir/$output_dir ]
	then
		echo "##############################caution"
		echo "the target directory $global_source_dir/$output_dir already exists, skip create it..."
		echo "##############################do you rewrite the directory of the previous predictions"
	else
		#echo "create $des_dir "
		mkdir $global_source_dir/$output_dir
		echo "create $global_source_dir/$output_dir done"
	fi


	#make the real_label file
	#sed -n "/Current phase_id is $phase_id,/,/Current phase_id is $phase_id_next,/ s|prediction =  |&|p" < $prediction_record_file | cut -d']' -f2 | cut -d',' -f2 | sed 's/real_label =//' | sed 's/ //' | tac | head -$num_example | tac > $global_source_dir/$output_dir/real_label.txt
	#make the test example_id file
	#sed -n "/Current phase_id is $phase_id,/,/Current phase_id is $phase_id_next,/ s|cursor->key():|&|p" < $prediction_record_file | cut -d']' -f2 | cut -d':' -f2 | sed 's/ //' | tac | head -$num_example | tac > $global_source_dir/$output_dir/example_id.txt 
	#sed -n '/Current phase_id is 0/,/Current phase_id is 1/   s|cursor->key():|&|p' < examples/cifar100/benchmark/classify_caffe/CIFAR100-NIN/original_100run-2017-3-3test | cut -d']' -f2 | cut -d':' -f2 | sed 's/ //' | tac | head -10000 | tac 

#modify -2017-12-5 just extract the first $num_example prediction, real_label, and example_id is good, I don't understant why I used tac | tac twice.
#using tac | tac twice is to extract the last $num_example, but it may cause problem if different method use different batch size but are forced to make ensemble (while I did notice such a case, in that case, the ensemble accuracy may be decreased).
# tac | | tac

	#make the test example_id file
	#sed -n "/Current phase_id is $phase_id,/,/Current phase_id is $phase_id_next,/ s|cursor->key():|&|p" < $prediction_record_file | cut -d']' -f2 | cut -d':' -f2 | sed 's/ //' | head -$num_example > $global_source_dir/$output_dir/example_id.txt
#| tac | head -$num_example | tac
	while [ $phase_id -lt $total_phase ]
	do
		echo "[Current phase_id is $phase_id, $phase_id/$phase_id_end]" #num_output =$num_output
		phase_id_next=$(($phase_id + 1)) #x=$($x+1) means x=$(0+1), while 0+1 is not a variable name

		#top-1 prediction
		#sed -n "/Current phase_id is $phase_id,/,/Current phase_id is $phase_id_next,/ s|prediction =  |&|p" < $prediction_record_file | cut -d"]" -f2 | cut -d"," -f1 | sed "s/prediction =  //" | sed "s/ //" | head -$num_example  > $global_source_dir/$output_dir/prediction_$phase_id.txt
#| tac | head -$num_example | tac
	
		grep 'prediction =' < $prediction_record_file | cut -d'=' -f2 | cut -d',' -f1 | sed 's/ //'  | head -$num_example  > $global_source_dir/$output_dir/prediction_$phase_id.txt

		grep 'real_label =' < $prediction_record_file  | cut -d'=' -f3 | head -$num_example  > $global_source_dir/$output_dir/real_label.txt

		#sed -n "/Current phase_id is $phase_id,/,/Current phase_id is $phase_id_next,/ s|prediction =  |&|p" < $prediction_record_file | cut -d']' -f2 | cut -d',' -f2 | sed 's/real_label =//' | sed 's/ //' | head -$num_example  > $global_source_dir/$output_dir/real_label.txt
		#sed -n "/Current phase_id is $phase_id,/,/Current phase_id is $phase_id_next,/ s|sorted predictions = |&|p" < $prediction_record_file | cut -d"]" -f2 | cut -d"=" -f2 | sed "s/ //"|  tac | head -$num_example | tac > $global_source_dir/$output_dir/prediction_$phase_id.txt


		phase_id=$phase_id_next #x=$($x+1) means x=$(0+1), while 0+1 is not a variable name
		
	done
}




#input: a script reording a lot of sub recording
extract_multi_recording(){
	global_record_file_this=$1
	key_word_this=$2
	phase_id_str_this=$3
	phase_id_end_this=$4
	dataset_dir_this=$5	
	num_example=$6
	
	output_dir_input_this=$dataset_dir_this/$key_word_this
	prediction_record_file_input_this=$global_source_dir/$dataset_dir_this/$key_word_this"_extracted_recording.script"  
	#$key_word_this"_extracted_recording.script"
	#TESTING original_100run_different_init BEGIN,
	echo $output_dir_input_this
	echo $prediction_record_file_input_this
	echo $global_record_file_this
	sed -n "/$key_word_this BEGIN,/,/$key_word_this END,/p"  < $global_record_file_this  > $prediction_record_file_input_this
	extract_results $output_dir_input_this $prediction_record_file_input_this $phase_id_str_this $phase_id_end_this $num_example
	rm $prediction_record_file_input_this
}

PredictTrainingAccuracy () {
	source_dir=$1
	phase_name_dir=$2
	dataset_dir=$3
	phase_id_str=$4
	phase_id_max=$5
	train_test_prototxt_original_prefix=$6
	iter_caffemodel_for_prediction=$7
	total_iteration=$8
	total_num_example=$9
	record_date=${10}
	test_method_dir=${11}


	#phase_id_str=$phase_id_to_predict
	#phase_id_max=$(($phase_id_str + 1)) #99

	
	#phase_id=$phase_id_str	
	#while [ $phase_id -lt $phase_id_end ]
	#do
	script_file=$global_source_dir/$dataset_dir/TRAINING-ACCURACY-$test_method_dir-phase-"$phase_id_str"-to-$phase_id_max-iter-$iter_caffemodel_for_prediction-pred-recording-$record_date

	train_test_prototxt_original=$train_test_prototxt_original_prefix".prototxt"
	train_test_prototxt=$train_test_prototxt_original_prefix-check-train-accu.prototxt 
	full_source_file=$source_dir/$phase_name_dir/$train_test_prototxt_original
	full_target_file=$source_dir/$phase_name_dir/$train_test_prototxt

	if [ -f $full_target_file ]
	then
		echo "##############################caution"
		echo "the target directory $full_target_file already exists, remove it..."
		echo "##############################do you rewrite the directory of the previous predictions"
		rm $full_target_file
	#else

	fi
	#regenerate the files (if we always skip creating the file, we may meet the bugs wherein the old (but incorrect) file is there that you can not create new file.
	source_train_lmdb=`sed -n "/phase: TRAIN/,/phase: TEST/p" < $full_source_file | sed -n "/source.*/p"`
	echo source_train_lmdb = $source_train_lmdb

	source_test_lmdb=`sed -n "/phase: TEST/,/backend: LMDB/p" < $full_source_file | sed -n "/source.*/p"`
	echo source_test_lmdb = $source_test_lmdb

	sed -e "/phase: TRAIN/,/phase: TEST/ s|source.*|$source_test_lmdb|" \
		-e "/phase: TEST/,/backend: LMDB/ s|source.*|$source_train_lmdb|" \
	< $full_source_file > $full_target_file


	#done
	predict $source_dir $phase_name_dir $iter_caffemodel_for_prediction $phase_id_str $phase_id_max $total_iteration $train_test_prototxt |& tee $script_file

	#test_method_dir=$phase_name_dir
	extract_multi_recording $script_file $test_method_dir $phase_id_str $phase_id_max $dataset_dir $total_num_example

}

classify_cifar10_quick() {
	dataset=cifar10
	source_dir=~/caffe/examples/$dataset/benchmark-cifar10-quick
	dataset_dir=CIFAR10-QUICK
	total_num_example=50000
	total_iteration=500 
	train_test_prototxt_original_prefix=cifar10_quick_train_test
	phase_id_str=$phase_id_to_predict
	phase_id_max=$(($phase_id_str + 1)) #99
	phase_name_dir=adaboost_100run

	iter_caffemodel_for_prediction=5000
	test_method_dir=$phase_name_dir

	echo $global_record_date
	PredictTrainingAccuracy  $source_dir $phase_name_dir $dataset_dir $phase_id_str $phase_id_max $train_test_prototxt_original_prefix $iter_caffemodel_for_prediction $total_iteration $total_num_example $global_record_date $test_method_dir

}

classify_cifar100_quick() {
	dataset=cifar10
	source_dir=~/caffe/examples/$dataset/benchmark-cifar100-cifar10-quick
	dataset_dir=CIFAR100-QUICK
	total_num_example=50000
	total_iteration=500 
	train_test_prototxt_original_prefix=cifar10_quick_train_test
	phase_id_str=$phase_id_to_predict
	phase_id_max=$(($phase_id_str + 1)) #99
	phase_name_dir=adaboost_100run



	iter_caffemodel_for_prediction=10000
	test_method_dir=$phase_name_dir

	echo $global_record_date
	PredictTrainingAccuracy  $source_dir $phase_name_dir $dataset_dir $phase_id_str $phase_id_max $train_test_prototxt_original_prefix $iter_caffemodel_for_prediction $total_iteration $total_num_example $global_record_date $test_method_dir

}
classify_cifar10_full() {
	dataset=cifar10
	source_dir=~/caffe/examples/$dataset/benchmark-cifar10-full
	dataset_dir=CIFAR10-FULL
	total_num_example=50000
	total_iteration=500 
	train_test_prototxt_original_prefix=cifar10_full_train_test

	phase_id_str=$phase_id_to_predict
	phase_id_max=$(($phase_id_str + 1)) #99
	phase_name_dir=adaboost_100run

	iter_caffemodel_for_prediction=70000
	test_method_dir=$phase_name_dir

	echo $global_record_date
	PredictTrainingAccuracy  $source_dir $phase_name_dir $dataset_dir $phase_id_str $phase_id_max $train_test_prototxt_original_prefix $iter_caffemodel_for_prediction $total_iteration $total_num_example $global_record_date $test_method_dir

}




classify_svhn_quick() {
	dataset=svhn
	source_dir=~/caffe/examples/$dataset/benchmark
	dataset_dir=SVHN-QUICK
	total_num_example=73257
	total_iteration=733 
	train_test_prototxt_original_prefix=svhn_quick_train_test

	phase_id_str=$phase_id_to_predict
	phase_id_max=$(($phase_id_str + 1)) #99
	phase_name_dir=adaboost_100run

	iter_caffemodel_for_prediction=6000
	test_method_dir=$phase_name_dir

	echo $global_record_date
	PredictTrainingAccuracy  $source_dir $phase_name_dir $dataset_dir $phase_id_str $phase_id_max $train_test_prototxt_original_prefix $iter_caffemodel_for_prediction $total_iteration $total_num_example $global_record_date $test_method_dir

}

classify_mnist_RI_bagging() {
	dataset=mnist
	source_dir=~/caffe/examples/$dataset/benchmark

	dataset_dir=MNIST
	#(total number of test data  = 10000), / (test batch-size = 100)

	#(total number of train data  = 60000), / (test batch-size = 100)
	total_iteration=600 #this equals to the (total number of test data) / (test batch-size)

	iter_caffemodel_for_prediction=10000
        total_num_example=60000




#worked code
<<COMMMENT20180226
	#source: "examples/mnist/mnist_adaboost_lmdb/mnist_train_adaboost_0_lmdb"
	#source: "examples/mnist/mnist_test_lmdb"


	source_train_lmdb=`sed -n "/phase: TRAIN/,/phase: TEST/p" < examples/mnist/benchmark/adaboost_100run/phase0/lenet_train_test_adaboost_100run_0_num_output_10.prototxt | sed -n "/source.*/p"`
	echo source_train_lmdb = $source_train_lmdb

	source_test_lmdb=`sed -n "/phase: TEST/,/backend: LMDB/p" < examples/mnist/benchmark/adaboost_100run/phase0/lenet_train_test_adaboost_100run_0_num_output_10.prototxt | sed -n "/source.*/p"`
	echo source_test_lmdb = $source_test_lmdb

	sed -e "/phase: TRAIN/,/phase: TEST/ s|source.*|$source_test_lmdb|" \
		-e "/phase: TEST/,/backend: LMDB/ s|source.*|$source_train_lmdb|" \
< examples/mnist/benchmark/adaboost_100run/phase0/lenet_train_test_adaboost_100run_0_num_output_10.prototxt > examples/mnist/benchmark/adaboost_100run/phase0/lenet_train_test-check-train-accu.prototxt 

COMMMENT20180226
	
	phase_id_str=$phase_id_to_predict
	phase_id_max=$(($phase_id_str + 1)) #99
	phase_name_dir=adaboost_100run
	
	phase_id=$phase_id_to_predict		
	#while [ $phase_id -lt $phase_id_end ]
	#do
	script_file=$global_source_dir/$dataset_dir/TRAINING-ACCURACY-Adaboost-phase-"$phase_id"-pred-recording-$record_date

	train_test_prototxt_original=lenet_train_test.prototxt
	train_test_prototxt=lenet_train_test-check-train-accu.prototxt 
	full_source_file=$source_dir/$phase_name_dir/$train_test_prototxt_original
	full_target_file=$source_dir/$phase_name_dir/$train_test_prototxt

	if [ -f $full_target_file ]
	then
		echo "##############################caution"
		echo "the target directory $full_target_file already exists, skip create it..."
		echo "##############################do you rewrite the directory of the previous predictions"
	else
		source_train_lmdb=`sed -n "/phase: TRAIN/,/phase: TEST/p" < $full_source_file | sed -n "/source.*/p"`
		echo source_train_lmdb = $source_train_lmdb

		source_test_lmdb=`sed -n "/phase: TEST/,/backend: LMDB/p" < $full_source_file | sed -n "/source.*/p"`
		echo source_test_lmdb = $source_test_lmdb

		sed -e "/phase: TRAIN/,/phase: TEST/ s|source.*|$source_test_lmdb|" \
			-e "/phase: TEST/,/backend: LMDB/ s|source.*|$source_train_lmdb|" \
	< $full_source_file > $full_target_file
	fi

	


	#done
	predict $source_dir $phase_name_dir $iter_caffemodel_for_prediction $phase_id_str $phase_id_max $total_iteration $train_test_prototxt |& tee $script_file

	test_method_dir=$phase_name_dir
	extract_multi_recording $script_file $test_method_dir $phase_id_str $phase_id_max $dataset_dir $total_num_example

	
}


classify_flower102_finetune_AlexNet() {
	dataset=oxford_flowers
	source_dir=~/caffe/examples/$dataset/benchmark
	phase_id_str=0
	phase_id_max=60 #99
	dataset_dir=FLOWER102-ALEXNET-FINETUNE
	#(total number of test data  = 1024), / (test batch-size = 64)
	total_iteration=16 #this equals to the (total number of test data) / (test batch-size)
	
	#(total number of test data  = 6149), / (test batch-size = 64)
	#total_iteration=100 #this equals to the (total number of test data) / (test batch-size)
	total_num_example = 1020
	train_test_prototxt_original_prefix=train_val

	iter_caffemodel_for_prediction=10000
	phase_name_dir=original_100run
test_method_dir=$phase_name_dir

	echo $global_record_date
	#PredictTrainingAccuracy  $source_dir $phase_name_dir $dataset_dir $phase_id_str $phase_id_max $train_test_prototxt_original_prefix $iter_caffemodel_for_prediction $total_iteration $total_num_example $global_record_date $test_method_dir



}




classify_cifar100_nin() {
	dataset=cifar100
	source_dir=~/caffe/examples/$dataset/benchmark
	phase_id_str=0
	phase_id_max=100 #99
	total_iteration=1000 #this equals to the (total number of test data) / (test batch-size)

	iter_caffemodel_for_prediction=50000


	dataset_dir=CIFAR100-NIN
	total_num_example=50000
	train_test_prototxt_original_prefix=train_val_cifar100_nin
	phase_id_str=$phase_id_to_predict
	phase_id_max=$(($phase_id_str + 1)) #99
	phase_name_dir=adaboost_100run
	test_method_dir=$phase_name_dir

	echo $global_record_date
	PredictTrainingAccuracy  $source_dir $phase_name_dir $dataset_dir $phase_id_str $phase_id_max $train_test_prototxt_original_prefix $iter_caffemodel_for_prediction $total_iteration $total_num_example $global_record_date $test_method_dir
}



echo "Input parameter [ $1 ] "
case "$1" in
	cifar10-quick) # | [Yy][Ee][Ss] ) 	
		classify_cifar10_quick 
		;;
	cifar100-quick) # | [Yy][Ee][Ss] ) 	
		classify_cifar100_quick 
		;;
	svhn)  	
		classify_svhn_quick
		;;
	cifar10-full) # | [Yy][Ee][Ss] ) 	
		classify_cifar10_full
		;;
	cifar100-nin) # | [Yy][Ee][Ss] ) 	
		classify_cifar100_nin
		;;
	cifar100-densenet) # | [Yy][Ee][Ss] ) 	
		classify_cifar100_densenet
		;;
	flower102) # | [Yy][Ee][Ss] ) 	
		classify_flower102_finetune_AlexNet
		;;
	mnist)  	
		classify_mnist_RI_bagging
		;;
	imagenet-nin)  	
		classify_imagenet_nin
		;;
	* ) 			
		echo  "Sorry, $1 not rcognized. Enter  cifar10-quick svhn"
		exit 1
		;; 
	#not "*" , which will only match the string *, not any string
esac










