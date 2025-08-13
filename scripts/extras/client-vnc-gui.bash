#!/bin/bash

read -rp "IP of remote: " ip 
read -rp "Location of key: " key
read -rp "Port of user session on remote: " port # I have configured to 5901

# A one liner for port forwarding during the connection and closing it right after
ssh -fL 9901:localhost:$port $ip -i $key sleep 10; vncviewer localhost:9901
