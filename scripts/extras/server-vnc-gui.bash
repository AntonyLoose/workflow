#!/bin/bash

# I use a weird geometry as my laptop resolution is weird.
sudo x0vncserver -display :0 -localhost -alwaysshared -geometry 1366x768 -rfbauth ~/.config/tigervnc/passwd

