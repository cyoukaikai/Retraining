#!/bin/bash


global_source_dir=examples/cifar100/benchmark/classify_caffe #global variable
global_record_date=2018-6-12
record_date=$global_record_date



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


		#fine the train val prototxt file first, if 
		caffe_weight_file=`ls $test_source_dir/$test_method_dir/phase$phase_id/*_$test_iter_id.caffemodel*`
		echo $caffe_weight_file 
		#if [ -f  $caffe_weight_file ]
		#	echo 
		#else

		#fi
#./build/tools/caffe test -model examples/imagenet/benchmark/original_100run-AlexNet/train_val.prototxt -weights examples/imagenet/benchmark/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel -gpu 0 -iterations 1
		./build/tools/caffe test -model $test_source_dir/$test_method_dir/$train_test_prototxt_file -weights $caffe_weight_file -gpu 0 -iterations $test_total_iter

		phase_id=$(($phase_id + 1)) #x=$($x+1) means x=$(0+1), while 0+1 is not a variable name
		
	done

	echo "================================================================"
	echo "[TESTING $test_method_dir END, for the iteration of $test_iter_id, Total number of phases $phase_id_end done.]"
	echo "================================================================"
}



Snapshot_ensemble_prediction() {
	#special settings here
	experiments_flag_prediction_RI $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} 
}

Horizontal_voting_prediction() {
	#special settings here 
	experiments_flag_prediction_RI $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} $test_method_dir $retrain_suffix
}

EXPERIMENTS_FLAG_prediction_general() {
	EXPERIMENTS_FLAG=$6 #HV
	for ele in ${!EXPERIMENTS_FLAG[@]}; do
		experiments_flag=${EXPERIMENTS_FLAG[ele]}
		echo $experiments_flag
		experiments_flag_prediction_RI $1 $2 $3 $4 $5 $experiments_flag $7 $8 $9 ${10} ${11} ${12} ${13} 
	done

}

predict_single_directory(){
	dataset=$1 #oxford_flowers
	source_dir=$2 #~/caffe/examples/$dataset/benchmark
	phase_id_str=$3 #0
	phase_id_max=$4 #100
	dataset_dir=$5 #FLOWER102-ALEXNET-SCRATCH
	experiments_flag=$6 
	test_method_dir=$7 #original_100run, ECOC2, bagging_100run
	iter_cur_fixed=$8 #10000
	iter_end=$9 #60001 
	iter_iterval=${10} #(500 1000 1000 1000 1000 1000 1000 1000 1000 1000)
	total_iteration=${11}
	train_test_prototxt=${12}
	record_date=${13}
	save_method_flag=${14} #original_100run, bagging_100run and so on used for multiple-retraining
	#retrain_suffix=${15} #retrain1, 2,  ... or pretrained1, 2, or ...

		phase_name_dir="$experiments_flag"/$test_method_dir
		echo $phase_name_dir

		iter_cur=$iter_cur_fixed
		while [[ $iter_cur -lt $iter_end ]]
		do	
			script_file_name=$global_source_dir/$dataset_dir/"$save_method_flag"-"$test_method_dir"_$iter_cur-iter-pred-recording-$record_date
			echo $script_file_name
			echo $iter_cur $iter_end $iter_iterval
			predict $source_dir $phase_name_dir $iter_cur $phase_id_str $phase_id_max $total_iteration $train_test_prototxt |& tee $script_file_name
			extract_multi_recording $script_file_name $test_method_dir $phase_id_str $phase_id_max $dataset_dir $total_num_example
			#mv $source_dir/$dataset_dir/$test_method_dir $source_dir/$dataset_dir/"$test_method_dir"_$iter_cur
			#ln -s $source_dir/$dataset_dir/"$test_method_dir"_$iter_cur  $source_dir/$dataset_dir/$test_method_dir
			iter_cur=$(($iter_cur + $iter_iterval))	
		done
}

