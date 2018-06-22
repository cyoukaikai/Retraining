//
// This script converts the CIFAR dataset to the leveldb format used
// by caffe to perform classification.
// Usage:
//    convert_cifar_data input_folder output_db_file
// The CIFAR dataset could be downloaded at
//    http://www.cs.toronto.edu/~kriz/cifar.html

#include <fstream>  // NOLINT(readability/streams)
#include <string>

#include "boost/scoped_ptr.hpp"
#include "glog/logging.h"
#include "google/protobuf/text_format.h"
#include "stdint.h"

#include "caffe/proto/caffe.pb.h"
#include "caffe/util/db.hpp"
#include "caffe/util/format.hpp"

//############### for use of rand function
#include <cstdlib>
#include <iostream>
#include <ctime>
//#######################
#include <math.h>       /* ceil */


using caffe::Datum;
using boost::scoped_ptr;
using std::string;
namespace db = caffe::db;

const int kCIFARSize = 32;
const int kCIFARImageNBytes = 3072;
const int kCIFARBatchSize = 10000;
const int kCIFARTrainBatches = 5;

// 1- exp(-1) =  0.6321
//const float threshold = 0.6321; //a thereshold used for adaboost sampling

void read_image(std::ifstream* file, int* label, char* buffer) {
  char label_char;
  file->read(&label_char, 1);
  *label = label_char;
  file->read(buffer, kCIFARImageNBytes);
  return;
}

