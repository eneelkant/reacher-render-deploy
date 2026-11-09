# reacher-render-deploy

Minimal Docker-based deployment of the [Reacher](https://reacher.email/) **Commercial License Trial** image for [Render](https://render.com/)’s Docker runtime.

This repository exists so you can run the official trial backend as a web service (for example behind [eneelkant/email-validation-tool](https://github.com/eneelkant/email-validation-tool)) without packaging application source code.

## Docker image

| Item | Value |
|------|--------|
| Base image | `reacherhq/commercial-license-trial:latest` |
| Dockerfile | Thin wrapper: `FROM` the official image, `EXPOSE 8080` only |
| Entrypoint / CMD | Unchanged — uses the official image defaults |
| Container port | **8080** |
| Built-in proxy | Trial image includes preconfigured Proxy4Smtp |

Upstream run example:

```bash
docker run -p 8080:8080 \
  -e RCH__COMMERCIAL_LICENSE_TRIAL__API_TOKEN=YOUR_TOKEN \
  reacherhq/commercial-license-trial:latest
```

This repo’s Dockerfile does not invent extra environment variables, does not hardcode tokens, and does not override `ENTRYPOINT` or `CMD`.

### Official image defaults

The official image is documented to listen on **port 8080**. This repository does **not** assume that setting `PORT=8080` or `RCH__HTTP_HOST=0.0.0.0` is required or supported by the trial image. Only use configuration that Reacher documents for this image. If Render asks for a port, map the service to **8080** to match the upstream `docker run -p 8080:8080` example.

Do **not** configure a `/health` (or similar) health-check path unless Reacher officially documents one for this image.

## Deploy on Render (Docker runtime)

1. Create a new **Web Service** on Render and connect this GitHub repository.
2. Set the runtime to **Docker** (Render builds from the `Dockerfile` in the repo root).
3. Set the service port to **8080**.
4. Add the required environment variable (see below) in the Render dashboard — do not commit it.
5. Deploy. Render Free instances may spin down when idle; the first request after idle can be slow while the instance wakes.

### Required environment variable

| Name | Required | Notes |
|------|----------|--------|
| `RCH__COMMERCIAL_LICENSE_TRIAL__API_TOKEN` | Yes | Your Reacher Commercial License Trial API token. Set it in Render → Environment. Never commit the real value. |

No other environment variables are required by this minimal deploy. Do not invent undocumented `RCH__*` settings.

## API

The service exposes:

- **Method / path:** `POST /v1/check_email`
- **Port:** `8080` (inside the container; use your Render HTTPS URL externally)

### Example request

Replace `YOUR_RENDER_URL` with your Render service hostname (no trailing slash) and send a JSON body with the address to check:

```bash
curl -X POST "https://YOUR_RENDER_URL/v1/check_email" \
  -H "Content-Type: application/json" \
  -d '{"to_email": "test@example.com"}'
```

Exact request/response fields follow Reacher’s Commercial License Trial API documentation. Authenticate as required by that documentation (typically via the trial API token configured in the container environment).

## Security guidance for API tokens

- Store `RCH__COMMERCIAL_LICENSE_TRIAL__API_TOKEN` only in Render environment settings (or a secret manager).
- Never commit tokens to git, Dockerfiles, `.env` files in the repo, screenshots, or issue/PR text.
- Rotate the token if it may have been exposed.
- Restrict who can view Render environment variables for this service.
- Prefer calling your Render URL over HTTPS only; do not expose the service over plain HTTP on the public internet when avoidable.

## Limits and notices

### Render Free

- Free web services on Render can **sleep after inactivity**; cold starts add latency.
- Free plans have limited compute, bandwidth, and monthly usage. Expect slower performance than paid instances.
- See [Render’s pricing / free tier docs](https://render.com/docs) for current limits; they can change.

### Reacher Trial

- The Commercial License Trial allows up to **10,000 email checks per day**.
- The trial image includes preconfigured Proxy4Smtp for SMTP checks.
- **Anonymized usage metrics are shared with Reacher** when you use the trial image. Review Reacher’s trial terms if that matters for your deployment.

## Local smoke test (optional)

```bash
docker build -t reacher-trial .
docker run --rm -p 8080:8080 \
  -e RCH__COMMERCIAL_LICENSE_TRIAL__API_TOKEN=YOUR_TOKEN \
  reacher-trial
```

Then `POST` to `http://localhost:8080/v1/check_email` as in the example above.

## What this repo does not do

- Does not deploy automatically or create cloud resources for you.
- Does not include application source beyond the thin Docker wrapper and docs.
- Does not hardcode credentials or undocumented configuration.