experiments_flag_prediction_general() {
	dataset=$1 #oxford_flowers
	source_dir=$2 #~/caffe/examples/$dataset/benchmark
	phase_id_str=$3 #0
	phase_id_max=$4 #100
	dataset_dir=$5 #FLOWER102-ALEXNET-SCRATCH
	experiments_flag=$6 #HV
	RETRAIN_IDs=$7 #(0 60) # retrain_id_str and retrain_id_end
	iter_cur_fixed=$8 #10000
	iter_end=$9 #60001 
	iter_iterval=${10} #(500 1000 1000 1000 1000 1000 1000 1000 1000 1000)
	total_iteration=${11}
	train_test_prototxt=${12}
	record_date=${13}
	test_method_dir=${14} #original_100run, bagging_100run and so on used for multiple-retraining
	retrain_suffix=${15} #retrain1, 2,  ... or pretrained1, 2, or ...


	test_method_prefix_final=$test_method_dir"$retrain_suffix"
	#test_method_dir + retrain_suffix = original_100run_retrain, or, bagging_100run_retrain, or ECOC2_pretrained_ this is what I mean general
		
	

		echo $experiments_flag
		retrain_id=${RETRAIN_IDs[0]} #${ITER_STRs[index]}
		retrain_id_end=${RETRAIN_IDs[1]}
		echo retrain_id_end = $retrain_id_end 

		while [[ $retrain_id -lt $retrain_id_end ]]
		do
			echo retrain_id = "$retrain_id" iter_cur ="$iter_cur"  iter_end ="$iter_end"  iter_iterval ="$iter_iterval"
	
			phase_name_dir=$experiments_flag/$test_method_prefix_final"$retrain_id"


			iter_cur=$iter_cur_fixed
			while [[ $iter_cur -lt $iter_end ]]
			do	
				echo $iter_cur $iter_end $iter_iterval
				predict $source_dir $phase_name_dir $iter_cur $phase_id_str $phase_id_max $total_iteration $train_test_prototxt |& tee $global_source_dir/$dataset_dir/"$experiments_flag"_$test_method_prefix_final"$retrain_id"_$iter_cur-iter-pred-recording-$record_date
				iter_cur=$(($iter_cur + $iter_iterval))	
			done

			retrain_id=$(($retrain_id + 1))	
		done

}
experiments_flag_prediction_RI() {
	test_method_dir=original_100run #original_100run, bagging_100run and so on used for multiple-retraining
	retrain_suffix="_retrain" #retrain1, 2,  ... or pretrained1, 2, or ...
	experiments_flag_prediction_general $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} $test_method_dir $retrain_suffix
}

#default, retraining is for RI-retraining
experiments_flag_prediction() {
	experiments_flag_prediction_RI $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13}
}

experiments_flag_prediction_ECOC() {
	test_method_dir=${14} #original_100run, bagging_100run and so on used for multiple-retraining
	retrain_suffix="_pretrained_" #retrain1, 2,  ... or pretrained1, 2, or ...
	experiments_flag_prediction_general $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} $test_method_dir $retrain_suffix
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


	
	sed -n "/Current phase_id is $phase_id,/,/Current phase_id is $phase_id_next,/ s|prediction =  |&|p" < $prediction_record_file | cut -d']' -f2 | cut -d',' -f2 | sed 's/real_label =//' | sed 's/ //' | head -$num_example  > $global_source_dir/$output_dir/real_label.txt
	#make the test example_id file
	sed -n "/Current phase_id is $phase_id,/,/Current phase_id is $phase_id_next,/ s|cursor->key():|&|p" < $prediction_record_file | cut -d']' -f2 | cut -d':' -f2 | sed 's/ //' | head -$num_example > $global_source_dir/$output_dir/example_id.txt
#| tac | head -$num_example | tac
	while [ $phase_id -lt $total_phase ]
	do
		echo "[Current phase_id is $phase_id, $phase_id/$phase_id_end]" 
		phase_id_next=$(($phase_id + 1)) #x=$($x+1) means x=$(0+1), while 0+1 is not a variable name

		#top-1 prediction
		sed -n "/Current phase_id is $phase_id,/,/Current phase_id is $phase_id_next,/ s|prediction =  |&|p" < $prediction_record_file | cut -d"]" -f2 | cut -d"," -f1 | sed "s/prediction =  //" | sed "s/ //" | head -$num_example  > $global_source_dir/$output_dir/prediction_$phase_id.txt
#| tac | head -$num_example | tac



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
	sed -n "/$key_word_this BEGIN,/,/$key_word_this END,/p"  < $global_record_file_this  > $prediction_record_file_input_this
	extract_results $output_dir_input_this $prediction_record_file_input_this $phase_id_str_this $phase_id_end_this $num_example
	rm $prediction_record_file_input_this
}


