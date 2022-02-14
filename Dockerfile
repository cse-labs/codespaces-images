###### Build jumpbox image
FROM alpine as jumpbox

WORKDIR /root

CMD [ "/bin/sh", "-c", "trap : TERM INT; sleep 9999999999d & wait" ]

RUN apk update && apk add bash curl nano jq httpie && \
    echo "alias ls='ls --color=auto'" >> /root/.profile && \
    echo "alias ll='ls -alF'" >> /root/.profile && \
    echo "alias la='ls -alF'" >> /root/.profile

###### Build Docker-in-Docker image
FROM mcr.microsoft.com/vscode/devcontainers/dotnet as dind

# user args
# some base images require specific values
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# configure apt-get
ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/usr/local/go/bin:/home/${USERNAME}/go/bin:/home/${USERNAME}/.local/bin:/home/${USERNAME}/.dotnet/tools

###
# We intentionally create multiple layers so that they pull in parallel which improves startup time
###

RUN mkdir -p /home/${USERNAME}/.local/bin && \
    mkdir -p /home/${USERNAME}/.dotnet/tools && \
    mkdir -p /home/${USERNAME}/.dapr/bin && \
    mkdir -p /home/${USERNAME}/.ssh && \
    mkdir -p /home/${USERNAME}/.oh-my-zsh/completions && \
    mkdir -p /home/${USERNAME}/go/bin

