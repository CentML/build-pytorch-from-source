ARG CUDA_TAG
FROM nvidia/cuda:${CUDA_TAG}

ARG COMMIT
ARG PYTHON_VERSION
ARG USE_MPI
ARG TORCH_CUDA_ARCH_LIST
ARG MINICONDA_VERSION

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -qq && \
    apt install -y --no-install-recommends wget git ccache && \
    rm -rf /var/cache/apk/*

WORKDIR /Downloads
ARG CONDA_INSTALL_SCRIPT=Miniconda3-${MINICONDA_VERSION}.sh
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

RUN conda install -y cmake ninja
RUN conda install -y -c conda-forge libstdcxx-ng
RUN pip install -r requirements.txt
RUN conda install -y mkl mkl-include
# The problem with magma-cuda* is that it's always significant lagging behind the 
# latest CUDA version.
# RUN conda install -c pytorch magma-cuda110
RUN CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"} \
    USE_MPI=${USE_MPI} \
    TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST} \
    python setup.py develop
