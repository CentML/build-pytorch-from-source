# Build PyTorch From Source

Sometimes, building [PyTorch](https://github.com/pytorch/pytorch) from source, 
especially into a Docker image, could be daunting, and [PyTorch's official repo](https://github.com/pytorch/pytorch) 
does not include many *clean* and *working* example scripts (sure, you could dig into 
PyTorch's CI scripts, if you have the time and patience). Hence, this repo serves as a 
*clean*, *working* and easy-to-tinker example of showing how to do so.

## Usage

```bash
git clone https://github.com/CentML/build-pytorch-from-source.git
cd build-pytorch-from-source/
<environment variable>=<value> ... bash build.sh <tag> <push> <dockerfile>
```

- `<tag>` is the tage that you name the resulting image with.
- `<push>` is `push` (if you want to push this image to an image registry) or `none`.
- `<dockerfile>` is the path to the Dockerfile that you want to use. 

### Environment Variables

- `COMMIT` is the commit SHA from PyTorch's official repo.
- `CUDA_TAG` is the tag of the CUDA image that you can find from [here](https://hub.docker.com/r/nvidia/cuda).
  Do make sure that your NVIDIA GPU driver supports the CUDA version that you want to
  use.
- `PYTHON_VERSION` is the Python version (I suppose only 3.8+ is supported these days).
- `USE_MPI` enables/disables distributed MPI backend build. Please refer to [here](https://github.com/pytorch/pytorch/blob/master/setup.py).
- `TORCH_CUDA_ARCH_LIST` is the CUDA architectures to build for. Please refer to [here](https://github.com/pytorch/pytorch/blob/master/setup.py).

Please submit a PR if you find some environment variables you want to have but this 
script currently doesn't have.

## Example

```bash
PYTHON_VERSION=3.8 USE_MPI=1 bash build.sh my-pytorch:latest
```

## Tested

```bash
COMMIT=712bd9ae8826cb11d2989bbe5f7b4e1cc3802831 \
CUDA_TAG=12.0.1-cudnn8-devel-ubuntu22.04 \
PYTHON_VERSION=3.8 \
USE_MPI=1 \
TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0" \
bash build.sh
```

wangshangsam/pytorch:2.1.0a0git7711d24717a2a76a202c3438286aaf87d4dc359c-cuda12.0.1-cudnn8-devel-ubuntu22.04-py38:
```bash
COMMIT=7711d24717a2a76a202c3438286aaf87d4dc359c \
CUDA_TAG=12.0.1-cudnn8-devel-ubuntu22.04 \
PYTHON_VERSION=3.8 \
USE_MPI=1 \                                     
TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0" \
bash build.sh
```

## Disclaimer

As you can see in the [LICENSE](LICENSE), this is a piece of free (in every sense of the 
word) software, so use it at your own risk!

This is not an official CentML product. My initial motivation to build it is only for 
my own convenience.