batch_collect_results_EXPERIMENTS_FLAG() {
	dataset=$1 #oxford_flowers
	global_source_dir=$2 #~/caffe/examples/$dataset/benchmark
	phase_id_str=$3 #0
	phase_id_end=$4 #100
	dataset_dir=$5 #FLOWER102-ALEXNET-SCRATCH
	EXPERIMENTS_FLAG=$6 #HV
	RETRAIN_IDs=$7 #(0 60) # retrain_id_str and retrain_id_end
	iter_cur_fixed=$8 #10000
	iter_end=$9 #60001 
	iter_iterval=${10} #(500 1000 1000 1000 1000 1000 1000 1000 1000 1000)
	total_num_example=${11}
	train_test_prototxt=${12}
	record_date=${13}

for ele in ${!EXPERIMENTS_FLAG[@]}; do
	experiments_flag=${EXPERIMENTS_FLAG[ele]}
	echo $experiments_flag
	batch_collect_results_experiments_flag  $1 $2 $3 $4 $5 $experiments_flag $7 $8 $9 ${10} ${11} ${12} ${13} 
done
}


batch_collect_results_experiments_flag () {
	dataset=$1 #oxford_flowers
	global_source_dir=$2 #~/caffe/examples/$dataset/benchmark
	phase_id_str=$3 #0
	phase_id_end=$4 #100
	dataset_dir=$5 #FLOWER102-ALEXNET-SCRATCH
	experiments_flag=$6 #HV
	RETRAIN_IDs=$7 #(0 60) # retrain_id_str and retrain_id_end
	iter_cur_fixed=$8 #10000
	iter_end=$9 #60001 
	iter_iterval=${10} #(500 1000 1000 1000 1000 1000 1000 1000 1000 1000)
	total_num_example=${11}
	train_test_prototxt=${12}
	record_date=${13}


	echo $experiments_flag
		retrain_id=${RETRAIN_IDs[0]} #${ITER_STRs[index]}
		retrain_id_end=${RETRAIN_IDs[1]}
		echo retrain_id_end = $retrain_id_end 

		while [[ $retrain_id -lt $retrain_id_end ]]
		do
			echo retrain_id = "$retrain_id" iter_cur ="$iter_cur"  iter_end ="$iter_end"  iter_iterval ="$iter_iterval"
	
			phase_name_dir=original_100run_retrain"$retrain_id"


			iter_cur=$iter_cur_fixed
			while [[ $iter_cur -lt $iter_end ]]
			do	
				echo $iter_cur

				global_record_file_input=$global_source_dir/$dataset_dir/"$experiments_flag"_original_100run_retrain"$retrain_id"_$iter_cur-iter-pred-recording-$record_date
				echo "global_record_file_input = "$global_record_file_input

				if [ -f $global_record_file_input ]
				then
					extract_multi_recording $global_record_file_input $phase_name_dir $phase_id_str $phase_id_max $dataset_dir $total_num_example
					mv $global_source_dir/$dataset_dir/$phase_name_dir $global_source_dir/$dataset_dir/"$phase_name_dir"_$iter_cur
				else
					echo "$global_record_file_input does not exist, skip generate the prediction files"
				fi
				iter_cur=$(($iter_cur + $iter_iterval))	
			done

			retrain_id=$(($retrain_id + 1))	
		done



		#create the target directory
		if [ -d $global_source_dir/$dataset_dir/$experiments_flag ]
		then
			echo "##############################caution"
			echo "the target directory $global_source_dir/$dataset_dir/$experiments_flag already exists, skip create it..."
			echo "##############################do you rewrite the directory of the previous predictions"
		else
			#echo "create $des_dir "
			mkdir $global_source_dir/$dataset_dir/$experiments_flag
			echo "create $global_source_dir/$dataset_dir/$experiments_flag done"
		fi
		#move the extracted predictions into the target directory
			mv $global_source_dir/$dataset_dir/original_100run_retrain* $global_source_dir/$dataset_dir/$experiments_flag/
		#back to the source directory


}

classify_cifar10_quick() {
	dataset=cifar10
	source_dir=~/caffe/examples/$dataset/benchmark-cifar10-quick
	phase_id_str=0
	phase_id_max=100 #99
	dataset_dir=CIFAR10-QUICK
	#(total number of test data  = 10000), / (test batch-size = 100)
	total_iteration=100 #this equals to the (total number of test data) / (test batch-size)
	total_num_example=10000
	train_test_prototxt=cifar10_quick_train_test.prototxt
	#iter_caffemodel_for_prediction=5000



	phase_id_str=0
	phase_id_max=100 #99
	EXPERIMENTS_FLAG=(ip2_2.5) #ip1-0.1 
	RETRAIN_IDs=(1 11) # retrain_id_str and retrain_id_end
	ITER_STRs=5000 # 290000
	ITER_ENDs=5001
	ITER_ITERVAL=1000
	#record_date=2017-11-29
	EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date

	batch_collect_results_EXPERIMENTS_FLAG  $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date


}