void convert_dataset(const string& input_folder, const string& output_folder,
    const string& db_type, const int adaboost_lmdb_id, const string& sampleweight_filename) {
  scoped_ptr<db::DB> train_db(db::GetDB(db_type));
  train_db->Open(output_folder + "/cifar10_train_adaboost_" + caffe::format_int(adaboost_lmdb_id) + "_"  +  db_type, db::NEW);
  scoped_ptr<db::Transaction> txn(train_db->NewTransaction());
  // Data buffer
  int label;
  char str_buffer[kCIFARImageNBytes];
  Datum datum;
  datum.set_channels(3);
  datum.set_height(kCIFARSize);
  datum.set_width(kCIFARSize);

  int datasize =  kCIFARBatchSize * kCIFARTrainBatches;
  //LOG(INFO) << "adaboost Data prepare begin: total " << datasize << " Training data to write";

  int adaboost_image_id = 0; //current image_id for baggging data writting
  int end_flag = 0; //if sampling process is finished, this flag will be set to 1, then all the loop will be break.

  //refer to http://stackoverflow.com/questions/686353/c-random-float-number-generation
  //Before calling rand(), you must first "seed" the random number generator by calling srand(). This should be done once during your program's run -- not once every time you call rand(). This is often done like this:
  srand (static_cast <unsigned> (time(0))); //
  float check_rand = rand() / (float)RAND_MAX;
  printf(" check_rand = %f \n", check_rand  );
  //LOG(INFO) << "Check the rand() work: random_num =" << check_rand << " [note that this number should be different for each adaboost_lmdb create]." ;
 //==================================================================================-
  //load the distribution of the training examples into Dis
  float distribution;
  float Dis[datasize]; // load the distribution into vector
	
  //string fileName ="D1.txt";
  FILE *fp; 
  //int phase_id = 1;
  // string fileNameSampleWeight = "./examples/mnist/D" + caffe::format_int(phase_id)  + "_caffeUse";
  fp = fopen(sampleweight_filename.c_str(), "r");  //"./examples/mnist/D1_caffeUse" fileNameSampleWeight.c_str() sampleweight_filename.c_str()
  if( fp == NULL )
    {
      perror("Error while openinqg the file.\n");
      exit(0);
    }
  //printf("The contents of data are :- \n\n");


  for (int i = 0; i < datasize; i++) {     
    fscanf(fp,"%f",&distribution);  Dis[i] = distribution;
    //LOG(INFO) << "[Example ID] i  =" << i << " , weight = ." << Dis[i];
  }

  printf("Succeed loading %d data lines.\n" , datasize );
  fclose(fp);
  //==================================================================================-

  FILE *adaboostTxt; // save the sampled examples information
  string fileName =  output_folder + "/cifar10_train_adaboost_" + caffe::format_int(adaboost_lmdb_id) + ".txt";
  adaboostTxt = fopen(fileName.c_str(), "w"); 
  LOG(INFO) << "Open the  " << fileName << " for writting the sampled images.";
         
int countTimesOpenLMDB = 0; 
  while ( adaboost_image_id < datasize ){
     LOG(INFO) << "Open the traing batch " << ++countTimesOpenLMDB << "th time for Writing";


    for (int fileid = 0; fileid < kCIFARTrainBatches; ++fileid) {
      // Open files
      LOG(INFO) << "Training Batch " << fileid + 1;
      string batchFileName = input_folder + "/data_batch_"
	+ caffe::format_int(fileid+1) + ".bin";
      std::ifstream data_file(batchFileName.c_str(),
			      std::ios::in | std::ios::binary);
      CHECK(data_file) << "Unable to open train file #" << fileid + 1;
      for (int itemid = 0; itemid < kCIFARBatchSize; ++itemid) {
	read_image(&data_file, &label, str_buffer);
	 float threshold = Dis[fileid * kCIFARBatchSize + itemid ];
	 if (threshold == 0) continue;

	float tmp_rand = rand() / (float)RAND_MAX;
	//printf(" tmp_rand = %f \n", tmp_rand  );
	if (tmp_rand <= threshold ) {
	  //printf(" tmp_rand <= %f, so [write] this example to lmdb \n", threshold );
	  datum.set_label(label);
	  datum.set_data(str_buffer, kCIFARImageNBytes);
	  string out;
	  CHECK(datum.SerializeToString(&out));
	  //txn->Put(caffe::format_int(fileid * kCIFARBatchSize + itemid, 5), out);


	//the following code is to speed up the process of generating the lmdb
	for (int pushTimesCount = 0; pushTimesCount < ceil( threshold ); ++pushTimesCount) { 

		  txn->Put(caffe::format_int(adaboost_image_id, 5), out);
		  fprintf(adaboostTxt, "%d %d %d\n", adaboost_image_id, label, fileid * kCIFARBatchSize + itemid ); //
		  //printf("writting the  %d th data \n", adaboost_image_id + 1);
		  if ( ++adaboost_image_id == datasize ) {
		    end_flag = 1;
		    break; //break the inner loop
		  }

		  //if ( adaboost_image_id  % 10000 == 0) {
		  //  printf("processing %d images done \n", adaboost_image_id );
		 // }

	}
	if (end_flag == 1 ) break; // break the while loop

	}
	//else {
	// printf(" tmp_rand > %f, so don't write this example to lmdb \n", threshold  );
	//	}
      } //inner loop for end
	//if ( adaboost_image_id  % 10000 == 0) {
	//    printf("processing %d images done \n", adaboost_image_id );
	//  }
      //the second condition check (adaboost_image_id >= datasize) is not needed 
      if (end_flag == 1 ) break; // break the outer for loop
    } //outer loop for end

   printf("processing %d images done \n", adaboost_image_id );
  } // end of while
  txn->Commit();
  train_db->Close();
  fclose(adaboostTxt); //close the adaboost txt writing
} //end of void

int main(int argc, char** argv) {
  FLAGS_alsologtostderr = 1;

  if (argc != 6) {
    printf("This script converts the CIFAR dataset to the leveldb format used\n"
           "by caffe to perform classification.\n"
           "Usage:\n"
           "    convert_cifar_data input_folder output_folder db_type number_of_adaboost_lmdb_to_create \n"
           "Where the input folder should contain the binary batch files.\n"
           "The CIFAR dataset could be downloaded at\n"
           "    http://www.cs.toronto.edu/~kriz/cifar.html\n"
           "You should gunzip them after downloading.\n");
  } else {
    google::InitGoogleLogging(argv[0]);
    //number_of_adaboost_lmdb_to_create
    int adaboost_id = atoi(string(argv[4]).c_str());
    //int num =int( argv[4] );  //note, it doesnot work for this command

    // for (int adaboost_id = 0;  adaboost_id < num; ++ adaboost_id) {
      // LOG(INFO) <<" cifar10_train_adaboost_" << adaboost_id <<"_lmdb creating ...";
       convert_dataset(string(argv[1]), string(argv[2]), string(argv[3]), adaboost_id, string(argv[5]));
     //}
  } 
  return 0;
} 
