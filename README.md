# Studio Base - Installation
_Updated on: Fri Mar 28 10:44:12 PDT 2025_
- [Links](#links)
- [System Requirements](#system-requirements)
- [Preparation](#preparation)
  - [Account ID and Registry
    Credentials](#account-id-and-registry-credentials)
  - [Linux Machine](#linux-machine)
  - [Front-End URL](#front-end-url)
  - [ArcGIS Portal and Application
    Registration](#arcgis-portal-and-application-registration)
  - [Get the Package](#get-the-package)
- [On Linux: Initial Setup](#on-linux-initial-setup)
- [On Linux: Upgrade to Latest](#on-linux-upgrade-to-latest)
- [On Windows: Initial Setup](#on-windows-initial-setup)
- [On Windows: Login via SSH](#on-windows-login-via-ssh)
  - [Continue Setup on Linux](#continue-setup-on-linux)
- [Port Management](#port-management)
  - [Bring you own Reverse Proxy](#bring-you-own-reverse-proxy)
  - [Leverage the HTTPS Feature](#leverage-the-https-feature)
- [Give the Container a Web
  Certificate](#give-the-container-a-web-certificate)
  - [Provide a Web Certificate
    Directly](#provide-a-web-certificate-directly)
  - [Use Enrollment Services (Windows
    Only)](#use-enrollment-services-windows-only)
  - [Reference INF file](#reference-inf-file)
- [Using Studio as a Reverse Proxy](#using-studio-as-a-reverse-proxy)

## Links

- [This
  Release](https://github.com/vertigis/studio-base/releases/v1.1.632.232243-r14134787850)
  ( v1.1.632.232243-r14134787850 )
  - [Image](https://github.com/vertigis/studio-base/pkgs/container/studio%2fbase/384190875?tag=v1.1.632.232243-r14134787850)
  - [Installation Guide](https://github.com/)
  - [Deployment Package
    (ZIP)](https://github.com/vertigis/studio-base-internal/archive/refs/tags/v0-pr-13249732233.zip)
  - [Deployment Package
    (TGZ)](https://github.com/vertigis/studio-base-internal/archive/refs/tags/v0-pr-13249732233.tar.gz)
- [Releases](https://github.com/vertigis/studio-base/releases)
- [Images](https://github.com/vertigis/studio-base/pkgs/container/studio%2fbase)
- [Repository](https://github.com/vertigis/studio-base)
- [Site](https://vertigis.github.io/studio-base/)

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
- VertiGIS Docker Registry Login Credentials

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

``` bash
> mkdir -p deploy-studio
> cd deploy-studio
> curl -fsSL https://vertigis.github.io/studio-install-help/deploy-studio.tgz | tar -xz
```

``` cmd
> mkdir deploy-studio
> cd deploy-studio
> curl -fsSL https://github.com/vertigis/studio-base/archive/refs/tags/v1.1.632.232243-r14134787850.tar.gz -o deploy.tar.gz
> tar -xzf deploy.tgz
> del deploy.tgz
```

``` powershell
> mkdir deploy-studio
> cd deploy-studio
> iwr -Uri https://github.com/vertigis/studio-base/archive/refs/tags/v1.1.632.232243-r14134787850.zip -OutFile deploy.zip
> exa -Path deploy.zip -DestinationPath .
> del deploy.zip
```

``` git
> git clone --depth 1 --branch v1.1.632.232243-r14134787850 https://github.com/vertigis/studio-base deploy-studio
> cd deploy-studio
```

## On Linux: Initial Setup

``` bash
# Install Docker and supporting tools
> sudo ./install-tools.sh

# Edit configuration for VertiGIS Studio
# If using a plain terminal, try one of these:
> nano docker-compose.yaml
> vi docker-compose.yaml
# If using a GUI, try one of these:
> code docker-compose.yaml &
> gedit docker-compose.yaml &
> kate docker-compose.yaml &
> mousepad docker-compose.yaml &

# Gain access to images (you must create a PAT)
> docker login ghcr.io -u x-access-token

# Pull/Start VertiGIS Studio
> docker compose up --wait
```

## On Linux: Upgrade to Latest

``` bash
# If login has expired, gain access to images
> docker login ghcr.io -u x-access-token

# Pull down VertiGIS Studio
> docker compose pull

# Upgrade VertiGIS Studio
> docker compose up --wait

# Refresh configuration 
> docker exec studio-main-1 util-refresh
```

## On Windows: Initial Setup

``` powershell
# ADMIN: Install required tools
> .\install-tools.ps1

# Extract CA certificates from Active Directory
# Some environments may use an internal CA system.
# This will enable systems to communicate over HTTPS in this situation.
> .\extract-ca-certs.ps1

# Edit configuration for VertiGIS Studio
> code docker-compose.yaml
> notepad docker-compose.yaml

# Create SSH key
> ssh-keygen -t ed25519

# Enable passwordless SSH
> .\rsat-auth.ps1 user@linux.contoso.com
```

## On Windows: Login via SSH

``` powershell
# ADMIN: Request Web certificates using Enrollment Services
# This step can be skipped if testing or if no web certificate is needed.
# Refer to the section on using Enrollment Services.
> .\request-web-certs.ps1

# Transfer context to remote deploy-studio folder.
> .\rsat-transfer.ps1 user@linux.contoso.com deploy-studio
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

## Give the Container a Web Certificate

Some Windows enterprise environments require using internal CA services
for secure communication. If you plan on using Studio as a frontend,
you’ll want to give the container a real web certificate. Your IT
professional can likely help with this. Although, you can likely perform
this task independently.

### Provide a Web Certificate Directly

- Edit the `docker-compose.yaml` file
- Adjust the `WEB_CERT` setting
  - `host` is the default value
- Go to the `web-certs` folder
  - Place the `.pfx` file here
  - Give this file a name like `host_<id>.pfx`
- Update your deployment (see [here](#on-linux-upgrade-to-latest))

### Use Enrollment Services (Windows Only)

- Edit the `docker-compose.yaml` file
- Adjust the `WEB_CERT` setting
  - `host` is the default value
- Go to the `web-certs` folder
  - Copy the `sample.inf` file to `host.inf`
  - Remove the `sample.inf` file
  - Edit the `host.inf` file (reference [here](#reference-inf-file))
  - Adjust the Subject
  - Adjust the DNS names
  - Save this file
- Update your deployment (see [here](#on-windows-login-via-ssh))

### Reference INF file

``` inf
[NewRequest]
Subject = "CN=System Name, O=Example Corp, OU=IT Department, L=New York, ST=New York, C=US"
...

[Extensions]
2.5.29.17 = "{text}"
_continue_ = "dns=server1.contoso.com&"
_continue_ = "dns=server2.contoso.com"
...
```

## Using Studio as a Reverse Proxy

For convenience, the Studio image provides a means of using the internal
NGINX server as a reverse proxy. You can take advantage of this for
whatever needs you have:

- Modify `server/nginx.conf` file
- Update your deployment (see [here](#on-linux-upgrade-to-latest))
