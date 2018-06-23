#!/bin/bash


dataset=cifar10
source_dir=examples/$dataset/benchmark


ri_multi_retrain() {
	rm_id=$1 #the pretrain, id, we actually start from rm_id + 1
	RM_N=$2 


	while [[ $rm_id -lt $RM_N ]]
	do

		cd $source_dir
			rm original_100run
			rm original_100run_pretrained
			ln -s original_100run_retrain$rm_id original_100run_pretrained

		
			rm_id=$(($rm_id + 1)) #x=$($x+1) means x=$(0+1)
			echo $rm_id/$phase_id_end = "$rm_id" #num_output =${random_num_class[index]}
			ln -s original_100run_retrain$rm_id original_100run

		cd ~/caffe-worked-weight-visulization
		chmod +x ./$source_dir/original_100run/create_benchmark_phase-prototxt.sh
		./$source_dir/original_100run/create_benchmark_phase-prototxt.sh |& tee  ./$source_dir/original_100run/retrain$rm_id-recording-2018-2-5
		#./$source_dir/original_100run/phase3.sh |& tee  ./$source_dir/original_100run/retrain$rm_id-recording-phase3-30000-to-50000iters-2017-11-6
	done
}

#chmod +x ./examples/cifar10/benchmark/ri_multi_retrain_main.sh
train_cifar10_quick() {
	current_phase_name_dir=$1
	id_retrain_stard=$2
	id_retrain_end=$3
	
	cd ~/caffe-worked-weight-visulization/$source_dir/
		mv $current_phase_name_dir/original_100run_retrain* .

	cd ~/caffe-worked-weight-visulization
		ri_multi_retrain  $id_retrain_stard $id_retrain_end  |& tee  ./examples/$dataset/benchmark/$current_phase_name_dir-recording-2018-2-5


	cd ~/caffe-worked-weight-visulization/$source_dir
		mv original_100run_retrain* $current_phase_name_dir
		#cp -R RETRAIN_FILES_NO_10times_lr_of_the_last_layer/* .

}





retrain_start_id=0 #the pretrained id, we actually start from rm_id + 1
retrain_end_id=1 #we end at (retrain_end_id - 1)
EXPERIMENTS_FLAG=(ip2_2.5)   #ccp8-25 
for ele in ${!EXPERIMENTS_FLAG[@]}; do
	experiments_flag=${EXPERIMENTS_FLAG[ele]}
	echo $experiments_flag
	train_cifar10_quick $experiments_flag $retrain_start_id $retrain_end_id
done

