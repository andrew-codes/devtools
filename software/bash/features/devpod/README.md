## Devpod

Client application that creates codespaces on a variety of providers. Using for dev containers spun up on self-hosted Kubernetes cluster.

### Commands

**devbuild**: Build dev container image to be used with devpod as a prebuild image.

> Note, must be authenticated with ghcr.io for this to work. Ensure you set the GITHUB_TOKEN environment variable.

```bash
devbuild repo_name
```

**devup**: Bring up a dev environment on a K8s cluster.

```bash
devup repo_name
```