#!/bin/ash

# check if running inside PyCharm
if [ ! -z "${PYCHARM_HOSTED}" ];
  then
    # when running from PyCharm just pass all arguments to enable debugger
    $@
  else
    # gunicorn drops privileges to doko3000 user
    # Run via python -m to avoid issues with the gunicorn wrapper script/shebang.
    /doko3000/.venv/bin/python -m gunicorn --user doko3000 \
             --group doko3000 \
             --worker-class eventlet \
             --workers 1 \
             --log-level ERROR \
             --bind :5000 \
             main:app
fi