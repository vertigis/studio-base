![](vertigis-studio-logo.svg)
# Studio Base - Installation
_Updated on: Fri Jun 20 09:25:03 PDT 2025_
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
- [Deployment Overview](#deployment-overview)
- [On Windows: Install SSH and Supporting
  Tools](#on-windows-install-ssh-and-supporting-tools)
- [On Remote: Setting up SSH](#on-remote-setting-up-ssh)
- [On Remote: Remote in via SSH](#on-remote-remote-in-via-ssh)
- [On Linux Host: Get the Package](#on-linux-host-get-the-package)
- [On Remote: Activate the Product](#on-remote-activate-the-product)
- [On Linux Host: Initial Setup](#on-linux-host-initial-setup)
- [On Linux Host: Updating](#on-linux-host-updating)
- [Check List](#check-list)

## Links

- [This
  Release](https://github.com/vertigis/studio-base/releases/v1.1.714.249788-r15783336765)
  ( v1.1.714.249788-r15783336765 )
  - [Image](https://github.com/vertigis/studio-base/pkgs/container/studio%2fbase/443236723?tag=v1.1.714.249788-r15783336765)
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

- [Docker — Getting Started](https://docs.docker.com/get-started/)
- [Docker Compose — Getting
  Started](https://docs.docker.com/compose/gettingstarted/)
- [SSH Tutorial](https://www.ssh.com/academy/ssh)
- [SSH Tutorial — Microsoft
  Learn](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_overview)
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

## Deployment Overview

The primary part of the installation will happen on the Linux machine
you have provisioned for this task. You may still use Windows as a means
to remotely administer your Linux system.

The package includes an ingress proxy (Traefik) and demonstrates how to
use said ingress mechanism. If you are using Windows, we suggest
enabling ACME on your Enterprise CA as this will be the easiest way to
acquire an Web Server certificates through the ingress proxy.

## On Windows: Install SSH and Supporting Tools

If using Windows to remotely administer your Linux environments, you’ll
need a variety of tools. We suggest using a full-featured SSH client
like VS Code to perform administrative tasks in this case. VS Code
supports remote file editing as well as remote command execution.

``` powershell
# If not already done, install supporting tools
> Get-WindowsCapability -Online -Name RSAT.ActiveDirectory.* | Add-WindowsCapability -Online
> Add-WindowsCapability -Online -Name OpenSSH.Client

# If desired, install vscode
> winget install vscode
> code --install-extension ms-vscode-remote.remote-ssh
```

You can do this via the GUI as well:

- Goto Windows Optional Features -\> Add an Optional Feature:
  - Install RSAT: Active Directory Domain Services
  - Install OpenSSH Client
- Optionally, download and install the following:
  - [VS Code](https://code.visualstudio.com/download)
  - Install the Remote SSH Extension

## On Remote: Setting up SSH

``` sh
# Create SSH key (we suggest using the defaults):
# NOTE: Only do this once or if you want to generate new key.
> ssh-keygen -t ed25519

# Register for passwordless login (optional but recommended)
# If on Linux:
> ssh-copy-id user@host
# If on Windows, you'll need to do this manually:
> scp %USERPROFILE%\.ssh\id_ed25519.pub user@host:~
> ssh user@host
> umask 077
> mkdir -p .ssh
> read line < id_ed25519.pub
> echo $line >> .ssh/authorized_keys
> rm id_ed25519.pub
> exit
```

## On Remote: Remote in via SSH

``` sh
# If using ssh directly:
> ssh user@host
# If using vscode:
> code --remote ssh-remote+user@host /home/user
```

## On Linux Host: Get the Package

``` bash
# If desired, use curl:
> mkdir -p ~/deploy-studio
> cd ~/deploy-studio
> curl -fsSL https://github.com/vertigis/studio-base/archive/refs/tags/v1.1.714.249788-r15783336765.tar.gz | tar -xz
# If desired, use git:
> git clone --depth 1 --branch v1.1.714.249788-r15783336765 https://github.com/vertigis/studio-base ~/deploy-studio
> cd ~/deploy-studio

# Install Docker and supporting tools if needed
> sudo ./install-tools.sh
> exec sudo su - $USER
```

## On Remote: Activate the Product

``` sh
# If session is local xterm, local vscode, or remote vscode:
> ~/deploy-studio/activate.py
# If session is remote through ssh:
> ssh -L localhost:7780:localhost:7780 user@host ~/deploy-studio/activate.py
```

## On Linux Host: Initial Setup

``` bash
# Switch to the deployment folder
> cd ~/deploy-studio

# If you need to discover your Enterprise Root certificates
> ./extract-ca-certs.py

# Edit configuration for VertiGIS Studio
# See checklist for what to edit.
# If using a plain terminal, try one of these:
> nano docker-compose.yml
> vi docker-compose.yml
# If using a GUI, try one of these:
> code docker-compose.yml &
> gedit docker-compose.yml &
> kate docker-compose.yml &
> mousepad docker-compose.yml &

# Gain access to images
> gh auth login -w -s repo,read:packages
> gh auth token | docker login ghcr.io -u x-access-token --password-stdin

# Pull/Start VertiGIS Studio
> docker compose up --wait --build

# Optionally, deploy the VertiGIS Studio Printing Engine
> docker exec vs-studio-main-1 util-deploy-printing-engine
```

## On Linux Host: Updating

``` bash
# Switch to the deployment folder
> cd ~/deploy-studio

# If login has expired, gain access to images
> gh auth login -w -s repo,read:packages
> gh auth token | docker login ghcr.io -u x-access-token --password-stdin

# Optionally, pull down VertiGIS Studio
> docker compose pull
# Then, upgrade VertiGIS Studio
> docker compose up --wait --build

# Optionally, hot refresh configuration
> docker exec vs-studio-main-1 util-refresh
```

## Check List

- Editing docker.compose.yml:
  - Set the front-end URL via `FRONTEND_URL`
  - Set the VertiGIS Account ID via `VERTIGIS_ACCOUNT_ID`
  - Set the ArcGIS Portal URL via `ARCGIS_PORTAL_URL`
  - Set the ArcGIS App ID via `ARCGIS_APP_ID`
