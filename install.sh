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

MICROSOFT_GPG_KEYS_URI="https://packages.microsoft.com/keys/microsoft.asc"

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

# Get central common setting
get_common_setting() {
    if [ "${common_settings_file_loaded}" != "true" ]; then
        curl -sfL "https://aka.ms/vscode-dev-containers/script-library/settings.env" 2>/dev/null -o /tmp/vsdc-settings.env || echo "Could not download settings file. Skipping."
        common_settings_file_loaded=true
    fi
    if [ -f "/tmp/vsdc-settings.env" ]; then
        local multi_line=""
        if [ "$2" = "true" ]; then multi_line="-z"; fi
        local result="$(grep ${multi_line} -oP "$1=\"?\K[^\"]+" /tmp/vsdc-settings.env | tr -d '\0')"
        if [ ! -z "${result}" ]; then declare -g $1="${result}"; fi
    fi
    echo "$1=${!1}"
}

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

if [ ! -z ${_BUILD_ARG_AZEXTENSION} ]; then
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
fi

if [ ! -z ${_BUILD_ARG_PULUMI} ]; then
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
fi

if [ ! -z ${_BUILD_ARG_AZUREFUNCTOOLS} ]; then
  # Install dependencies
  check_packages apt-transport-https curl ca-certificates gnupg2 dirmngr
  # Import key safely (new 'signed-by' method rather than deprecated apt-key approach) and install
  get_common_setting MICROSOFT_GPG_KEYS_URI
  curl -sSL ${MICROSOFT_GPG_KEYS_URI} | gpg --dearmor > /usr/share/keyrings/microsoft-archive-keyring.gpg
  echo "deb [arch=${architecture} signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli/ ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/azure-cli.list
  apt-get update

  if ! (apt-get install -yq azure-functions-core-tools-4); then
    rm -f /etc/apt/sources.list.d/azure-cli.list
    return 1
  fi
fi