classify_cifar100_quick() {
	dataset=cifar10
	source_dir=~/caffe/examples/$dataset/benchmark-cifar100-cifar10-quick
	dataset_dir=CIFAR100-QUICK
	phase_id_str=0
	phase_id_max=100 #99
	#(total number of test data  = 10000), / (test batch-size = 100)
	total_iteration=100 #this equals to the (total number of test data) / (test batch-size)
	total_num_example=10000
	train_test_prototxt=cifar10_quick_train_test.prototxt

	phase_id_str=0
	phase_id_max=60 #99
	EXPERIMENTS_FLAG=(ip2_2.5_lower_layer_weights_locked) #ip1-0.1 
	RETRAIN_IDs=(1 9) # retrain_id_str and retrain_id_end
	ITER_STRs=10000 # 290000
	ITER_ENDs=10001
	ITER_ITERVAL=1000
	#record_date=2017-11-29
	EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date

	batch_collect_results_EXPERIMENTS_FLAG  $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date


}

classify_svhn_quick() {
	dataset=svhn
	source_dir=~/caffe/examples/$dataset/benchmark
	phase_id_str=0
	phase_id_max=100 #99
	dataset_dir=SVHN-QUICK
	#(total number of test data  = 26032), / (test batch-size = 100)
	total_iteration=261 #this equals to the (total number of test data) / (test batch-size)
	total_num_example=26032
	train_test_prototxt=svhn_quick_train_test.prototxt
	#iter_caffemodel_for_prediction=6000

	phase_id_str=0
	phase_id_max=100 #99
	EXPERIMENTS_FLAG=(ip1_2.5_ip2_2.5 conv3_1_ip1_1_ip2_1 conv3_2.5_ip1_2.5_ip2_2.5 conv3_10_ip1_10_ip2_10) #ip1-0.1 
	RETRAIN_IDs=(1 11) # retrain_id_str and retrain_id_end
	ITER_STRs=6000 # 290000
	ITER_ENDs=6001
	ITER_ITERVAL=1000
	#record_date=2017-11-29
	EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date

	batch_collect_results_EXPERIMENTS_FLAG  $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date
	
}

classify_mnist_RI_bagging() {
	dataset=mnist
	source_dir=~/caffe/examples/$dataset/benchmark
	phase_id_str=0
	phase_id_max=60 #99
	dataset_dir=MNIST
	#(total number of test data  = 10000), / (test batch-size = 100)
	total_iteration=100 #this equals to the (total number of test data) / (test batch-size)
	total_num_example=10000
	train_test_prototxt=lenet_train_test.prototxt
	iter_caffemodel_for_prediction=10000

	record_date=$global_record_date



	phase_id_str=0
	phase_id_max=60 #99
	EXPERIMENTS_FLAG=(conv38-1-conv39-1-ip1-1 conv38-2.5-conv39-2.5-ip1-2.5 conv38-10-conv39-10-ip1-10) #ip1-0.1 
	RETRAIN_IDs=(1 4) # retrain_id_str and retrain_id_end
	ITER_STRs=10000 # 290000
	ITER_ENDs=10001
	ITER_ITERVAL=1000
	#record_date=2017-11-29
	EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date

	batch_collect_results_EXPERIMENTS_FLAG  $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date


		
}




classify_cifar100_densenet() {
	dataset=cifar100
	source_dir=~/caffe/examples/$dataset/benchmark
	phase_id_str=0
	total_num_example=10000
	dataset_dir=CIFAR100-DENSENET
	total_iteration=200 #this equals to the (total number of test data) / (test batch-size) = 10000 / 50 = 200
	train_test_prototxt=train_densenet.prototxt



	
	phase_id_str=0
	phase_id_max=1 #99
	EXPERIMENTS_FLAG=(SnapshotEnsemble-secondrun ip1-2.5-retrain-single-secondrun) #ip1-0.1 
	RETRAIN_IDs=(10 20) # retrain_id_str and retrain_id_end
	ITER_STRs=30000 # 
	ITER_ENDs=30001
	ITER_ITERVAL=1000
	#EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date

	#batch_collect_results_EXPERIMENTS_FLAG  $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date



	phase_id_str=5
	phase_id_max=10 #99
	EXPERIMENTS_FLAG=(ip1-2.5) #ip1-0.1 
	RETRAIN_IDs=(4 5) # retrain_id_str and retrain_id_end
	ITER_STRs=30000 # 
	ITER_ENDs=30001
	ITER_ITERVAL=1000
	EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date

	batch_collect_results_EXPERIMENTS_FLAG  $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date




}


