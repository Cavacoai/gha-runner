# gha-runner

## Cavaco image

The Cavaco image extends the pinned `summerwind/actions-runner:ubuntu-22.04` base
with runner 2.337.0 and the tools in this repository. It supports Linux ARM64 and AMD64.

`build-and-publish` builds pull requests without publishing. A version tag matching
`*.*.*`, or a manual run from `main`, publishes both architectures to the `arc-runner`
repository in Amazon ECR. For the prepared runner update, use image tag `20261014-0`.

Publication requires the release app secrets `CAVACO_RELEASER_APP_ID` and
`CAVACO_RELEASER_APP_TOKEN`, plus the variables `AWS_DEFAULT_ACCOUNT`,
`AWS_DEFAULT_REGION`, and `AWS_OIDC_ROLE_NAME`. The app token authenticates GitHub
checkout; AWS credentials are temporary credentials obtained through GitHub OIDC.

Publishing does not update Kubernetes. Verify the published image and both
architectures before merging the corresponding image-reference PR in `argocd-ops`.

## Upstream reference

Automated updated builds starting with `ghcr.io/actions/actions-runner` image. Adds with utilities installed so actions actually work.

Adds the following packages to the base image.

```
curl
ca-certificates
zstd
gzip
tar
jq
git
zip
unzip
```

### How to use

Replace `ghcr.io/actions/actions-runner` with `mobilecoin/gha-runner` in your `gha-runner-scale-set` helm releases.

Example `values.yaml`.  See the [gha-runner-scale-set docs](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/deploying-runner-scale-sets-with-actions-runner-controller#using-advanced-configuration-options) for full details on customizing your install.

```yaml
runnerScaleSetName: dev-small-x64
githubConfigUrl: https://github.com/<GitHub Org>
githubConfigSecret: <GitHub App Secret>
maxRunners: 25
minRunners: 0
runnerGroup: default

template:
  spec:
    imagePullSecrets:
    - name: docker-credentials
    initContainers:
    - name: init-dind-externals
      image: mobilecoin/gha-runner:latest
      command: ["cp", "-r", "-v", "/home/runner/externals/.", "/home/runner/tmpDir/"]
      volumeMounts:
      - name: dind-externals
        mountPath: /home/runner/tmpDir
    containers:
    - name: runner
      image: mobilecoin/gha-runner:latest
      command: ["/home/runner/run.sh"]
      env:
      - name: DOCKER_HOST
        value: unix:///run/docker/docker.sock
      volumeMounts:
      - name: work
        mountPath: /home/runner/_work
      - name: dind-sock
        mountPath: /run/docker
        readOnly: true
    - name: dind
      image: docker:dind
      args:
      - dockerd
      - --host=unix:///run/docker/docker.sock
      - --group=$(DOCKER_GROUP_GID)
      env:
      - name: DOCKER_GROUP_GID
        value: "123"
      securityContext:
        privileged: true
      volumeMounts:
      - name: work
        mountPath: /home/runner/_work
      - name: dind-sock
        mountPath: /run/docker
      - name: dind-externals
        mountPath: /home/runner/externals
    volumes:
    - name: work
      emptyDir: {}
    - name: dind-sock
      emptyDir: {}
    - name: dind-externals
      emptyDir: {}
```
