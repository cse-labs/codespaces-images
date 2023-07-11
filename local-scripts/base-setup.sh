#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

RUN apt-get update
RUN apt-get -y install --no-install-recommends apt-utils dialog apt-transport-https ca-certificates curl git wget openssl
RUN apt-get -y install --no-install-recommends software-properties-common make build-essential jq bash-completion gettext iputils-ping dnsutils

# this fails the first time
curl https://certs.godaddy.com/repository/gd_bundle-g2.crt

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    echo "(!) $0 failed!"
    exit 1
fi

# install GoDaddy CA certs
mkdir -p /usr/local/share/ca-certificates
curl -Lo /usr/local/share/ca-certificates/gd_bundle-g2.crt https://certs.godaddy.com/repository/gd_bundle-g2.crt
update-ca-certificates

# install github cli
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 23F3D4EA75716059 && \
    apt-add-repository https://cli.github.com/packages && \
    apt-get update && \
    apt-get -y install --no-install-recommends gh

# install fluent bit for debugging
curl https://packages.fluentbit.io/fluentbit.key | gpg --dearmor > /usr/share/keyrings/fluentbit-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/fluentbit-keyring.gpg] https://packages.fluentbit.io/debian/buster buster main" >> /etc/apt/sources.list
apt-get update
apt-get -y install --no-install-recommends fluent-bit

# install dotnet 3.1, 5, and 6 for tool support
# dotnet 7 is already installed
apt-get -y install --no-install-recommends dotnet-sdk-5.0 dotnet-sdk-6.0 dotnet-sdk-3.1

