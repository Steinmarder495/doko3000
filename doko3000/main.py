#!/usr/bin/env python3
#
# ©2020-2022 Henri Wahl
#
# Attempt to play good ol' Doppelkopf online
#

from .web import app, \
    socketio

def main():
    socketio.run(app, host='::')

if __name__ == '__main__':
    main()
