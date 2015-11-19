# Cookbook Name:: neon-opencv
# Attributes:: default
# Author:: Mark Desnoyer <desnoyer@neon-lab.com>
#
# Copyright 2014, Neon Labs Inc.
#
# All rights reserved - Do Not Redistribute
#

# Location of the OpenCV repo
default[:opencv][:repo] = "https://github.com/neon-lab/opencv.git"

# The version of OpenCV to install. This will be a tag from the repo
default[:opencv][:version] = "neon-3.0" #"2.4.9-neon-fix4939"

# Where to install opencv
default[:opencv][:install_prefix] = "/usr/local"

# Options for what parts of OpenCV to install
default[:opencv][:with_cuda] = false # TODO(mdesnoyer): Implement CUDA install
default[:opencv][:with_python] = true
default[:opencv][:with_firewire] = false
default[:opencv][:with_qt] = true
default[:opencv][:with_gstreamer] = false
default[:opencv][:with_v4l] = false
default[:opencv][:with_tbb] = true

# Options for where to build OpenCV
default[:opencv][:build_dir] = "/tmp/opencv"

# Options for opencv_contrib
default[:opencv][:include_contrib] = true
default[:opencv][:contrib_dir] = "/opt/neon/opencv_contrib"
default[:opencv][:contrib_repo] = "https://github.com/neon-lab/opencv_contrib.git"
default[:opencv][:contrib_version] = "neon-3.0"
