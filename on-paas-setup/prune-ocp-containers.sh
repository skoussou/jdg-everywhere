#!/bin/bash

# https://github.com/openshift/release/issues/468 
# Looks like we still have the bug where we fail to clean up intermediate containers for failed builds, so ran this on the node:

for container in $( docker ps -a --format {{.ID}} ); do
	buildName="$( docker inspect --format '{{index .Config.Labels "io.openshift.build.name"}}' "${container}" )"
	if [[ -n "${buildName}" ]]; then
		exitCode="$( docker inspect --format '{{.State.ExitCode}}' "${container}" )"
		if [[ "${exitCode}" != 0 ]]; then
			docker rm -v "${container}"
		fi
	fi
done