classify_flower102_finetune_RI_bagging() {
	dataset=oxford_flowers
	source_dir=~/caffe/examples/$dataset/benchmark
	phase_id_str=0
	phase_id_max=60 #99
	dataset_dir=FLOWER102-NIN-FINETUNE #FLOWER102-NIN-FINETUNE #FLOWER102-ALEXNET-FINETUNE #
	#(total number of test data  = 1020), / (test batch-size = 64) [ note some of the test batch size is   50 , so I set to 21.
	#total_iteration=16 #this equals to the (total number of test data) / (test batch-size)
	total_iteration=16 #this equals to the (total number of test data) / (test batch-size)
	total_num_example=1020  #1024 valid 6149
	train_test_prototxt=train_val_cifar100_nin.prototxt #finetune NIN 

	#train_test_prototxt=train_val.prototxt
	iter_caffemodel_for_prediction=12000

	record_date=$global_record_date
	ITER_STRs=12000 # 
	ITER_ENDs=12001
	ITER_ITERVAL=100

	phase_id_max=60
	EXPERIMENTS_FLAG=(ccp8-2.5-finetune-60-NIN) # fc8-7.5 fc7-1-fc8-1 fc8-1 fc7-1 fc7-10  fc7-10-fc8-1 fc7-1-fc8-10 fc7-10-fc8-10 fc8-1 fc7-1 fc7-10
	RETRAIN_IDs=(4 5) # retrain_id_str and retrain_id_end
		EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date
		batch_collect_results_EXPERIMENTS_FLAG  $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date



}


classify_flower102_scratch_RI_bagging() {
	dataset=oxford_flowers
	source_dir=~/caffe/examples/$dataset/benchmark
	phase_id_str=0
	phase_id_max=60 #99
	dataset_dir=FLOWER102-ALEXNET-SCRATCH #FLOWER102-ALEXNET-SCRATCH
	#(total number of test data  = 1020), / (test batch-size = 64) [ note some of the test batch size is   50 , so I set to 21.
	#total_iteration=16 #this equals to the (total number of test data) / (test batch-size)
	total_iteration=16 #this equals to the (total number of test data) / (test batch-size)
	total_num_example=1020  #1024 valid 6149
	train_test_prototxt=train_val.prototxt
	iter_caffemodel_for_prediction=12000

	record_date=$global_record_date
	ITER_STRs=12000 # 
	ITER_ENDs=12001
	ITER_ITERVAL=100

phase_id_max=10
EXPERIMENTS_FLAG=(fc7-2.5-fc8-2.5 fc6-1-fc7-1-fc8-1 fc6-2.5-fc7-2.5-fc8-2.5 fc6-10-fc7-10-fc8-10) # fc8-7.5 fc7-1-fc8-1 fc8-1 fc7-1 fc7-10  fc7-10-fc8-1 fc7-1-fc8-10 fc7-10-fc8-10 fc8-1 fc7-1 fc7-10
RETRAIN_IDs=(1 4) # retrain_id_str and retrain_id_end
	EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date
	batch_collect_results_EXPERIMENTS_FLAG  $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date





}


classify_cifar100_nin() {
dataset=cifar100
source_dir=~/caffe/examples/$dataset/benchmark
phase_id_str=0
phase_id_max=10 #99
dataset_dir=CIFAR100-NIN
total_iteration=200 #this equals to the (total number of test data) / (test batch-size)
total_num_example=10000
train_test_prototxt=train_val_cifar100_nin.prototxt




	
}
classify_imagenet_nin() {
dataset=imagenet
dataset_dir=ILSVRC2012-NIN
source_dir=~/caffe/examples/$dataset/benchmark-NIN
phase_id_str=0
phase_id_max=5 #99
total_iteration=1000 #this equals to the (total number of test data) / (test batch-size) 50000/50 test
#total_iteration=10010 #this equals to the (total number of test data) / (test batch-size) 1281167/128 = 1.0009e+04 train
total_num_example=50000
train_test_prototxt=train_val_cifar100_nin.prototxt #train_val_cifar100_nin.prototxt

	phase_id_str=5
	phase_id_max=10 #99
	EXPERIMENTS_FLAG=(ccp8-2.5-secondrun) #snapshot_ensemble not yet ccp7-2.5-ccp8-2.5 conv4-2.5-ccp7-2.5-ccp8-2.5  conv4-10-ccp7-10-ccp8-10
	RETRAIN_IDs=(1 2) # retrain_id_str and retrain_id_end
	ITER_STRs=250000 # 
	ITER_ENDs=250001
	ITER_ITERVAL=50000
	record_date=$global_record_date
	EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date

	batch_collect_results_EXPERIMENTS_FLAG $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date



}

