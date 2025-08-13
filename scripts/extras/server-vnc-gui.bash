#!/bin/bash

# Make sure to set `localhost` in $XDG_CONFIG_HOME/tigervnc/config, otherwise, the
# connection will be insecure.

sudo systemctl start vncserver@:1.service
sudo x0vncserver -rfbauth ~/.config/tigervnc/passwd

