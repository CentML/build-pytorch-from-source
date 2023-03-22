#!/bin/bash

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

build_pytorch_image () {
  local tag=${1:-"pytorch:latest"}
  local cuda_tag=${2:-"12.0.1-cudnn8-devel-ubuntu22.04"}
  local dockerfile=${3:-"pyt.Dockerfile"}
  local push=${4:-"none"}  # "push" or "none"

  local ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  local ram_gb=$(expr $ram_kb / 1024 / 1024)

  if [[ -z "${COMMIT}" ]]; then
    local build_arg_flag_commit="--build-arg COMMIT=${COMMIT}"
  else
    local build_arg_flag_commit=""
  fi

  docker build \
    --pull \
    --network=host \
    -m ${ram_gb}g \
    --rm \
    --build-arg CUDA_TAG=${cuda_tag} \
    ${build_arg_flag_commit} \
    -t ${tag} \
    - < ${dockerfile}

  _push_image ${push} ${pi_api_url}
}
