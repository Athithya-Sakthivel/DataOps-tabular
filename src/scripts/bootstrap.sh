#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

log() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

fatal() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

require_bin() {
  command -v "$1" >/dev/null 2>&1 || fatal "$1 not found in PATH"
}

TMPDIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMPDIR}"
}
trap cleanup EXIT

log "updating apt metadata"
sudo apt-get update -qq

log "installing base packages"
sudo apt-get install -y -qq \
  ca-certificates \
  curl \
  gnupg \
  apt-transport-https \
  unzip \
  gh \
  make \
  tree \
  vim \
  python3-pip \
  python3-venv \
  jq \
  wget

log "installing kubectl into /usr/local/bin"
KUBECTL_VERSION="v1.30.1"
curl -fsSL -o "${TMPDIR}/kubectl" \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x "${TMPDIR}/kubectl"
sudo install -m 0755 "${TMPDIR}/kubectl" /usr/local/bin/kubectl

log "installing kind into /usr/local/bin"
KIND_VERSION="v0.25.0"
curl -fsSL -o "${TMPDIR}/kind" \
  "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"
chmod +x "${TMPDIR}/kind"
sudo install -m 0755 "${TMPDIR}/kind" /usr/local/bin/kind

log "installing AWS CLI v2"
curl -fsSL -o "${TMPDIR}/awscliv2.zip" \
  "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip -q "${TMPDIR}/awscliv2.zip" -d "${TMPDIR}/awscli"
sudo "${TMPDIR}/awscli/aws/install" --update

log "installing flytectl"
curl -fsSL https://ctl.flyte.org/install | sudo bash -s -- -b /usr/local/bin v0.9.8

log "installing helm"
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | DESIRED_VERSION=v3.15.4 bash

log "installing gitleaks into /usr/local/bin"
curl -fsSL -o "${TMPDIR}/gitleaks.tar.gz" \
  https://github.com/gitleaks/gitleaks/releases/download/v8.30.0/gitleaks_8.30.0_linux_x64.tar.gz
tar -xzf "${TMPDIR}/gitleaks.tar.gz" -C "${TMPDIR}"
sudo install -m 0755 "${TMPDIR}/gitleaks" /usr/local/bin/gitleaks

log "installing ruff"
curl -fsSL https://astral.sh/ruff/0.14.11/install.sh | sh

if [[ -d "${HOME}/.local/bin" ]]; then
  export PATH="${HOME}/.local/bin:${PATH}"
fi

if ! grep -qs 'export PATH=$HOME/.local/bin:$PATH' "${HOME}/.bashrc"; then
  echo 'export PATH=$HOME/.local/bin:$PATH' >> "${HOME}/.bashrc"
fi

log "creating Python virtual environments"

# Flyte local environments only need packages imported at module load time

# -------------------------
# ELT environment
# -------------------------

python3 -m venv .venv_elt

.venv_elt/bin/python -m pip install --upgrade \
  pip \
  wheel \
  setuptools

.venv_elt/bin/python -m pip install \
  setuptools==69.5.1 \
  flytekit==1.16.15 \
  flytekitplugins-spark==1.16.15 \
  pyspark==4.1.1 \
  cloudpickle==3.1.2

# -------------------------
# Training environment
# -------------------------

python3 -m venv .venv_train

.venv_train/bin/python -m pip install --upgrade \
  pip \
  wheel \
  setuptools

.venv_train/bin/python -m pip install \
  boto3==1.42.70 \
  setuptools==69.5.1 \
  flytekit==1.16.16 \
  mlflow==3.10.1 \
  numpy==2.4.4 \
  pandas==2.3.3 \
  lightgbm==4.6.0 \
  onnx==1.21.0 \
  onnxruntime==1.24.4 \
  onnxmltools==1.16.0 \
  pyiceberg==0.11.0 \
  scikit-learn==1.8.0 \
  polars==1.39.3


log "installing Python packages"

pip install --no-cache-dir \
  pyiceberg==0.11.0 \
  boto3==1.42.81 \
  onnxruntime==1.24.4 \
  pandas==2.3.3 \
  numpy==2.4.4 \
  rich==14.3.3 \
  s3fs==2026.3.0 \
  fsspec==2026.3.0 \
  pyarrow==23.0.1 \
  requests==2.33.1 \
  urllib3==2.7.0 \
  pyyaml==6.0.3 \
  --break-system-packages

log "installing pre-commit hooks"
pre-commit install --install-hooks

clear
log "verifying installed tools"
gitleaks version
echo "helm version $(helm version)"
aws --version
ruff version
pre-commit --version
kubectl version --client
flytectl version

log "done"