#!/bin/sh
# Writes runtime env vars into a JS config file before nginx starts.
# The HTML page loads /env-config.js and reads window.__ENV__.
set -e

cat > /usr/share/nginx/html/env-config.js <<JSEOF
window.__ENV__ = {
  "APP_ENV":       "${APP_ENV:-dev}",
  "GIT_COMMIT":    "${GIT_COMMIT:-unknown}",
  "GIT_BRANCH":    "${GIT_BRANCH:-unknown}",
  "BUILD_DATE":    "${BUILD_DATE:-unknown}",
  "K8S_NAMESPACE": "${K8S_NAMESPACE:-unknown}",
  "K8S_POD_NAME":  "${K8S_POD_NAME:-unknown}",
  "PR_NUMBER":     "${PR_NUMBER:-}"
};
JSEOF

exec "$@"
