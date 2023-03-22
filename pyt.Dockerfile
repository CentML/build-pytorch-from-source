ARG CUDA_TAG
FROM nvidia/cuda:${CUDA_TAG}

ARG COMMIT=3282030fa4cce46f1714c570484a81f059a83615

ARG PYTHON_VERSION=3.8
ARG USE_MPI=1
ARG TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -qq && \
    apt install -y --no-install-recommends wget git build-essential cmake ninja-build \
      ccache && \
    rm -rf /var/cache/apk/*

WORKDIR /Downloads
ARG CONDA_INSTALL_SCRIPT=Miniconda3-py38_23.1.0-1-Linux-x86_64.sh
ARG CONDA_INSTALL_DIR=/opt/conda
RUN wget https://repo.anaconda.com/miniconda/${CONDA_INSTALL_SCRIPT} && \
    bash ${CONDA_INSTALL_SCRIPT} -b -p ${CONDA_INSTALL_DIR} && \
    rm -f ${CONDA_INSTALL_SCRIPT}
ENV PATH=${CONDA_INSTALL_DIR}/bin:${PATH}
RUN conda install -y python=${PYTHON_VERSION} pip

RUN git clone --recursive https://github.com/pytorch/pytorch
WORKDIR /Downloads/pytorch
RUN git checkout ${COMMIT} && \
    git submodule sync && \
    git submodule update --init --recursive

RUN pip install -r requirements.txt
RUN conda install mkl mkl-include
RUN USE_MPI=${USE_MPI} TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST} python setup.py develop
