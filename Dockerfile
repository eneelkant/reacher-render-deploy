# Minimal wrapper for Render Docker runtime.
# Upstream image: https://hub.docker.com/r/reacherhq/commercial-license-trial
FROM reacherhq/commercial-license-trial:latest

# Service listens on 8080 (see upstream docker run -p 8080:8080).
EXPOSE 8080

# Do not override ENTRYPOINT or CMD — preserve the official image defaults.
