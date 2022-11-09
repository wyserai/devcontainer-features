#!/bin/bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ ! -z ${_BUILD_ARG_AZEXTENSION} ]; then
    # Build args are exposed to this entire feature set following the pattern:  _BUILD_ARG_<FEATURE ID>_<OPTION NAME>
    NAMES="${_BUILD_ARG_AZEXTENSION_NAMES}"
    
    echo "Installing Azure CLI extensions: ${NAMES}"
    names=(`echo ${NAMES} | tr ',' ' '`)
    for i in "${names[@]}"
    do
        echo "Installing ${i}"
        az extension add --name ${i} -y
    done
fi
