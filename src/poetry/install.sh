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

# pipx version for poetry
POETRY_VERSION=${_BUILD_ARG_POETRY_VERSION:-"latest"}

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

# settings these will allow us to clean leftovers later on
export PYTHONUSERBASE=/tmp/pip-tmp
export PIP_CACHE_DIR=/tmp/pip-tmp/cache
# install python if does not exists
if ! type pip3 > /dev/null 2>&1; then
    echo "Installing python3..."
    # we set INSTALLTOOLS=false in order to save disk space, but as
    # a result we will need to install pipx manually later on
    check_packages curl
    export VERSION="system" 
    export INSTALLTOOLS="false"
    curl -fsSL https://raw.githubusercontent.com/devcontainers/features/main/src/python/install.sh | $SHELL
fi
# install pipx if not exists
export PIPX_HOME=${PIPX_HOME:-"/usr/local/py-utils"}
export PIPX_BIN_DIR="${PIPX_HOME}/bin"

if ! type pipx > /dev/null 2>&1; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi

    PATH="${PATH}:${PIPX_BIN_DIR}"

    # Create pipx group, dir, and set sticky bit
    if ! cat /etc/group | grep -e "^pipx:" > /dev/null 2>&1; then
        groupadd -r pipx
    fi
    usermod -a -G pipx ${USERNAME}
    umask 0002
    mkdir -p ${PIPX_BIN_DIR}
    chown -R "${USERNAME}:pipx" ${PIPX_HOME}
    chmod -R g+r+w "${PIPX_HOME}" 
    find "${PIPX_HOME}" -type d -print0 | xargs -0 -n 1 chmod g+s

    pip3 install --disable-pip-version-check --no-cache-dir --user pipx 2>&1
    /tmp/pip-tmp/bin/pipx install --pip-args=--no-cache-dir pipx
    PIPX_COMMAND=/tmp/pip-tmp/bin/pipx

    updaterc "export PIPX_HOME=\"${PIPX_HOME}\""
    updaterc "export PIPX_BIN_DIR=\"${PIPX_BIN_DIR}\""
    updaterc "if [[ \"\${PATH}\" != *\"\${PIPX_BIN_DIR}\"* ]]; then export PATH=\"\${PATH}:\${PIPX_BIN_DIR}\"; fi"

else
    PIPX_COMMAND=pipx
fi

if [ "$POETRY" != "none" ]; then
    if [ "$POETRY" =  "latest" ]; then
        util_command="poetry"
    else
        util_command="poetry==$POETRY"
    fi
    "${PIPX_COMMAND}" install --system-site-packages --force --pip-args '--no-cache-dir --force-reinstall' ${util_command}

    # Ensure virtual environments are created in project
    su ${USERNAME} -c "poetry config virtualenvs.in-project true"
fi

# cleaning after pip
rm -rf /tmp/pip-tmp




# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"