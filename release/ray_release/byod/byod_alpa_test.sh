#!/bin/bash
# This script is used to build an extra layer on top of the base anyscale/ray image 
# to run the horovod tests

set -exo pipefail

pip3 install -U cupy-cuda113 numpy==1.21.0 protobuf==3.20.0

pip3 install --upgrade pip
git clone https://github.com/alpa-projects/alpa.git
pip3 install -e alpa
pip3 install -e alpa/examples
pip install jaxlib==0.3.22+cuda113.cudnn820 -f https://alpa-projects.github.io/wheels.html
pip3 install --no-cache-dir nvidia-pyindex
pip3 install --no-cache-dir nvidia-tensorrt==7.2.3.4
pip install -U transformers==4.23.1
pip install -U accelerate
