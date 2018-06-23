#!/bin/bash

#dataset=mnist #  ##!/bin/bash #!/bin/sh
#source ./examples/$dataset/benchmark/original_100run/config_phase.sh  #if you run this script in caffe/. 

#this file is for the test of the random initilization version of mnist models. 
#it can also be used for the horizontal voting ensemble.
dataset=cifar10
ECOC_sourse_dataset=cifar10_quick
source_dir=examples/$dataset/benchmark/ECOC #~/caffe/
#phase_name_dir=ECOC
random_num_class=(2 3 4 5  ) # 2 3 4 5  25 33 50
num_output_array=(2 3 4 5  ) # 10 10 10  25 33 50

solver_prototxt_prefix=cifar10_quick_solver
train_test_prototxt_prefix=cifar10_quick_train_test
num_output_to_replace=10 #be carefull about this value, if this is not unique, other places maybe be replaced.

source_solver_prototxt_file=$solver_prototxt_prefix.prototxt
source_train_test_prototxt_file=$train_test_prototxt_prefix.prototxt

generate_target_prototxt_and_modify() {
	phase_name_dir=$1
	phase_id=$2

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




	
	
	
	#===============================================
	#section 2, modify solver_prototxt and cp to a new file
	#modify the net, one ECOC suddirectory share a net, 
	#because they have the same num_output
	#===============================================
	solver_prototxt="$des_dir"/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output".prototxt
	source_file=$source_dir/$phase_name_dir/$source_solver_prototxt_file
	target_file=$solver_prototxt

	prefix_str="$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"

	snapshot_prefix_new=`echo snapshot_prefix: \"$(echo $des_dir | sed "s|"$HOME"/caffe/||")/$prefix_str\"`
	echo $snapshot_prefix_new

	#echo "begin the replacement..."

	sed -e "s|snapshot_prefix.*|$snapshot_prefix_new|" \
		-e "s|net:.*|$net_new|" \
		<$source_file >$target_file

	#===============================================solver_lr1.prototxt
	solver_prototxt="$des_dir"/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_lr1.prototxt
	source_file=$source_dir/$phase_name_dir/$solver_prototxt_prefix"_lr1.prototxt"
	target_file=$solver_prototxt

	prefix_str="$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"

	snapshot_prefix_new=`echo snapshot_prefix: \"$(echo $des_dir | sed "s|"$HOME"/caffe/||")/$prefix_str\"`
	echo $snapshot_prefix_new

	#echo "begin the replacement..."

	sed -e "s|snapshot_prefix.*|$snapshot_prefix_new|" \
		-e "s|net:.*|$net_new|" \
		<$source_file >$target_file
}

generate_train_test_prototxt_and_modify(){
	phase_name_dir=$1
	num_output=$2

	echo "==============================================="
	echo "$dataset phase_name_dir="$phase_name_dir" num_output="$num_output

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
	

	train_test_prototxt=$source_dir/$phase_name_dir/$source_train_test_prototxt_file

	
	#===============================================
	#section 3, modify train_test_prototxt
	#===============================================
	source_file=$source_dir/$source_train_test_prototxt_file
	target_file=$train_test_prototxt

	echo "source_file:"$source_file
	echo "target_file:"$target_file


	#echo "Show the original relavant sections to modify..."
	#sed -n "s|num_output: $num_output_to_replace|(&)|p" < $source_file

	num_output_new=`echo num_output: "$num_output"`
	echo "num_output_new: "$num_output

	sed  "s|num_output: $num_output_to_replace.*|$num_output_new|" < $source_file >$target_file
	echo "Modify the num_output of target_file, done "




	#echo "show the modified new file..."
	#more $target_file
	#===============================================
	#section 2, modify solver_prototxt and cp to a new file
	#modify the net, one ECOC suddirectory share a net, 
	#because they have the same num_output
	#===============================================
	source_file=$source_dir/$source_solver_prototxt_file
	target_file=$source_dir/$phase_name_dir/$source_solver_prototxt_file
	
	echo "source_file:"$source_file
	echo "target_file:"$target_file

	net_new=`echo net: \"$(echo $train_test_prototxt | sed "s|"$HOME"/caffe/||")\"`
	#echo "after modification... "
	echo $net_new

	#echo "begin the replacement..."
	sed "s|net:.*|$net_new|" \
		<$source_file >$target_file


	#===============================================solver_lr1.prototxt
	source_file=$source_dir/$solver_prototxt_prefix"_lr2.prototxt"
	target_file=$source_dir/$phase_name_dir/$solver_prototxt_prefix"_lr1.prototxt"
	
	echo "source_file:"$source_file
	echo "target_file:"$target_file

	net_new=`echo net: \"$(echo $train_test_prototxt | sed "s|"$HOME"/caffe/||")\"`
	#echo "after modification... "
	echo $net_new

	#echo "begin the replacement..."
	sed "s|net:.*|$net_new|" \
		<$source_file >$target_file

}


