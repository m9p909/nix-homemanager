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

# Switch to user for Nix installation
USER ${USER}
WORKDIR /home/${USER}

# Install Nix as user (single-user mode - no daemon needed)
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Set up Nix environment
ENV PATH="/home/${USER}/.nix-profile/bin:${PATH}"
ENV NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# Enable experimental features (flakes and nix-command)
RUN mkdir -p /home/${USER}/.config/nix && \
    echo "experimental-features = nix-command flakes" > /home/${USER}/.config/nix/nix.conf

# Copy home-manager configuration
COPY --chown=${USER}:${USER} . /home/${USER}/.config/home-manager/

# Create initialization script
# Note: home-manager must initialize at runtime due to container filesystem path length limits
USER root
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Initialize home-manager on first run\n\
if [ ! -f /home/jack/.local/state/.hm-initialized ]; then\n\
  echo "Initializing home-manager (this will take 5-10 minutes on first run)..."\n\
  mkdir -p /home/jack/.local/state\n\
  chown jack:jack /home/jack/.local/state\n\
  \n\
  # Run as jack user with proper Nix environment\n\
  su jack -s /bin/bash -c '\''set -e\n\
    export HOME=/home/jack\n\
    export USER=jack\n\
    export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt\n\
    cd /home/jack\n\
    if [ -e /home/jack/.nix-profile/etc/profile.d/nix.sh ]; then\n\
      . /home/jack/.nix-profile/etc/profile.d/nix.sh\n\
    fi\n\
    /home/jack/.nix-profile/bin/nix run home-manager/master -- switch --flake /home/jack/.config/home-manager#jack'\''\n\
  \n\
  su jack -c "git config --global user.name '\''Jack'\'' && git config --global user.email '\''jack@localhost'\''"\n\
  touch /home/jack/.local/state/.hm-initialized\n\
  echo "Home-manager initialized successfully!"\n\
fi\n\
\n\
# Start SSH server in foreground (keeps container alive)\n\
echo "Starting SSH server on port 22..."\n\
exec /usr/sbin/sshd -D -e' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set working directory
WORKDIR /home/${USER}

# Expose SSH port
EXPOSE 22

# Entry point: initialization script
ENTRYPOINT ["/entrypoint.sh"]
