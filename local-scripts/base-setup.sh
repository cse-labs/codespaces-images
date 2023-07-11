#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    echo "(!) $0 failed!"
    exit 1
fi

mkdir -p /home/${USERNAME}/bin
mkdir -p /home/${USERNAME}/.local/bin
mkdir -p /home/${USERNAME}/.dotnet/tools
mkdir -p /home/${USERNAME}/.dapr/bin
mkdir -p /home/${USERNAME}/.ssh
mkdir -p /home/${USERNAME}/.oh-my-zsh/completions
mkdir -p /home/${USERNAME}/go/bin
chsh --shell /bin/zsh vscode

# customize first run message
echo "👋 Welcome to the Docker-in-Docker Codespaces image\n" >> /usr/local/etc/vscode-dev-containers/first-run-notice.txt

apt-get update
apt-get -y install --no-install-recommends apt-utils dialog apt-transport-https ca-certificates curl git wget openssl
apt-get -y install --no-install-recommends software-properties-common make build-essential jq bash-completion gettext iputils-ping dnsutils

# install github cli
apt-key adv --keyserver keyserver.ubuntu.com --recv-key 23F3D4EA75716059
apt-add-repository https://cli.github.com/packages

# install fluent bit for debugging
curl https://packages.fluentbit.io/fluentbit.key | gpg --dearmor > /usr/share/keyrings/fluentbit-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/fluentbit-keyring.gpg] https://packages.fluentbit.io/debian/buster buster main" >> /etc/apt/sources.list
apt-get update

apt-get -y install --no-install-recommends gh fluent-bit

# install dotnet 3.1, 5, and 6 for tool support
# dotnet 7 is already installed
apt-get -y install --no-install-recommends dotnet-sdk-5.0 dotnet-sdk-6.0 dotnet-sdk-3.1

# this fails the first time
curl https://certs.godaddy.com/repository/gd_bundle-g2.crt

# install GoDaddy CA certs
mkdir -p /usr/local/share/ca-certificates
curl -Lo /usr/local/share/ca-certificates/gd_bundle-g2.crt https://certs.godaddy.com/repository/gd_bundle-g2.crt
update-ca-certificates

