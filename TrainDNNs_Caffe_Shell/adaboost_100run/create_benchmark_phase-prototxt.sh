#!/bin/sh


#dataset=mnist #  ##!/bin/bash
#source ./examples/$dataset/benchmark/original_100run/config_phase.sh  #if you run this script in caffe/. 

#this file is for the test of the random initilization version of mnist models. 
#it can also be used for the horizontal voting ensemble.
dataset=cifar10
EXAMPLE=examples/$dataset
source_dir=~/caffe/examples/$dataset/benchmark
phase_name_dir=adaboost_100run


solver_prototxt_prefix=cifar10_quick_solver
train_test_prototxt_prefix=cifar10_quick_train_test
num_output_to_replace=10 #be carefull about this value, if this is not unique, other places maybe be replaced.


source_solver_prototxt_file=$solver_prototxt_prefix.prototxt
source_train_test_prototxt_file=$train_test_prototxt_prefix.prototxt


generate_target_prototxt_and_modify() {
	phase_name_dir=$1
	phase_id=$2
	num_output=$3

	echo "==============================================="
	echo "$dataset phase_id="$phase_id" num_output="$num_output

	#===============================================
	#section 1, generate_target_prototxt
	#===============================================
	if [ -d $source_dir/$phase_name_dir ]
	then
		echo "the target directory $phase_name_dir already exists, skip create it..."
		#rm -rf $des_dir
		#echo "remove $des_dir done."
	else
		#echo "create $des_dir "
		mkdir $source_dir/$phase_name_dir
		echo "create $des_dir done"
	fi


	des_dir=$source_dir/$phase_name_dir/phase$phase_id

	if [ -d $des_dir ]
	then
		echo "the target directory $des_dir already exists, skip create it..."
		#rm -rf $des_dir
		#echo "remove $des_dir done."
	else
		#echo "create $des_dir "
		mkdir $des_dir
		echo "create $des_dir done"
	fi

	#target file
	#train_test_prototxt=$des_dir/$source_train_test_prototxt_file
	train_test_prototxt=$des_dir/"$train_test_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output".prototxt
	
	
	#===============================================
	#section 3, modify train_test_prototxt
	#===============================================
	source_file=$source_dir/$phase_name_dir/$source_train_test_prototxt_file
	target_file=$train_test_prototxt

	echo "source_file:"$source_file
	echo "target_file:"$target_file


	#echo "Show the original relavant sections to modify..."
	#sed -n "s|num_output: $num_output_to_replace|(&)|p" < $source_file

	num_output_new=`echo num_output: "$num_output"`
	echo "num_output_new: "$num_output



	#training_set0_lmdb
	share_prefix_str=cifar10_train_adaboost_"$phase_id"
	train_data="$share_prefix_str"_lmdb
	echo "Expected relavant sections..."
	source_train_data=`echo source: \"$EXAMPLE/cifar10_adaboost_lmdb/$train_data\"`
	echo "	[TRAIN]"$source_train_data



	sed  "s|num_output: $num_output_to_replace.*|$num_output_new|" < $source_file >$target_file
	echo "Modify the num_output of target_file, done "

	#modify the train,test data, mean-file, num_output
	sed -e "/phase: TRAIN/,/phase: TEST/ s|source.*|$source_train_data|" \
		-e "s|num_output: $num_output_to_replace.*|$num_output_new|" \
		< $source_file >$target_file
	
	echo "Modify the train,test data, mean_file, num_output of $source_file, done "


	#===============================================
	#section 2, modify solver_prototxt and cp to a new file
	#===============================================
	solver_prototxt="$des_dir"/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output".prototxt
	source_file=$source_dir/$phase_name_dir/$source_solver_prototxt_file
	target_file=$solver_prototxt
	prefix_str="$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"

	echo "source_file:"$source_file
	echo "target_file:"$target_file

	net_new=`echo net: \"$(echo $train_test_prototxt | sed "s|"$HOME"/caffe/||")\"`
	#echo "after modification... "
	echo $net_new

	snapshot_prefix_new=`echo snapshot_prefix: \"$(echo $des_dir | sed "s|"$HOME"/caffe/||")/$prefix_str\"`
	echo $snapshot_prefix_new
	sed -e "s|snapshot_prefix.*|$snapshot_prefix_new|" \
		-e "s|net:.*|$net_new|" \
		<$source_file >$target_file


	#===============================================modify the cifar10_full_solver_lr1.prototxt
	source_file=$source_dir/$phase_name_dir/$solver_prototxt_prefix"_lr1.prototxt"
	target_file="$des_dir"/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_lr1.prototxt
	prefix_str="$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_lr1



	snapshot_prefix_new=`echo snapshot_prefix: \"$(echo $des_dir | sed "s|"$HOME"/caffe/||")/$prefix_str\"`
	sed -e "s|snapshot_prefix.*|$snapshot_prefix_new|" \
		-e "s|net:.*|$net_new|" \
		<$source_file >$target_file

}

