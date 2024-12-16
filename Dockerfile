FROM --platform=amd64 ghcr.io/actions/actions-runner:2.321.0

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  git-lfs \
  gzip \
  jq \
  tar \
  unzip \
  zip \
  zstd \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*
 RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install 

COPY wait_for_docker_then_run.sh /usr/local/bin/wait_for_docker_then_run.sh

USER runner
