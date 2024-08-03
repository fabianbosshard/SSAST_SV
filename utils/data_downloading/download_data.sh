#!/bin/bash

# Function to display error message and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Check if we're running inside a Docker container
if [ ! -f /.dockerenv ]; then
    error_exit "This script must be run inside a Docker container."
fi

# Check if we're running inside a SLURM allocation
if [ -z "$SLURM_JOB_ID" ]; then
    error_exit "This script must be run within a SLURM allocation."
fi

# Print environment information (optional, but can be helpful for logging)
echo "Running in Docker container with SLURM job ID: $SLURM_JOB_ID"

# Set the download directory to the raid storage
BASE_DIR="/raid/xbfr"

# Function to download and process data
download_and_process() {
    local dataset=$1

    case $dataset in
        "librispeech")
            # LibriSpeech download logic here
            download_urls=(
                "https://www.openslr.org/resources/12/train-clean-100.tar.gz"
                "https://www.openslr.org/resources/12/train-clean-360.tar.gz"
                "https://www.openslr.org/resources/12/train-other-500.tar.gz"
            )
            download_dir="$BASE_DIR/data/librispeech"

            # Create directory if it doesn't exist
            mkdir -p "$download_dir" || error_exit "Failed to create directory: $download_dir"

            # Iterate over the list of download URLs
            for url in "${download_urls[@]}"; do
                tar_file="$download_dir/file$i.tar.gz"

                # Download the data
                echo "Downloading data from $url ..."
                wget -O "$tar_file" "$url" || error_exit "Failed to download data from $url"

                # Extract the data
                echo "Extracting data to $download_dir ..."
                tar -xzvf "$tar_file" -C "$download_dir" || error_exit "Failed to extract data"

                # Remove the tar file
                rm "$tar_file"

                # Find Subdir with data
                subdirs=$(find "$download_dir"/LibriSpeech -mindepth 2 -maxdepth 2 -type d)

                for subdir in $subdirs; do
                    files=$(find "$subdir" -mindepth 1 -type f -name "*.flac")
                    speakerId=$(basename $subdir)
                    for file in $files; do
                        fileName=$(basename $file)
                        mkdir -p "$download_dir/$speakerId" || error_exit "Failed to create directory: $download_dir/$speakerId"
                        # Move the contents of each subdirectory to $download_dir
                        mv "$file" "$download_dir/$speakerId/$fileName" || error_exit "Failed to move files"
                    done
                done
                
                # Remove src dir
                rm -r "$download_dir"/LibriSpeech || error_exit "Failed to remove source dir"

                echo "Data extraction completed successfully."
            done
            ;;

        "voxceleb")
            # VoxCeleb download logic here
            download_urls=(
                "https://huggingface.co/datasets/ProgramComputer/voxceleb/resolve/main/vox1/vox1_test_wav.zip?download=true"
                "https://huggingface.co/datasets/ProgramComputer/voxceleb/resolve/main/vox1/vox1_dev_wav.zip?download=true"
                "https://huggingface.co/datasets/ProgramComputer/voxceleb/resolve/main/vox2/vox2_aac_1.zip?download=true"
                "https://huggingface.co/datasets/ProgramComputer/voxceleb/resolve/main/vox2/vox2_aac_2.zip?download=true"
            )
            download_dir="$BASE_DIR/data/voxcelebtemp"
            dest_dir="$BASE_DIR/data/voxceleb"

            # Create directory if it doesn't exist
            mkdir -p "$dest_dir" || error_exit "Failed to create directory: $dest_dir"

            # Iterate over the list of download URLs
            for url in "${download_urls[@]}"; do
                # Create directory
                mkdir -p "$download_dir" || error_exit "Failed to create directory: $download_dir"
                zip_file="$download_dir/file.zip"

                # Download the data
                echo "Downloading data from $url ..."
                wget -O "$zip_file" "$url" || error_exit "Failed to download data from $url"

                # Extract the data
                echo "Extracting data to $download_dir ..."
                unzip "$zip_file" -d "$download_dir" || error_exit "Failed to extract data"

                # Remove the zip file
                rm "$zip_file"

                # Find Subdir with data
                subdirs=$(find "$download_dir" -type d  -name "id[0-9]*")

                for subdir in $subdirs; do
                    files=$(find "$subdir" -type f)
                    speakerId=$(basename "$subdir")

                    # Create speaker dir if not exists
                    mkdir -p "$dest_dir/$speakerId" || error_exit "Failed to create directory: $dest_dir/$speakerId"

                    for file in $files; do
                        mv "$file" "$dest_dir/$speakerId"
                    done
                done
                
                # Remove Download dir
                rm -r "$download_dir"
            done
            echo "Data extraction completed successfully."
            ;;

        "audioset")
            # AudioSet download logic here
            processUrl() {
                local download_dir=$1
                local dest_dir=$2
                local url=$3

                tar_file="$download_dir/file.tar.gz"

                mkdir -p "$download_dir" || error_exit "Failed to create directory: $download_dir"

                # Download the data
                echo "Downloading data from $url ..."
                wget -O "$tar_file" "$url" || error_exit "Failed to download data from $url"

                # Extract the data
                echo "Extracting data to $download_dir ..."
                tar -xvf "$tar_file" -C "$download_dir" || error_exit "Failed to extract data"

                # Remove the tar file
                rm "$tar_file"

                # Find Subdir with data
                files=$(find "$download_dir" -type f -name "*.flac")

                for file in $files; do
                    basename=$(basename "$file")
                    uid=$(uuidgen)
                    # Resample file to 16khz mono
                    ffmpeg -i "$file" -ar 16000 -ac 1 -sample_fmt s16 "$dest_dir/$uid$basename"
                done

                # Remove src dir
                rm -r "$download_dir" || error_exit "Failed to remove source dir"
            }

            # Define the base URL
            base_url="https://huggingface.co/datasets/agkphysics/AudioSet/resolve/main/data/unbal_train"

            download_dir="$BASE_DIR/data/audiosettemp"
            dest_dir="$BASE_DIR/data/audioset/unbal"

            # Create directory if it doesn't exist
            mkdir -p "$download_dir" || error_exit "Failed to create directory: $download_dir"
            mkdir -p "$dest_dir" || error_exit "Failed to create directory: $dest_dir"

            # Define the total number of links you need
            total_links=869

            # Loop to generate the URLs
            for ((i=0; i<=total_links-4; i+=4)); do
                # Generate the URL and add it to the array
                url1="$base_url$(printf '%03d' "$((i))").tar?download=true"
                url2="$base_url$(printf '%03d' "$((i+1))").tar?download=true"
                url3="$base_url$(printf '%03d' "$((i+2))").tar?download=true"
                url4="$base_url$(printf '%03d' "$((i+3))").tar?download=true"

                processUrl "$download_dir/1" "$dest_dir" "$url1" &
                processUrl "$download_dir/2" "$dest_dir" "$url2" &
                processUrl "$download_dir/3" "$dest_dir" "$url3" &
                processUrl "$download_dir/4" "$dest_dir" "$url4" &

                wait
            done

            url1="$base_url$(printf '%03d' "868").tar?download=true"
            url2="$base_url$(printf '%03d' "869").tar?download=true"
            processUrl "$download_dir/1" "$dest_dir" "$url1" &
            processUrl "$download_dir/2" "$dest_dir" "$url2" &

            wait

            download_urls=(
                "https://huggingface.co/datasets/agkphysics/AudioSet/resolve/main/data/eval00.tar?download=true"
                "https://huggingface.co/datasets/agkphysics/AudioSet/resolve/main/data/eval01.tar?download=true"
                "https://huggingface.co/datasets/agkphysics/AudioSet/resolve/main/data/eval02.tar?download=true"
                "https://huggingface.co/datasets/agkphysics/AudioSet/resolve/main/data/eval03.tar?download=true"
                "https://huggingface.co/datasets/agkphysics/AudioSet/resolve/main/data/eval04.tar?download=true"
                "https://huggingface.co/datasets/agkphysics/AudioSet/resolve/main/data/eval05.tar?download=true"
                "https://huggingface.co/datasets/agkphysics/AudioSet/resolve/main/data/eval06.tar?download=true"
                "https://huggingface.co/datasets/agkphysics/AudioSet/resolve/main/data/eval07.tar?download=true"
                "https://huggingface.co/datasets/agkphysics/AudioSet/resolve/main/data/eval08.tar?download=true"
            )

            download_dir="$BASE_DIR/data/audiosettemp"
            dest_dir="$BASE_DIR/data/audioset/eval"

            # Create directory if it doesn't exist
            mkdir -p "$download_dir" || error_exit "Failed to create directory: $download_dir"
            mkdir -p "$dest_dir" || error_exit "Failed to create directory: $dest_dir"

            # Iterate over the list of download URLs
            for url in "${download_urls[@]}"; do
                tar_file="$download_dir/file.tar.gz"
                
                # Create directory if it doesn't exist
                mkdir -p "$download_dir" || error_exit "Failed to create directory: $download_dir"

                # Download the data
                echo "Downloading data from $url ..."
                wget -O "$tar_file" "$url" || error_exit "Failed to download data from $url"

                # Extract the data
                echo "Extracting data to $download_dir ..."
                tar -xvf "$tar_file" -C "$download_dir" || error_exit "Failed to extract data"

                # Remove the tar file
                rm "$tar_file"

                # Find Subdir with data
                files=$(find "$download_dir"/audio -mindepth 1 -type f -name "*.flac")

                for file in $files; do
                    basename=$(basename "$file")
                    uid=$(uuidgen)
                    # Resample file to 16khz mono
                    ffmpeg -i "$file" -ar 16000 -ac 1 -sample_fmt s16 "$dest_dir/$uid$basename"
                done

                # Remove src dir
                rm -r "$download_dir" || error_exit "Failed to remove source dir"
            done
            ;;
        *)
            error_exit "Invalid dataset. Please specify 'librispeech', 'voxceleb', or 'audioset'."
            ;;
    esac
}

# Main execution
if [ "$#" -ne 1 ]; then
    error_exit "Usage: $0 <dataset>"
fi

# Download and process the specified dataset
download_and_process "$1"

echo "Data download and processing completed successfully."