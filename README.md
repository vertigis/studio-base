![](vertigis-studio-logo.svg)
# Studio Base - Installation
_Updated on: Thu Nov 6 19:04:06 PST 2025_
- [Links](#links)
- [Reference Guides](#reference-guides)
- [VertiGIS Studio-Base: An
  Introduction](#vertigis-studio-base-an-introduction)
  - [Why Use VertiGIS Studio-Base?](#why-use-vertigis-studio-base)
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
  - [On Windows: Testing with Docker Desktop and
    WSL](#on-windows-testing-with-docker-desktop-and-wsl)
  - [On Remote: Setting up SSH](#on-remote-setting-up-ssh)
  - [On Remote: Remote in via SSH](#on-remote-remote-in-via-ssh)
  - [On Linux Host: Get the Package](#on-linux-host-get-the-package)
  - [On Remote: Activate the Product](#on-remote-activate-the-product)
  - [On Linux Host: Initial Setup](#on-linux-host-initial-setup)
  - [On Linux Host: Updating](#on-linux-host-updating)
  - [Check List](#check-list)

## Links

- [This
  Release](https://github.com/vertigis/studio-base/releases/v1.1.855.282339-r19156775830)
  ( v1.1.855.282339-r19156775830 )
  - [Image](https://github.com/vertigis/studio-base/pkgs/container/studio%2fbase/569105249?tag=v1.1.855.282339-r19156775830)
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

# VertiGIS Studio-Base: An Introduction

VertiGIS Studio-Base refers to the deployment of VertiGIS Studio using
container technology, specifically Docker, on a Linux operating system.
It provides a structured way to install and run VertiGIS Studio, which
is designed for developing GIS applications that integrate with Esri’s
ArcGIS Portal.

The setup involves preparing a Linux machine, obtaining necessary
account credentials for VertiGIS and GitHub (for image access), and
configuring the deployment using a `docker-compose.yml` file. The
package includes tools and scripts to aid in installation, activation,
and updates.

## Why Use VertiGIS Studio-Base?

Deploying VertiGIS Studio using the Studio-Base package offers several
advantages focused on a managed and reproducible environment:

- **Standardized Deployment:** Utilizes Docker and Docker Compose for a
  consistent setup process across different Linux machines that meet the
  system requirements (specific Ubuntu or Debian distributions).
- **Defined Operating Environment:** Requires a specific Linux
  distribution, ensuring that the software runs in a known and tested
  environment.
- **Integrated Ingress Management:** The deployment package includes
  Traefik as an ingress proxy, demonstrating a method for managing
  external access to the Studio application.
- **Configuration-Driven Setup:** Key parameters such as the front-end
  URL, VertiGIS Account ID, and ArcGIS Portal details are managed
  through the `docker-compose.yml` file, centralizing configuration.
- **Streamlined Installation and Activation:** Provides scripts and a
  defined process for getting the necessary tools, activating the
  product, and starting the VertiGIS Studio services.
- **Clear Update Path:** Offers commands for pulling the latest images
  and updating the running deployment.
- **ArcGIS Integration:** The setup process explicitly includes steps
  for registering the application with an ArcGIS Portal, highlighting
  its core integration.

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

We require Linux to run VertiGIS Studio in containers. You must have a
suitable distribution/version of Linux installed on an appropriately
resourced machine. Please review the system requirements. We suggest
using this Linux machine as a pure Docker host. In other words, do not
install software directly on the host system.

### Front-End URL

The front-end URL for the software’s hosting location is a required
configuration. Multiple internal components utilize this value for
proper functionality.

### ArcGIS Portal and Application Registration

Go to your portal and create a web application:

1.  Register this application (enable OAUTH2).
2.  Provide a Redirect URL (use the Front-End URL).
3.  Note the App ID.

## Deployment Overview

The primary part of the installation occurs on the Linux machine you
have provisioned for this task. You can use Windows as a means to
remotely administer your Linux system.

The package includes an ingress proxy (Traefik) and demonstrates how to
use the ingress mechanism. If you are using Windows, we suggest enabling
ACME on your Enterprise CA as this will be the easiest way to acquire
Web Server certificates through the ingress proxy.

## On Windows: Install SSH and Supporting Tools

If using Windows to remotely administer your Linux environments, you
will need a variety of tools. We suggest using a full-featured SSH
client like VS Code to perform administrative tasks. VS Code supports
remote file editing as well as remote command execution.

``` powershell
# If not already done, install supporting tools
> Add-WindowsCapability -Online -Name OpenSSH.Client

# If desired, install vscode
> winget install vscode
> code --install-extension ms-vscode-remote.remote-ssh
```

You can do this via the GUI as well:

- Goto Windows Optional Features -\> Add an Optional Feature:
  - Install OpenSSH Client
- Optionally, download and install the following:
  - [VS Code](https://code.visualstudio.com/download)
  - Install the Remote SSH Extension

## On Windows: Testing with Docker Desktop and WSL

If you wish to test with Docker Desktop, you will need to following
installations instructions (see below). Please note that Docker Desktop
and WSL environments are not production grade environments. However,
these tools are extremely useful ways of testing locally. - [Docker
Desktop](https://docs.docker.com/desktop/) -
[WSL2](https://learn.microsoft.com/en-us/windows/wsl/install)

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
> curl -fsSL https://github.com/vertigis/studio-base/archive/refs/tags/v1.1.855.282339-r19156775830.tar.gz | tar -xz
# If desired, use git:
> git clone --depth 1 --branch v1.1.855.282339-r19156775830 https://github.com/vertigis/studio-base ~/deploy-studio
> cd ~/deploy-studio

# Install the Docker Engine:
> curl -fsSL https://get.docker.com -o get-docker.sh
> sudo sh ./get-docker.sh

# Add yourself to the docker group:
> usermod -aG docker $USER
> exec sudo su - $USER
```

## On Remote: Activate the Product

``` sh
# If session is local xterm, local vscode, or remote vscode:
> cd ~/deploy-studio
> ./tools.sh activate
# If session is remote through ssh:
> ssh -L localhost:7780:localhost:7780 user@host ~/deploy-studio/tools activate
```

## On Linux Host: Initial Setup

``` bash
# Switch to the deployment folder
> cd ~/deploy-studio

# If you need to discover your Enterprise Root certificates
> ./tools.sh extract-ca-certs

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
