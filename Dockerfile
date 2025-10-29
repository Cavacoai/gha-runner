FROM summerwind/actions-runner:ubuntu-22.04

ARG TARGETARCH

USER root

RUN add-apt-repository ppa:rmescandon/yq && \
    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      git-lfs \
      gh \
      gzip \
      helm \
      jq \
      tar \
      unzip \
      yq \
      wget \
      zip \
      zstd \
     && apt-get clean \
     && rm -r /var/lib/apt/lists/*

RUN case "$TARGETARCH" in \
        amd64) AWSCLI_ARCHIVE=awscli-exe-linux-x86_64.zip ;; \
        arm64) AWSCLI_ARCHIVE=awscli-exe-linux-aarch64.zip ;; \
        *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2 && exit 1 ;; \
    esac && \
    curl -fsSL "https://awscli.amazonaws.com/${AWSCLI_ARCHIVE}" -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

COPY wait_for_docker_then_run.sh /usr/local/bin/wait_for_docker_then_run.sh

USER runner
