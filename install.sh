#!/bin/bash
set -e

AZ_NAMES=${NAMES:-""}
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

echo "Installing Azure CLI extensions: ${AZ_NAMES}"
names=(`echo ${AZ_NAMES} | tr ',' ' '`)
for i in "${names[@]}"
do
    echo "Installing ${i}"
    su ${USERNAME} -c "az extension add --name ${i} -y"
    if [ "$?" != 0 ]; then
      err 'Failed to install az extension'
      exit 1
    fi
done
