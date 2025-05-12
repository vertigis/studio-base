# Studio Base - Installation
_Updated on: Mon May 12 14:11:36 PDT 2025_
- [Links](#links)
- [Reference Guides](#reference-guides)
- [System Requirements](#system-requirements)
- [Preparation](#preparation)
  - [Account ID and Registry
    Credentials](#account-id-and-registry-credentials)
  - [Linux Machine](#linux-machine)
  - [Front-End URL](#front-end-url)
  - [ArcGIS Portal and Application
    Registration](#arcgis-portal-and-application-registration)
  - [Get the Package](#get-the-package)
- [Deployment Overview](#deployment-overview)
- [On Linux: Initial Setup](#on-linux-initial-setup)
- [On Linux: Upgrade to Latest](#on-linux-upgrade-to-latest)
- [On Windows: Remotely Administer your Linux
  Machine](#on-windows-remotely-administer-your-linux-machine)
  - [Install Tools (Administrator
    Session)](#install-tools-administrator-session)
  - [Install Tools CLI Alternative (Administrator
    Session)](#install-tools-cli-alternative-administrator-session)
  - [Initial Deployment](#initial-deployment)
  - [Update the Deployment](#update-the-deployment)
  - [Continue Setup on Linux](#continue-setup-on-linux)
- [Port Management](#port-management)
  - [Bring you own Reverse Proxy](#bring-you-own-reverse-proxy)
  - [Leverage the HTTPS Feature](#leverage-the-https-feature)
- [Give the Container a Real Web
  Certificate](#give-the-container-a-real-web-certificate)
  - [Use ACME via `certbot` from Let’s Encrypt
    (RECOMMENDED)](#use-acme-via-certbot-from-lets-encrypt-recommended)
  - [Use a given `.pfx` file](#use-a-given-.pfx-file)
- [Using Studio as a Reverse Proxy](#using-studio-as-a-reverse-proxy)

## Links

- [This
  Release](https://github.com/vertigis/studio-base/releases/v1.1.677.241594-r14982707196)
  ( v1.1.677.241594-r14982707196 )
  - [Image](https://github.com/vertigis/studio-base/pkgs/container/studio%2fbase/413952295?tag=v1.1.677.241594-r14982707196)
  - [Installation Guide](https://github.com/)
  - [Deployment Package
    (ZIP)](https://github.com/vertigis/studio-base-internal/archive/refs/tags/v0-pr-13249732233.zip)
  - [Deployment Package
    (TGZ)](https://github.com/vertigis/studio-base-internal/archive/refs/tags/v0-pr-13249732233.tar.gz)
- [Releases](https://github.com/vertigis/studio-base/releases)
- [Images](https://github.com/vertigis/studio-base/pkgs/container/studio%2fbase)
- [Repository](https://github.com/vertigis/studio-base)
- [Site](https://vertigis.github.io/studio-base/)

## Reference Guides

- [Docker Tutorial](https://docs.docker.com/get-started/)
- [Docker Compose
  Tutorial](https://docs.docker.com/compose/gettingstarted/)
- [SSH Tutorial](https://www.ssh.com/academy/ssh)
- [SSH
  Tutorial](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview)
  – Microsoft Learn
- [SSH and VS Code](https://code.visualstudio.com/docs/remote/ssh)

## System Requirements

| Requirement  | Spec                                                |
|--------------|-----------------------------------------------------|
| OS           | Linux                                               |
| Distribution | Ubuntu 24.04, Ubuntu 22.04, or Debian 12 (bookworm) |
| Memory       | 4 GB Minimum, 8 GB Preferred                        |
| Disk         | 16 GB Free                                          |

## Preparation

In order to run VertiGIS Studio in containers, there are a few
prerequisites that should be satisfied. Before you begin, please have
the following at hand:

### Account ID and Registry Credentials

We require an appropriate license to run our software, but also, you
will need registry credentials to pull down the software. Our support
can help you with finding the following information:

- VertiGIS Account ID
- GitHub
  - Account
  - Permissions to ghcr.io/vertigis/studio/base

### Linux Machine

We require Linux to run VertiGIS Studio in containers. You will need to
have a suitable distribution/version of Linux installed on an
appropriately resourced machine. Please review the system requirements.
We suggest using said Linux machine as a pure Docker host. In other
words, do not install software directly on the host system.

### Front-End URL

As with all web software, you will need to know the front-end URL of
where you plan to host the software. Various components need to know
this value.

### ArcGIS Portal and Application Registration

Go to your portal and create a web application:

- Register this application (enable OAUTH2)
- Provide a Redirect URL (use the Front-End URL)
- Note the App ID

### Get the Package

``` sh
# Using bash on Debian/Ubuntu
> mkdir -p deploy-studio
> cd deploy-studio
> curl -fsSL https://github.com/vertigis/studio-base/archive/refs/tags/v1.1.677.241594-r14982707196.tar.gz | tar -xz

# Using cmd on Windows
> mkdir deploy-studio
> cd deploy-studio
> curl -fsSL https://github.com/vertigis/studio-base/archive/refs/tags/v1.1.677.241594-r14982707196.tar.gz -o deploy.tgz
> tar -xzf deploy.tgz
> del deploy.tgz

# Using powershell on Windows
> mkdir deploy-studio
> cd deploy-studio
> iwr -Uri https://github.com/vertigis/studio-base/archive/refs/tags/v1.1.677.241594-r14982707196.zip -OutFile deploy.zip
> Expand-Archive -Path deploy.zip -DestinationPath .
> del deploy.zip

# Using git
> git clone --depth 1 --branch v1.1.677.241594-r14982707196 https://github.com/vertigis/studio-base deploy-studio
> cd deploy-studio
```

## Deployment Overview

The primary part of the installation will happen on the Linux machine
you have provisioned for this task. If your on a Windows Enterprise
network, you may want to capture the Enterprise CA certificates. This
step can only really be done effectively from a domain-joined Windows
machine.

## On Linux: Initial Setup

``` bash
# Install Docker and supporting tools if needed
> sudo ./install-tools.sh
> exec sudo su - $USER

# Edit configuration for VertiGIS Studio
# If using a plain terminal, try one of these:
> nano docker-compose.yaml
> vi docker-compose.yaml
# If using a GUI, try one of these:
> code docker-compose.yaml &
> gedit docker-compose.yaml &
> kate docker-compose.yaml &
> mousepad docker-compose.yaml &

# Gain access to images
> gh auth login -w -s repo,read:packages
> gh auth token | docker login ghcr.io -u x-access-token --password-stdin

# Pull/Start VertiGIS Studio
> docker compose up --wait
```

## On Linux: Upgrade to Latest

``` bash
# If login has expired, gain access to images
> gh auth login -w -s repo,read:packages
> gh auth token | docker login ghcr.io -u x-access-token --password-stdin

# Pull down VertiGIS Studio
> docker compose pull

# Upgrade VertiGIS Studio
> docker compose up --wait

# Refresh configuration 
> docker exec vs-studio-main-1 util-refresh
```

## On Windows: Remotely Administer your Linux Machine

On Windows, we suggest using a full-featured SSH client like VS Code to
perform administrative tasks on a remote Linux machine. VS Code supports
remote file editing as well as remote command execution.

### Install Tools (Administrator Session)

- Goto Windows Optional Features -\> Add an Optional Feature:
  - Install RSAT: Active Directory Domain Services
  - Install OpenSSH Client
- Optionally, download and install the following:
  - [VS Code](https://code.visualstudio.com/download)

### Install Tools CLI Alternative (Administrator Session)

``` powershell
# If not already done, install supporting tools
Get-WindowsCapability -Online -Name RSAT.ActiveDirectory.* | Add-WindowsCapability -Online
Add-WindowsCapability -Online -Name OpenSSH.Client

# If desired,  install vscode
winget install vscode
```

### Initial Deployment

``` powershell
# Extract CA certificates from Active Directory
# Some environments may use an internal CA system.
# This will enable systems to communicate over HTTPS in this situation.
> .\extract-ca-certs.ps1

# Edit configuration for VertiGIS Studio:
> code docker-compose.yaml
> notepad docker-compose.yaml

# If not already done, create SSH key (we suggest using the defaults):
> ssh-keygen -t ed25519

# For convenience, set the target system:
> $server = "user@my-linux-server.contoso.net"

# If not already done, register yourself for passwordless login:
> (gc $env:USERPROFILE\.ssh\id_ed25519.pub -Raw) | ssh $server 'cat >> ~/.ssh/authorized_keys'
```

### Update the Deployment

``` powershell
# For convenience, set the target system:
> $server = "user@my-linux-server.contoso.net"

# Transfer context and SSH:
> scp -r . "$server`:deploy-studio"
> ssh $server
> cd deploy-studio
```

### Continue Setup on Linux

- [Initial Setup](#on-linux-initial-setup)
- [Upgrade to Latest](#on-linux-upgrade-to-latest)

## Port Management

The Studio image will provide HTTP access (container port 8080) and
HTTPS access (container port 8443). You may map these ports however you
like on the host machine (see configuration).

### Bring you own Reverse Proxy

If you wish to use your own reverse proxy, you will want to expose the
container via non-standard ports. Afterwards, you will need to configure
your reverse proxy to route to one of these ports. Remember to give the
container a certificate if you plan to route to the HTTPS port.

### Leverage the HTTPS Feature

If you wish, you may leverage the HTTPS port directly and route the
standard HTTPS port (443) to the container port (8443).

## Give the Container a Real Web Certificate

The container is setup to use SSL certificates if provided. You have a
few options for certificate issuance:

### Use ACME via `certbot` from Let’s Encrypt (RECOMMENDED)

The most straightforward option for requesting an SSL certificate on
Linux is to use ACME. `certbot` lets you easily manage this exchange via
some simple prompts:

``` bash
# Configure certbot for your domain
# NOTE: You only need to do this once per domain of interest.
# NOTE: You must have port 80 open.
# NOTE: You will be prompted to answer some questions.
# NOTE: Windows Enterprise environments can enable ACME, ask your Enterprise Admin.
# If using a public domain:
> sudo certbot certonly --standalone -d my-server.contoso.com
# If using a non-public domain or custom ACME server:
> sudo certbot certonly --standalone -d my-server.contoso.com --server <url>

# You may run certbot to renew your SSL certificate at any time:
> sudo certbot renew

# If you wish to apply the cert immediately:
> docker exec vs-studio-main-1 util-refresh
```

### Use a given `.pfx` file

``` powershell
# If on Windows, copy the .pfx file into the right place:
# For convenience, set the target system:
> $server = "user@my-linux-server.contoso.net"

# Transfer PFX:
> scp -r path\to\my.pfx "$server`:deploy-studio/certs-web/host.pfx"

# SSH into the server:
> ssh $server
```

``` bash
# If not already done, copy the .pfx file into the right place:
> mkdir -p certs-web
> cp path/to/my.pfx certs-web\host.pfx

# Convert .pfx file into the right format:
> bash ./convert-pfx.sh

# If you wish to apply the cert immediately:
> docker exec vs-studio-main-1 util-refresh
```

## Using Studio as a Reverse Proxy

For convenience, the Studio image provides a means of using the internal
NGINX server as a reverse proxy. You can take advantage of this for
whatever needs you have:

- Modify `nginx-server/nginx.conf` file
- Refresh your deployment (see [here](#on-linux-upgrade-to-latest))