# copy the stup scripts to the image
COPY library-scripts/*.sh /scripts/
COPY local-scripts/*.sh /scripts/

RUN apt-get update
RUN apt-get -y install --no-install-recommends apt-utils dialog
RUN apt-get -y install --no-install-recommends apt-transport-https ca-certificates
RUN apt-get -y install --no-install-recommends curl git wget
RUN apt-get -y install --no-install-recommends software-properties-common make build-essential
RUN apt-get -y install --no-install-recommends jq bash-completion
RUN apt-get -y install --no-install-recommends gettext iputils-ping dnsutils

# use scripts from: https://github.com/microsoft/vscode-dev-containers/tree/main/script-library
# uncomment this if you use a base image other than a Codespaces image
# RUN /bin/bash /scripts/common-debian.sh
RUN /bin/bash /scripts/docker-in-docker-debian.sh
RUN /bin/bash /scripts/kubectl-helm-debian.sh
RUN /bin/bash /scripts/azcli-debian.sh
RUN /bin/bash /scripts/go-debian.sh
RUN /bin/bash /scripts/dapr-debian.sh

# install Radius
RUN wget -q "https://get.radapp.dev/tools/rad/install.sh" -O - | /bin/bash

# run local scripts
RUN /bin/bash /scripts/dind-debian.sh

# install GoDaddy CA certs
RUN wget -o /usr/local/share/ca-certificates/gd_bundle-g2-g1.crt https://certs.godaddy.com/repository/gd_bundle-g2-g1.crt && \
    wget -o /usr/local/share/ca-certificates/gd_bundle-g3-g1.crt https://certs.godaddy.com/repository/gd_bundle-g3-g1.crt && \
    wget -o /usr/local/share/ca-certificates/gd_bundle-g4-g1.crt https://certs.godaddy.com/repository/gd_bundle-g4-g1.crt && \
    update-ca-certificates

# install dotnet 5 for tool support
# dotnet 6 is already installed
RUN apt-get -y install --no-install-recommends dotnet-sdk-5.0

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    apt-get clean -y

# change ownership of the home directory
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

WORKDIR /home/${USERNAME}
USER ${USERNAME}

# install https://aka.ms/webv
RUN dotnet tool install -g webvalidate && \
    git config --global core.whitespace blank-at-eol,blank-at-eof,space-before-tab && \
    git config --global pull.rebase false && \
    git config --global init.defaultbranch main && \
    git config --global fetch.prune true && \
    git config --global core.pager more && \
    git config --global diff.colorMoved zebra

USER root

# customize first run message
RUN echo "👋 Welcome to Codespaces! You are on a custom image defined in your devcontainer.json file.\n" > /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "🔍 To explore VS Code to its fullest, search using the Command Palette (Cmd/Ctrl + Shift + P)\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "👋 Welcome to the Docker-in-Docker image\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt

# docker pipe
VOLUME [ "/var/lib/docker" ]

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine 
# inside the container "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

#######################
### Build k3d image from Docker-in-Docker
FROM dind as k3d

ARG USERNAME=vscode

ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/usr/local/go/bin:/usr/local/istio/bin:/home/${USERNAME}/go/bin:/home/${USERNAME}/.local/bin:/home/${USERNAME}/.dotnet/tools:/home/${USERNAME}/.dapr/bin

# install kind / k3d
RUN /bin/bash /scripts/kind-k3d-debian.sh

# change ownership of the home directory
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# customize first run message
RUN echo "👋 Welcome to Codespaces! You are on a custom image defined in your devcontainer.json file.\n" > /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "🔍 To explore VS Code to its fullest, search using the Command Palette (Cmd/Ctrl + Shift + P)\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "👋 Welcome to the k3d Codespaces image\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt

# update the container
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get autoremove -y && \
    apt-get clean -y

#######################
### Build k3d-rust image from k3d
FROM k3d as k3d-rust

ARG USERNAME=vscode

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y --no-install-recommends pkg-config libssl-dev
RUN apt-get install -y --no-install-recommends gcc libc6-dev
RUN apt-get install -y --no-install-recommends lldb python3-minimal libpython3.?
RUN apt-get install -y --no-install-recommends python
RUN apt-get install -y --no-install-recommends clang
RUN apt-get install -y --no-install-recommends cmake
RUN apt-get install -y --no-install-recommends musl-tools

# install rust
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=stable \
    USER=${USERNAME}

RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='fb3a7425e3f10d51f0480ac3cdb3e725977955b2ba21c9bdac35309563b115e8' ;; \
        armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='f263e170da938888601a8e0bc822f8b40664ab067b390cf6c4fdb1d7c2d844e7' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='de1dddd8213644cba48803118c7c16387838b4d53b901059e01729387679dd2a' ;; \
        i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='66c03055119cecdfc20828c95429212ae5051372513f148342758bb5d0130997' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.24.1/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME;

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get autoremove -y && \
    apt-get clean -y

# change ownership of the home directory
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

WORKDIR /home/${USERNAME}
USER ${USERNAME}

# update rust
RUN rustup self update
RUN rustup update

# install additional components
RUN cargo install cargo-debug
RUN rustup component add rust-analysis rust-src rls rustfmt clippy
RUN rustup target add x86_64-unknown-linux-musl

USER root

# customize first run message
RUN echo "👋 Welcome to Codespaces! You are on a custom image defined in your devcontainer.json file.\n" > /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "🔍 To explore VS Code to its fullest, search using the Command Palette (Cmd/Ctrl + Shift + P)\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "👋 Welcome to the k3d and Rust Codespaces image\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt

#######################
### Build k3d-wasm image from k3d-rust
FROM k3d-rust as k3d-wasm

ARG USERNAME=vscode

RUN apt-get update
RUN apt-get upgrade -y

# change ownership of the home directory
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

WORKDIR /home/${USERNAME}
USER ${USERNAME}

# update rust
RUN rustup self update
RUN rustup update

# install WebAssembly target
RUN rustup target add wasm32-unknown-unknown

# install wasm-pack
RUN curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh && \
    cargo install wasm-bindgen-cli 

USER root

# install node
RUN RUN /bin/bash /scripts/node-debian.sh

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get autoremove -y && \
    apt-get clean -y

# change ownership of the home directory
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# customize first run message
RUN echo "👋 Welcome to Codespaces! You are on a custom image defined in your devcontainer.json file.\n" > /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "🔍 To explore VS Code to its fullest, search using the Command Palette (Cmd/Ctrl + Shift + P)\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt \
    && echo "👋 Welcome to the k3d Rust WebAssembly Codespaces image\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt
