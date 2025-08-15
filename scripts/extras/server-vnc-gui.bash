#!/bin/bash

sudo systemctl start sshd
sudo x0vncserver -display :0 -localhost -alwaysshared -geometry 1920x1080 -rfbauth ~/.config/tigervnc/passwd

