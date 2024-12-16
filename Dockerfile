FROM summerwind/actions-runner:ubuntu-22.04

USER root

RUN add-apt-repository ppa:rmescandon/yq && \
    apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      git-lfs \
      gh \
      gzip \
      jq \
      tar \
      unzip \
      yq \
      wget \
      zip \
      zstd \
     && apt-get clean \
     && rm -r /var/lib/apt/lists/*
     RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install

COPY wait_for_docker_then_run.sh /usr/local/bin/wait_for_docker_then_run.sh

USER runner
