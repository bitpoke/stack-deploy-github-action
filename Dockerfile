FROM buildpack-deps:stretch

LABEL "repository"="https://github.com/presslabs/stack-deploy-github-action"
LABEL "maintainer"="Presslabs <support@presslabs.com>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# install kubectl
ENV KUBECTL_VERSION="1.60.0"
RUN curl -sL -o /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/v{$KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod 0755 /usr/local/bin/kubectl \
    && chown root:root /usr/local/bin/kubectl

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