generate_ECOC_prototxt() {
	phase_id_str=$1
	phase_id_end=$2


	for index in ${!random_num_class[@]}; do
		#generate the new_train_test.prototxt for each of the ECOC version (ECOC2, ECOC3,...)
		echo $((index))/${#random_num_class[@]} = "${random_num_class[index]}" num_output ="${num_output_array[index]}"
		ECOC_DIR=ECOC${random_num_class[index]}
		echo $ECOC_DIR

		generate_train_test_prototxt_and_modify  $ECOC_DIR ${num_output_array[index]} #here we modify the num_output for each ECOC version, because the num_output = num_class did not work.
		
		phase_id=$phase_id_str
		#generate the solver.prototxt file for each phase of the a specific ECOC version
		while [[ $phase_id -lt $phase_id_end ]] 
		do
			#echo $phase_id
			echo $phase_id/$phase_id_end = "$phase_id" 
		
			generate_target_prototxt_and_modify $ECOC_DIR $phase_id  
			phase_id=$(($phase_id + 1)) #x=$($x+1) means x=$(0+1), while 0+1 is not a variable name
		done
		#ls $source_dir/$phase_name_dir/ -Rt
	done

	#check if the num_output unique. if not, you should make it unique manually.

	echo "############################################################"
	echo "note, there should be only one line below, if not, check the num_output in source_train_test_file, and modify the the relavant setting to make it unique so we can safely replace it."
	source_file=$source_dir/$source_train_test_prototxt_file
	sed -n "s|num_output: $num_output_to_replace|(&)|p" < $source_file
	echo "############################################################"

}


	
benchmark_single_phase() {
	phase_name_dir=$1
	phase_id=$2
	num_output=$3
	class_group_prototxt=$4

	echo "==============================================="
	echo "$dataset phase_name_dir=$phase_name_dir phase_id="$phase_id" num_output="$num_output

	des_dir=$source_dir/$phase_name_dir/phase$phase_id
	
	solver_prototxt="$des_dir"/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output".prototxt


		#./build/tools/caffe train \
		#--solver=$solver_prototxt \
		#--class_group=$class_group_prototxt \
		#--benchmark_phase_id=$phase_id 

solver_prototxt_lr1="$des_dir"/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_lr1.prototxt
		./build/tools/caffe train \
		--solver=$solver_prototxt_lr1 \
		--class_group=$class_group_prototxt \
		--benchmark_phase_id=$phase_id \
		--snapshot=$des_dir/"$solver_prototxt_prefix"_"$phase_name_dir"_"$phase_id"_num_output_"$num_output"_iter_5000.solverstate.h5
#--snapshot=examples/svhn/svhn_model/svhn_quick_iter_3000.solverstate.h5
}

benchmark() {
	phase_id_str=$1
	phase_id_end=$2

	for index in ${!random_num_class[@]}; do
		num_output=${num_output_array[index]}
		echo $((index))/${#random_num_class[@]} = "${random_num_class[index]}" num_output ="$num_output"
		ECOC_DIR=ECOC${random_num_class[index]}
		
		class_group_prototxt=$source_dir/"$ECOC_sourse_dataset"_ECOC_sources/"$ECOC_sourse_dataset"_random"${random_num_class[index]}"-all-phase-class.prototxt
#svhn10_random3-all-phase-class
		phase_id=$phase_id_str
		while [[ $phase_id -lt $phase_id_end ]]
		do
			#echo $phase_id
			echo $phase_id/$phase_id_end = "$phase_id" num_output =${random_num_class[index]}

			benchmark_single_phase  $ECOC_DIR $phase_id  $num_output $class_group_prototxt
			phase_id=$(($phase_id + 1)) #x=$($x+1) means x=$(0+1), while 0+1 is not a variable name
		
		done
	done
}

phase_id_str=0
phase_id_max=100 #99
###here we create 100 phases, but only test 60 of them
generate_ECOC_prototxt $phase_id_str $phase_id_max 


#phase_id_str=44 #69 
#phase_id_max=100 #100
benchmark $phase_id_str $phase_id_max $num_output









