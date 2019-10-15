#!/bin/bash
: ${GOOGLE_CREDENTIALS:="$(cat "$PLUGIN_GOOGLE_CREDENTIALS_FILE" 2>/dev/null)"}

set -e
set -o pipefail

sanitize() {
  if [ -z "${1}" ]; then
    >&2 echo "Unable to find the ${2}. Did you set with.${2}?"
    exit 1
  fi
}

require_google_credentials() {
    if [ -z "$GOOGLE_CREDENTIALS" ] ; then
        echo "You must define \"google_credentials_file\" parameter or define GOOGLE_CREDENTIALS environment variable" >&2
        exit 2
    fi
}

run() {
    echo "+" "$@"
    "$@"
}

main() {
    echo "" # see https://github.com/actions/toolkit/issues/168

    sanitize "${INPUT_GOOGLE_PROJECT}" "google_project"
    sanitize "${INPUT_GOOGLE_CLUSTER}" "google_cluster"
    sanitize "${INPUT_GOOGLE_ZONE}" "google_zone"

    sanitize "${INPUT_NAMESPACE}" "namespace"
    sanitize "${INPUT_WORDPRESS}" "wordpress"
    sanitize "${INPUT_IMAGE}" "image"

    if [ ! -z "$GOOGLE_CREDENTIALS" ] ; then
        echo "$GOOGLE_CREDENTIALS" > /run/google-credentials.json
        run gcloud auth activate-service-account --key-file=/run/google-credentials.json
    fi

    if [ ! -z "${INPUT_GOOGLE_PROJECT}" ] ; then
        run gcloud config set project "${INPUT_GOOGLE_PROJECT}"
    fi

    if [ ! -z "${INPUT_GOOGLE_CLUSTER}" ] ; then
        require_google_credentials

        run gcloud container clusters get-credentials "${INPUT_GOOGLE_CLUSTER}" --project "${INPUT_GOOGLE_PROJECT}" --zone "${INPUT_GOOGLE_ZONE}"
        # Display kubernetees versions (usefull for debugging)
        run kubectl version
    fi

    kubectl -n "${INPUT_NAMESPACE}" patch wordpress "${INPUT_WORDPRESS}" --type=json -p "[{\"op\": \"replace\", \"path\": \"/spec/image\", \"value\": \"${INPUT_IMAGE}\"}]"
}

main
