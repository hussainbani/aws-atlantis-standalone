#!/bin/sh

set -eu pipefail

logtag='cloud-config'
logger -t $logtag 'Running cloud-config script'
logger -t $logtag 'Output logged to /var/log/cloud-init-output.log'

# Template variables use $${var} syntax
ATLANTIS_VERSION=${atlantis_version}
DEFAULT_CONFTEST_VERSION=${conftest_version}
GIT_LFS_VERSION=${git_lfs_version}
DEFAULT_TERRAFORM_VERSION=${terraform_version}
GO_VERSION=${go_version}
AWS_CREDENTIALS_BASE64=${aws_credentials_base64}
ATLANTIS_REPO_ALLOWLIST=${repo_allowlist}
ATLANTIS_DOMAIN=${atlantis_domain}
ATLANTIS_GH_WEBHOOK_SECRET=${atlantis_gh_webhook_secret}
ATLANTIS_GH_APP_ID=${atlantis_gh_app_id}
# Optional web authentication
%{ if atlantis_username != null && atlantis_password != null ~}
ATLANTIS_WEB_USERNAME=${atlantis_username}
ATLANTIS_WEB_PASSWORD=${atlantis_password}
%{ endif ~}

sudo apt-get update && sudo apt-get install -y --no-install-recommends \
  gnupg software-properties-common \
  python3 \
  python3-pip \
  net-tools \
  curl \
  git \
  unzip \
  ca-certificates \
  openssh-server \
  dumb-init \
  gnupg \
  openssl \
  bash \
  sudo \
  build-essential \
  wget


# --- Install Go ---
GO_TARBALL="go$${GO_VERSION}.linux-amd64.tar.gz"
sudo wget "https://go.dev/dl/$${GO_TARBALL}" -O "$${GO_TARBALL}"
sudo tar -C /usr/local -xzf "$${GO_TARBALL}"
sudo chmod +x /usr/local/go/bin/*
export PATH=$PATH:/usr/local/go/bin

# --- Create user ---
sudo useradd --create-home --user-group --shell /bin/bash atlantis

# --- Download Atlantis binary for correct arch ---
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ATLANTIS_ARCH=amd64 ;;
  aarch64) ATLANTIS_ARCH=arm64 ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac
sudo wget "https://github.com/runatlantis/atlantis/releases/download/v$${ATLANTIS_VERSION}/atlantis_linux_$${ATLANTIS_ARCH}.zip" -O /tmp/atlantis.zip
sudo unzip /tmp/atlantis.zip -d /usr/local/bin
sudo chown root:root /usr/local/bin/atlantis
sudo chmod +x /usr/local/bin/atlantis

# --- Install Conftest ---
sudo wget -q "https://github.com/open-policy-agent/conftest/releases/download/v$${DEFAULT_CONFTEST_VERSION}/conftest_$${DEFAULT_CONFTEST_VERSION}_Linux_$${ATLANTIS_ARCH}.deb"
sudo dpkg -i conftest_$${DEFAULT_CONFTEST_VERSION}_Linux_$${ATLANTIS_ARCH}.deb

# --- Install git-lfs ---
sudo wget -q "https://github.com/git-lfs/git-lfs/releases/download/v$${GIT_LFS_VERSION}/git-lfs-linux-$${ATLANTIS_ARCH}-v$${GIT_LFS_VERSION}.tar.gz" -O git-lfs.tar.gz
sudo tar -xzf git-lfs.tar.gz --strip-components=1
sudo mv git-lfs /usr/bin/
sudo chmod +x /usr/bin/git-lfs

# --- Install Terraform and OpenTofu ---
download_terraform () {
  NAME=$1
  VERSION=$2
  ARCH=$3
  URL="https://releases.hashicorp.com/$${NAME}/$${VERSION}/$${NAME}_$${VERSION}_linux_$${ARCH}.zip"
  curl -s -L -o $NAME.zip "$URL"
  unzip -o $NAME.zip
  sudo mv $NAME /usr/local/$NAME-$VERSION
  sudo ln -sf /usr/local/$NAME-$VERSION /usr/local/bin/$NAME
}

download_terraform terraform "$${DEFAULT_TERRAFORM_VERSION}" "$${ATLANTIS_ARCH}"

sudo mkdir /var/github-app -p

# Decode and save the private key
echo ${github_app_private_key} | base64 -d > /var/github-app/key.pem
sudo chown atlantis:atlantis /var/github-app/key.pem
sudo chmod 600 /var/github-app/key.pem

# Setup AWS credentials
sudo mkdir -p /home/atlantis/.aws
echo "$${AWS_CREDENTIALS_BASE64}" | base64 -d | sudo tee /home/atlantis/.aws/credentials > /dev/null

sudo chown -R atlantis:atlantis /home/atlantis/.aws
sudo chmod 600 /home/atlantis/.aws/credentials

# Create Atlantis repos configuration
sudo mkdir -p /etc/atlantis
sudo tee /etc/atlantis/repos.yaml > /dev/null <<EOF
repos:
  - id: /.*/
    allowed_overrides: [workflow, apply_requirements]
    allow_custom_workflows: true
EOF

sudo chown -R atlantis:atlantis /etc/atlantis
sudo chmod 644 /etc/atlantis/repos.yaml

# --- Optional: Systemd service ---
cat <<EOF > /etc/systemd/system/atlantis.service
[Unit]
Description=Atlantis Terraform GitOps Server
After=network.target

[Service]
User=atlantis
Environment="ATLANTIS_GH_APP_KEY_FILE=/var/github-app/key.pem"
Environment="ATLANTIS_GH_WEBHOOK_SECRET=$${ATLANTIS_GH_WEBHOOK_SECRET}"
Environment="ATLANTIS_GH_APP_ID=$${ATLANTIS_GH_APP_ID}"
Environment="AWS_SHARED_CREDENTIALS_FILE=/home/atlantis/.aws/credentials"
Environment="ATLANTIS_REPO_CONFIG=/etc/atlantis/repos.yaml"
Environment="ATLANTIS_REPO_ALLOWLIST=$${ATLANTIS_REPO_ALLOWLIST}"
Environment="CONFTEST_VERSION=$${DEFAULT_CONFTEST_VERSION}"
Environment="ATLANTIS_TFE_LOCAL_EXECUTION_MODE=true"
 %{ if atlantis_username != null && atlantis_password != null ~}
Environment="ATLANTIS_WEB_BASIC_AUTH=true"
Environment="ATLANTIS_WEB_USERNAME=$${ATLANTIS_WEB_USERNAME}"
Environment="ATLANTIS_WEB_PASSWORD=$${ATLANTIS_WEB_PASSWORD}"
%{ endif ~}
ExecStart=/usr/local/bin/atlantis server --atlantis-url https://$${ATLANTIS_DOMAIN} --write-git-creds
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable atlantis
sudo systemctl start atlantis