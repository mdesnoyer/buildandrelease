# Cookbook Name:: neon-opencv
# Attributes:: default
# Author:: Mark Desnoyer <desnoyer@neon-lab.com>
#
# Copyright 2014, Neon Labs Inc.
#
# All rights reserved - Do Not Redistribute
#

# Location of the OpenCV repo
default[:opencv][:repo] = "https://github.com/Itseez/opencv.git"

# The version of OpenCV to install. This will be a tag from the repo
default[:opencv][:version] = "2.4.9"

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
default[:opencv][:build_path] = "/tmp/opencv"
