#!/bin/bash
set -e

# The install.sh script is the installation entrypoint for any dev container 'features' in this repository. 
#
# The tooling will parse the devcontainer-features.json + user devcontainer, and write 
# any build-time arguments into a feature-set scoped "devcontainer-features.env"
# The author is free to source that file and use it however they would like.
set -a
. ./devcontainer-features.env
set +a

# Setup STDERR.
err() {
    echo "(!) $*" >&2
}

# Ensure the appropriate root user is running the script.
if [ "$(id -u)" -ne 0 ]; then
    err 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

PULUMI_VERSION=${_BUILD_ARG_PULUMI_VERSION:-"latest"}

export DEBIAN_FRONTEND=noninteractive
check_packages curl build-essential

if ! type git > /dev/null 2>&1; then
  check_packages git
fi

if [ "$PULUMI_VERSION" = "latest" ]; then 
  curl -fsSL https://get.pulumi.com/ | bash; 
else 
  curl -fsSL https://get.pulumi.com/ | bash -s -- --version $PULUMI_VERSION ; 
fi

mkdir -p /usr/local/pulumi
cp -r ${HOME}/.pulumi/* /usr/local/pulumi
