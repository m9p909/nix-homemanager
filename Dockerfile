FROM debian:bookworm-slim

# Build arguments for user customization
ARG UID=1000
ARG GID=1000
ARG USER=jack

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    xz-utils \
    ca-certificates \
    sudo \
    openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

# Create user with specified UID/GID and set password
RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} && \
    echo "${USER}:dev" | chpasswd && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/${USER}/.ssh && \
    chown ${USER}:${USER} /home/${USER}/.ssh && \
    chmod 700 /home/${USER}/.ssh

# Install Nix as multi-user (daemon mode - system-wide)
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon && \
    usermod -aG nixbld ${USER}

# Set up Nix environment
ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"
ENV NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Switch to user for home-manager setup
USER ${USER}
WORKDIR /home/${USER}

# Enable experimental features (flakes and nix-command)
RUN mkdir -p /home/${USER}/.config/nix && \
    echo "experimental-features = nix-command flakes" > /home/${USER}/.config/nix/nix.conf

# Copy home-manager configuration
COPY --chown=${USER}:${USER} . /home/${USER}/.config/home-manager/

# Initialize home-manager during build (takes 5-10 minutes)
RUN nix run home-manager/master -- switch --flake /home/${USER}/.config/home-manager#jack

# Copy entrypoint script
USER root
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Set working directory
WORKDIR /home/${USER}

# Entry point: initialization script
ENTRYPOINT ["/entrypoint.sh"]