<<COMMENT
	#===============================================modify the cifar10_full_solver_lr2.prototxt
	source_file=$source_dir/$phase_name_dir/"$solver_prototxt_prefix"_lr2.prototxt
	target_file=$des_dir/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_lr2.prototxt
	prefix_str="$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_lr2
	echo "Modify the net and snapshot_prefix of target_file, done "
	#echo "show the modified new file..."
	#more $target_file

	snapshot_prefix_new=`echo snapshot_prefix: \"$(echo $des_dir | sed "s|"$HOME"/caffe/||")/$prefix_str\"`
	echo $snapshot_prefix_new
	sed -e "s|snapshot_prefix.*|$snapshot_prefix_new|" \
		-e "s|net:.*|$net_new|" \
		<$source_file >$target_file
COMMENT

	
benchmark_single_phase() {
	phase_name_dir=$1
	phase_id=$2
	num_output=$3

	echo "==============================================="
	echo "$dataset phase_name_dir=$phase_name_dir phase_id="$phase_id" num_output="$num_output

	des_dir=$source_dir/$phase_name_dir/phase$phase_id
	
	solver_prototxt="$des_dir"/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output".prototxt


		./build/tools/caffe train \
		--solver=$solver_prototxt 

solver_prototxt_lr1="$des_dir"/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_lr1.prototxt
		./build/tools/caffe train \
		--solver=$solver_prototxt_lr1 \
		--snapshot=$des_dir/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_iter_4000.solverstate.h5



}

<<COMMENT		
solver_prototxt_lr2=$des_dir/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_lr2.prototxt
		./build/tools/caffe train \
		--solver=$solver_prototxt_lr2 \
		--snapshot=$des_dir/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_lr1_iter_65000.solverstate.h5
COMMENT


create_prototxt(){
	phase_id=$1
	phase_id_end=$2
	num_output=$3
	while [ $phase_id -lt $phase_id_end ] 
	do
		#echo $phase_id
		echo $phase_id/$phase_id_end = "$phase_id" num_output =$num_output
		
		generate_target_prototxt_and_modify $phase_name_dir $phase_id  $num_output
		phase_id=$(($phase_id + 1)) #x=$($x+1) means x=$(0+1), while 0+1 is not a variable name
	done
	#ls $source_dir/$phase_name_dir/ -Rt
}
benchmark() {
	phase_id=$1
	phase_id_end=$2
	num_output=$3
	while [ $phase_id -lt $phase_id_end ]
	do
		#echo $phase_id
		echo $phase_id/$phase_id_end = "$phase_id" num_output =$num_output

		benchmark_single_phase  $phase_name_dir $phase_id  $num_output
		phase_id=$(($phase_id + 1)) #x=$($x+1) means x=$(0+1), while 0+1 is not a variable name
		
	done
}

num_output=10

phase_id_str=$1

echo "[ the phase_id to run is " $phase_id_str " ]"

phase_id_max=$(($phase_id_str + 1)) #99
###here we create 100 phases, but only test 60 of them
create_prototxt $phase_id_str $phase_id_max $num_output
benchmark $phase_id_str $phase_id_max $num_output











