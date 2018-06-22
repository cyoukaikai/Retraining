#!/usr/bin/env sh
# This script converts the mnist data into lmdb/leveldb format,
# depending on the value assigned to $BACKEND.



DATASET=cifar10
EXAMPLE=examples/cifar10/cifar10_adaboost_lmdb
DATA=data/cifar10
DBTYPE=lmdb

	phase_id=$1
	weight_file=$2

echo "Creating $DBTYPE..."

#rm -rf $EXAMPLE/cifar10_train_bagging_*$DBTYPE 
./build/examples/"$DATASET"/adaboost_"$DATASET"_data.bin $DATA $EXAMPLE $DBTYPE $phase_id $weight_file


