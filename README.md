# ![](https://apps.vertigisstudio.com/favicon.ico) VertiGIS Studio Base

Container image for running VertiGIS Studio Base with Docker.

See [docs](https://vertigis.github.io/studio-base/).

## Image

```text
ghcr.io/vertigis/studio/base:v1.1.1030.330038-r25200186693
```

## Registry login

```sh
gh auth login -w -s read:packages
gh auth token | docker login ghcr.io -u x-access-token --password-stdin
```

## Quick start

```sh
docker run -d --name studio-base \
  -p 8080:8080 \
  -e ARCGIS_APP_ID=app_id \
  -e ARCGIS_PORTAL_URL=https://portal.example.com/portal \
  -e VERTIGIS_ACCOUNT_ID=account_id \
  -e FRONTEND_URL=https://studio.example.com/studio \
  -v studio-data:/data \
  -v studio-logs:/var/log \
  -v studio-temp:/stmp \
  ghcr.io/vertigis/studio/base:v1.1.1030.330038-r25200186693
```

## Compose example

```yaml
services:
  studio-base:
    image: ghcr.io/vertigis/studio/base:v1.1.1030.330038-r25200186693
    restart: unless-stopped
    ports:
      # Expose Studio Base on the host.
      - "8080:8080"
    environment:
      # ArcGIS OAuth application ID from your ArcGIS Portal app registration.
      ARCGIS_APP_ID: app_id
      # Base URL of your ArcGIS Portal.
      ARCGIS_PORTAL_URL: https://portal.example.com/portal
      # VertiGIS account ID provided by VertiGIS support.
      VERTIGIS_ACCOUNT_ID: account_id
      # Public URL users will browse to.
      FRONTEND_URL: https://studio.example.com/studio
      # Optional runtime settings.
      VERTIGIS_PURGE: "1"
      VERTIGIS_WORKERS: "8"
    volumes:
      # Persist application data, logs, and temp files.
      - studio-data:/data
      - studio-logs:/var/log
      - studio-temp:/stmp

volumes:
  studio-data:
  studio-logs:
  studio-temp:
```

## Required environment variables

| Variable | Description |
| --- | --- |
| `ARCGIS_APP_ID` | ArcGIS application ID from your ArcGIS Portal app registration |
| `ARCGIS_PORTAL_URL` | ArcGIS Portal URL |
| `VERTIGIS_ACCOUNT_ID` | VertiGIS account ID provided by VertiGIS support |
| `FRONTEND_URL` | Public Studio Base URL |

## Finding the IDs

- `ARCGIS_APP_ID`: create or open the app registration in ArcGIS Portal and copy the application ID.
- `VERTIGIS_ACCOUNT_ID`: request this value from VertiGIS support.

## Data

Persist these paths if you want data and logs to survive container replacement:

- `/data`
- `/var/log`
- `/stmp`
