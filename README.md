# Using the SSAST for SV


## Introduction

This repository explores the application of transformer neural networks in the domain of automatic speaker recognition (ASR). The project focuses on investigating whether transformer architectures can effectively capture and learn voice dynamics (_prosodic features_) when trained for speaker verification. It is based on https://github.com/YuanGongND/ssast.


## Getting Started
Clone the Repo:
```
git clone https://github.com/fabianbosshard/SSAST_SV.git
git lfs fetch
```

## Data Download Process for DGX Server

This section provides step-by-step commands for running the data download process on the CAI DGX server ([documentation](https://cai.cloudlab.zhaw.ch/pages/gpu.html)).


Navigate to the `utils/data_downloading` directory:
   ```bash
   cd utils/data_downloading
   ```

Start a screen session:
   ```bash
   screen
   ```

Start a SLURM session:
   ```bash
   srun --job-name=xbfr_data_download --pty --ntasks=1 --cpus-per-task=4 --mem=16G --gres=gpu:0 bash
   ```

Build the Docker image (paste as one line):
   ```bash
   docker build \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
  -t xbfr_data_download_img .
   ```

Run the Docker container (paste as one line):
   ```bash
   nvidia-docker run --rm -it \
    --shm-size=16g \
    --name xbfr_data_download \
    --volume /cluster/home/xbfr/SSAST_SV:/workspace/SSAST_SV \
    --volume /raid/xbfr:/raid/xbfr \
    --env SLURM_JOB_ID \
    xbfr_data_download_img bash
   ```

Inside the Docker container, run the download script:
   ```bash
   cd /workspace
   ./download_data.sh librispeech  # or voxceleb or audioset
   ```

Exit the Docker container:
   ```bash
   exit
   ```

Exit the SLURM session:
   ```bash
   exit
   ```

Exit the screen session:
   ```bash
   exit
   ```

Repeat the process for the other datasets (VoxCeleb and AudioSet) by changing the argument of the `download_data.sh` script accordingly.