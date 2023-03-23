#!/bin/bash

set -eux

# Helper functions.
_push_image () {
  local push=$1
  local url=$2
  if [ "${push}" == "push" ]; then
    docker push ${url}
  elif [ "${push}" == "none" ]; then
    echo "Keep the built image locally."
  else
    echo "Invalid \${PUSH} option: ${push} !"
    exit 1
  fi
}

# Pass in as in positional arguments.
tag=${1:-"pytorch:latest"}
push=${2:-"none"}  # "push" or "none"
dockerfile=${3:-"pyt.Dockerfile"}

# Pass in as in environment variables.
COMMIT=${COMMIT:-"3282030fa4cce46f1714c570484a81f059a83615"}
CUDA_TAG=${CUDA_TAG:-"12.0.1-cudnn8-devel-ubuntu22.04"}
PYTHON_VERSION=${PYTHON_VERSION:-"3.8"}
USE_MPI=${USE_MPI:-"1"}
TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST:-"7.0;7.5;8.0;8.6;8.9;9.0"}

# Local variables.
shm_gb=8
ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
ram_gb=$(expr $ram_kb / 1024 / 1024 - $shm_gb)
miniconda_version=py${PYTHON_VERSION//.}_23.1.0-1-Linux-x86_64

docker build \
  --pull \
  --network=host \
  -m ${ram_gb}g \
  --shm-size ${shm_gb}g \
  --rm \
  --build-arg CUDA_TAG=${CUDA_TAG} \
  --build-arg COMMIT=${COMMIT} \
  --build-arg PYTHON_VERSION=${PYTHON_VERSION} \
  --build-arg USE_MPI=${USE_MPI} \
  --build-arg TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST} \
  --build-arg MINICONDA_VERSION="${miniconda_version}" \
  -t ${tag} \
  - < ${dockerfile}

_push_image ${push} ${tag}
