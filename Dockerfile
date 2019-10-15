FROM buildpack-deps:stretch

LABEL "repository"="https://github.com/presslabs/stack-deploy-github-action"
LABEL "maintainer"="Presslabs <support@presslabs.com>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install kubectl
ENV KUBECTL_VERSION="1.16.0"
RUN curl -sL -o /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/v{$KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod 0755 /usr/local/bin/kubectl \
    && chown root:root /usr/local/bin/kubectl

# https://cloud.google.com/sdk/docs/downloads-versioned-archives
ENV GCLOUD_SDK_VERSION="254.0.0"
ENV CLOUDSDK_PYTHON="/usr/bin/python2.7"
ENV GOOGLE_APPLICATION_CREDENTIALS="/run/google-credentials.json"
RUN curl -sL -o google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && tar -zxf google-cloud-sdk.tar.gz \
    && mv google-cloud-sdk /opt/ \
    && rm google-cloud-sdk.tar.gz \
    && /opt/google-cloud-sdk/bin/gcloud --quiet components install beta

ENV PATH="/opt/google-cloud-sdk/bin:${PATH}"

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
