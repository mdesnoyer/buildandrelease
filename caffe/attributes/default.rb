include_attribute "neon::default"

default["caffe"]["software_dir"] = "#{node[:neon][:home]}/caffe"
default["caffe"]["local_user"] = "ubuntu"
default["caffe"]["local_group"] = "ubuntu"
default["caffe"]["remote_dir"] = "https://neon-dependencies.s3.amazonaws.com"
default["caffe"]["cudnn_tarball_name_wo_tgz"] = "cudnn-7.0-linux-x64-v3.0-rc"
default["caffe"]["glog_tarball_name_wo_tgz"] = "glog-0.3.3"

#default["caffe"]["glog_deb_file"] = "https://neon-dependencies.s3.amazonaws.com/libgoogle-glog-dev_0.3.4-0.1+b1_amd64"
#default["caffe"]["glog_pre_deb_file"] = "https://s3-us-west-1.amazonaws.com/neon-dependencies/libgoogle-glog0v5_0.3.4-0.1%2Bb1_amd64"
#default["caffe"]["glog_deb_file"] = "https://s3-us-west-1.amazonaws.com/neon-dependencies/libgoogle-glog-dev_0.3.4-0.1%2Bb1_amd64"
#default["caffe"]["lmdb_deb_file"] = "https://neon-dependencies.s3.amazonaws.com/liblmdb-dev_0.9.15-1_amd64"
#default["caffe"]["CUDA_deb_file"] = "https://neon-dependencies.s3.amazonaws.com/cuda-repo-ubuntu1204-7-0-local_7.0-28_amd64"
# decide whether or not it will launch interactive tools
#default["caffe"]["interactive"] = true
