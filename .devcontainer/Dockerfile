# this image is built and updated weekly
# https://github.com/cse-labs/codespaces-images
FROM ghcr.io/cse-labs/dind:latest

# some images require specific values
ARG USERNAME=vscode

# install gh; update welcome message; chown home dir
RUN echo "$(date +'%Y-%m-%d %H:%M:%S')    docker build start" >> "/home/${USERNAME}/status" && \
    chown -R ${USERNAME}:${USERNAME} "/home/${USERNAME}" && \
    echo "$(date +'%Y-%m-%d %H:%M:%S')    docker build complete" >> "/home/${USERNAME}/status"
