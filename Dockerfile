FROM summerwind/actions-runner:ubuntu-22.04

ARG TARGETARCH

USER root

RUN add-apt-repository ppa:rmescandon/yq && \
    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource-repo.gpg && \
    echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/nodesource-repo.gpg] https://deb.nodesource.com/node_23.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list > /dev/null

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
      nodejs \
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

RUN wget -qO /usr/local/bin/earthly https://github.com/earthly/earthly/releases/download/v0.8.16/earthly-linux-$TARGETARCH && \
    chmod +x /usr/local/bin/earthly

COPY wait_for_docker_then_run.sh /usr/local/bin/wait_for_docker_then_run.sh

USER runner
