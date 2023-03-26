ARG CUDA_TAG
FROM nvidia/cuda:${CUDA_TAG}

ARG COMMIT
ARG VISION_COMMIT
ARG AUDIO_COMMIT
ARG PYTHON_VERSION
ARG USE_MPI
ARG TORCH_CUDA_ARCH_LIST
ARG MINICONDA_VERSION

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -qq && \
    apt install -y --no-install-recommends wget git ccache && \
    rm -rf /var/cache/apk/*

# Step 1: Install conda and Python.
WORKDIR /Downloads
ARG CONDA_INSTALL_SCRIPT=Miniconda3-${MINICONDA_VERSION}.sh
ARG CONDA_INSTALL_DIR=/opt/conda
RUN wget https://repo.anaconda.com/miniconda/${CONDA_INSTALL_SCRIPT} && \
    bash ${CONDA_INSTALL_SCRIPT} -b -p ${CONDA_INSTALL_DIR} && \
    rm -f ${CONDA_INSTALL_SCRIPT}
ENV PATH=${CONDA_INSTALL_DIR}/bin:${PATH}
RUN conda install -y python=${PYTHON_VERSION} pip

# Step 2: Build PyTorch from source.
WORKDIR /Downloads
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

# Step 3: Build torchvision from source.
WORKDIR /Downloads
RUN git clone https://github.com/pytorch/vision.git
WORKDIR /Downloads/vision
RUN git checkout ${VISION_COMMIT}

RUN conda install -y libpng jpeg scipy chardet
RUN FORCE_CUDA=1 python setup.py develop

# Step 4. Build torchaudio from source.
WORKDIR /Downloads
RUN git clone --recursive https://github.com/pytorch/audio.git
WORKDIR /Downloads/audio
RUN git checkout ${AUDIO_COMMIT} && \
    git submodule sync && \
    git submodule update --init --recursive

RUN conda install -y pkg-config && \
    conda install -y ffmpeg -c conda-forge
RUN USE_FFMPEG=1 python setup.py develop
