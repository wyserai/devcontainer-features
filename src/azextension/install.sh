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

USERNAME=${USERNAME:-"automatic"}

# Setup STDERR.
err() {
    echo "(!) $*" >&2
}

# Ensure the appropriate root user is running the script.
if [ "$(id -u)" -ne 0 ]; then
    err 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Determine the appropriate non-root user.
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
            USERNAME="${CURRENT_USER}"
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

NAMES="${_BUILD_ARG_AZEXTENSION_NAMES}" 

echo "Installing Azure CLI extensions: ${NAMES}"
names=(`echo ${NAMES} | tr ',' ' '`)
for i in "${names[@]}"
do
    echo "Installing ${i}"
    su ${USERNAME} -c "az extension add --name ${i} -y"
    if [ "$?" != 0 ]; then
      err 'Failed to install az extension'
      exit 1
    fi
done
