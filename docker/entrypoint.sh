#!/bin/ash

# Fail fast on errors / unset vars (but allow optional vars via ${VAR:-})
set -eu

# check if running inside PyCharm
if [ -n "${PYCHARM_HOSTED:-}" ]; then
  # when running from PyCharm just pass all arguments to enable debugger
  exec "$@"
fi

# Run via python -m to avoid issues with the gunicorn wrapper script/shebang.
exec /doko3000/.venv/bin/python -m gunicorn \
  --worker-class eventlet \
  --workers 1 \
  --log-level ERROR \
  --bind :5000 \
  doko3000.web:app