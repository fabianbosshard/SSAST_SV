# Start with an NVIDIA CUDA base image. This provides CUDA support for GPU operations.
FROM nvidia/cuda:11.6.2-base-ubuntu20.04

# Set an environment variable to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package lists and install necessary packages
# The backslash (\) allows us to break the command into multiple lines for readability
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    unzip \
    ffmpeg \
    python3 \
    python3-pip \
    uuid-runtime \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up arguments that will be passed when building the image
# These will be used to create a user with the same UID and GID as the host user
ARG USER_ID
ARG GROUP_ID

# Create a non-root user with the same UID and GID as the host user
# This helps avoid permission issues when mounting volumes
RUN groupadd -g $GROUP_ID user && \
    useradd -m -u $USER_ID -g $GROUP_ID -s /bin/bash user && \
    # Give the user sudo privileges without requiring a password
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set the working directory inside the container
# This is where we'll copy our script and where commands will run by default
WORKDIR /workspace

# Copy the download script from the host into the container
COPY download_data.sh /workspace/

# Make the script executable and change its ownership to the new user
RUN chmod +x /workspace/download_data.sh && \
    chown user:user /workspace/download_data.sh

# Switch to the non-root user
# This ensures that the container runs as this user by default
USER user

# Set the default command to run when the container starts
# In this case, it starts an interactive bash shell
CMD ["/bin/bash"]