#!/usr/bin/env python3
#
# ©2020-2022 Henri Wahl
#
# Attempt to play good ol' Doppelkopf online
#
# This file exists for gunicorn compatibility in Docker
# For development, use: uv run doko-dev

from doko3000.web import app

if __name__ == '__main__':
    # This won't be used in Docker (gunicorn calls it directly)
    # but kept for compatibility
    from doko3000.web import socketio
    socketio.run(app, host='::')
