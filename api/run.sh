#!/bin/bash

 # Check if the MODEL environment variable is set
 if [ -z "$MODEL" ]
 then
     echo "Please set the MODEL_FILE environment variable"
     exit 1
 fi

 # Check if the MODEL_DOWNLOAD_URL environment variable is set
 if [ -z "$MODEL_DOWNLOAD_URL" ]
 then
     echo "Please set the MODEL_DOWNLOAD_URL environment variable"
     exit 1
 fi

 # Check if the model file exists
 if [ ! -f $MODEL ]; then
     echo "Model file not found. Downloading..."
     # Check if curl is installed
     if ! [ -x "$(command -v curl)" ]; then
         echo "curl is not installed. Installing..."
         apt-get update --yes --quiet
         apt-get install --yes --quiet curl
     fi
     # Download the model file
     curl -L -o $MODEL $MODEL_DOWNLOAD_URL
     if [ $? -ne 0 ]; then
         echo "Download failed. Trying with TLS 1.2..."
         curl -L --tlsv1.2 -o $MODEL $MODEL_DOWNLOAD_URL
     fi
 else
     echo "$MODEL model found."
 fi

# Build the project
make build

# Get the number of available CPU threads
n_threads=$(grep -c ^processor /proc/cpuinfo) 

# Define context window
n_ctx=4096

# Offload everything to CPU
n_gpu_layers=0

# Define batch size based on total RAM
total_ram=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
n_batch=2096
if [ $total_ram -lt 8000000 ]; then
    n_batch=1024
fi

if ! [ -x "$(command -v pip3)" ]; then
  echo "pip3 is not installed. Installing..."
  apt-get update --yes --quiet
  apt-get install --yes --quiet python3-pip
fi
if ! [ -x "$(command -v git)" ]; then
  echo "pip3 is not installed. Installing..."
  apt-get update --yes --quiet
  apt-get install --yes --quiet git
fi

pip3 install cython
pip3 install numpy
pip3 install mmh3
pip3 install requests
git clone https://github.com/boisgera/bitstream.git
cd bitstream
python3 setup.py --cython install
cd ../

# run the lick interface
#ls /app
exec python3 /lick/lick-ai-interface.py &


# Display configuration information
echo "Initializing server with:"
echo "Batch size: $n_batch"
echo "Number of CPU threads: $n_threads"
echo "Number of GPU layers: $n_gpu_layers"
echo "Context window: $n_ctx"

# Run the server
exec python3 -m llama_cpp.server --n_ctx $n_ctx --n_threads $n_threads --n_gpu_layers $n_gpu_layers --n_batch $n_batch 
#
#
