#!/bin/bash
: ${GOOGLE_CREDENTIALS:="$(cat "$PLUGIN_GOOGLE_CREDENTIALS_FILE" 2>/dev/null)"}

set -e
set -o pipefail

function sanitize() {
  if [ -z "${1}" ]; then
    >&2 echo "Unable to find the ${2}. Did you set with.${2}?"
    exit 1
  fi
}

run() {
    echo "+" "$@"
    "$@"
}

function main() {
    echo "" # see https://github.com/actions/toolkit/issues/168

    sanitize "${INPUT_NAMESPACE}" "namespace"
    sanitize "${INPUT_WORDPRESS}" "wordpress"
    sanitize "${INPUT_IMAGE}" "image"

    if [ ! -z "$GOOGLE_CREDENTIALS" ] ; then
        echo "$GOOGLE_CREDENTIALS" > /run/google-credentials.json
        run gcloud auth activate-service-account --key-file=/run/google-credentials.json
    fi

    kubectl -n "${INPUT_NAMESPACE}" patch wordpress "${INPUT_WORDPRESS}" --type=json -p '[{"op": "replace", "path": "/spec/image", "value": "${INPUT_IMAGE}"}]'
}

main