classify_imagenet_alexnet() {
dataset=imagenet
source_dir=~/caffe/examples/$dataset/benchmark    #-NIN
dataset_dir=ILSVRC2012-ALEXNET
phase_id_str=0
phase_id_max=60 #99
total_iteration=1000 #this equals to the (total number of test data) / (test batch-size) 50000/50 test
#total_iteration=10010 #this equals to the (total number of test data) / (test batch-size) 1281167/128 = 1.0009e+04 train
total_num_example=50000
train_test_prototxt=train_val.prototxt #train_val_cifar100_nin.prototxt


    phase_id_str=0
    phase_id_max=5 #99
    EXPERIMENTS_FLAG=(1Alpha200000iter-fc8-2.5) #snapshot_ensemble not yet conv4-1-ccp7-1-ccp8-1
    RETRAIN_IDs=(1 2) # retrain_id_str and retrain_id_end
    ITER_STRs=50000 #75000 #
    ITER_ENDs=150001
    ITER_ITERVAL=50000
    record_date=$global_record_date
    EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date
    batch_collect_results_EXPERIMENTS_FLAG $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date
}




classify_imagenet_vgg_16layer() {
#TRAIN_VALID_TEST_LMDB_FLAG=0 #reset this for correctly generate the prototxt file for checking training accuracy
dataset=imagenet
source_dir=~/caffe/examples/$dataset/benchmark    #-NIN
dataset_dir=ILSVRC2012-VGG-16-layer
phase_id_str=0
phase_id_max=60 #99
total_iteration=1000 #this equals to the (total number of test data) / (test batch-size) 50000/50 test
#total_iteration=10010 #this equals to the (total number of test data) / (test batch-size) 1281167/128 = 1.0009e+04 train
total_num_example=50000
train_test_prototxt=train_val.prototxt #train_val_cifar100_nin.prototxt


    phase_id_str=0
    phase_id_max=1 #99
    EXPERIMENTS_FLAG=(16-layer-fc8-2.5-retrain-from-250000iters) #0.1Alpha75000iter-fc8-2.5 0.1Alpha200000iter-fc8-2.5
    RETRAIN_IDs=(0 1) # retrain_id_str and retrain_id_end
    ITER_STRs=250000 #
    ITER_ENDs=250001
    ITER_ITERVAL=50000
    record_date=$global_record_date
    EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date
    batch_collect_results_EXPERIMENTS_FLAG $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date



    RETRAIN_IDs=(1 2) # retrain_id_str and retrain_id_end
    ITER_STRs=100000 #
    ITER_ENDs=100001
    ITER_ITERVAL=50000
    record_date=$global_record_date
    #EXPERIMENTS_FLAG_prediction_general $dataset $source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_iteration  $train_test_prototxt $record_date
    #batch_collect_results_EXPERIMENTS_FLAG $dataset $global_source_dir $phase_id_str $phase_id_max $dataset_dir $EXPERIMENTS_FLAG $RETRAIN_IDs $ITER_STRs  $ITER_ENDs $ITER_ITERVAL $total_num_example  $train_test_prototxt $record_date
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
	flower102-scratch) # | [Yy][Ee][Ss] ) 	
		classify_flower102_scratch_RI_bagging
		;;
	flower102-finetune) # | [Yy][Ee][Ss] ) 	
		classify_flower102_finetune_RI_bagging
		;;
	mnist)  	
		classify_mnist_RI_bagging
		;;
	imagenet-nin)  	
		classify_imagenet_nin
		;;
	imagenet-alexnet)     
        	classify_imagenet_alexnet
       		;;

	imagenet-vgg-s)     
		classify_imagenet_vgg_s
		;;
	imagenet-vgg-16layer)     
		classify_imagenet_vgg_16layer
		;;

	* ) 			
		echo  "Sorry, $1 not rcognized. Enter  cifar10-quick svhn, and so on"
		exit 1
		;; 

esac



