#!/bin/bash

sudo systemctl start sshd
sudo x0vncserver -rfbauth ~/.config/tigervnc/passwd

