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

### LibriSpeech

Start a screen session:
   ```bash
   screen
   ```

Start a SLURM session:
   ```bash
   srun --job-name=xbfr_data_download_librispeech --pty --ntasks=1 --cpus-per-task=4 --mem=16G --gres=gpu:0 bash
   ```

Build the Docker image (paste as one line):
   ```bash
   docker build \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
  -t xbfr_data_download_librispeech_img .
   ```

Run the Docker container (paste as one line):
   ```bash
   nvidia-docker run --rm -it \
    --shm-size=16g \
    --name xbfr_data_download_librispeech \
    --volume /cluster/home/xbfr/SSAST_SV:/workspace/SSAST_SV \
    --volume /raid/xbfr:/raid/xbfr \
    --env SLURM_JOB_ID \
    xbfr_data_download_librispeech_img bash
   ```

Inside the Docker container, run the download script:
   ```bash
   ./download_data.sh librispeech
   ```

Detach from the screen session by pressing `Ctrl + A` followed by `D`.

### VoxCeleb

Start a screen session:
   ```bash
   screen
   ```

Start a SLURM session:
   ```bash
   srun --job-name=xbfr_data_download_voxceleb --pty --ntasks=1 --cpus-per-task=4 --mem=16G --gres=gpu:0 bash
   ```

Build the Docker image (paste as one line):
   ```bash
   docker build \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
  -t xbfr_data_download_voxceleb_img .
   ```

Run the Docker container (paste as one line):
   ```bash
   nvidia-docker run --rm -it \
    --shm-size=16g \
    --name xbfr_data_download_voxceleb \
    --volume /cluster/home/xbfr/SSAST_SV:/workspace/SSAST_SV \
    --volume /raid/xbfr:/raid/xbfr \
    --env SLURM_JOB_ID \
    xbfr_data_download_voxceleb_img bash
   ```

Inside the Docker container, run the download script:
   ```bash
   ./download_data.sh voxceleb
   ```

Detach from the screen session by pressing `Ctrl + A` followed by `D`.

### AudioSet

Start a screen session:
   ```bash
   screen
   ```

Start a SLURM session:
   ```bash
   srun --job-name=xbfr_data_download_audioset --pty --ntasks=1 --cpus-per-task=4 --mem=16G --gres=gpu:0 bash
   ```

Build the Docker image (paste as one line):
   ```bash
   docker build \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
  -t xbfr_data_download_audioset_img .
   ```

Run the Docker container (paste as one line):
   ```bash
   nvidia-docker run --rm -it \
    --shm-size=16g \
    --name xbfr_data_download_audioset \
    --volume /cluster/home/xbfr/SSAST_SV:/workspace/SSAST_SV \
    --volume /raid/xbfr:/raid/xbfr \
    --env SLURM_JOB_ID \
    xbfr_data_download_audioset_img bash
   ```

Inside the Docker container, run the download script:
   ```bash
   ./download_data.sh audioset
   ```

Detach from the screen session by pressing `Ctrl + A` followed by `D`.


### Exiting the Sessions

After a while, the datasets will have been downloaded. Reattach to the screen sessions using their respective identifiers:
   ```bash
   screen -r <screen_id>
   ```
Follow the instructions below to exit the Docker container, SLURM session, and screen session.

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

Repeat these steps for each screen session.