#!/bin/bash
echo "***Input your hostname or alias below***"
read -p "Hostname:" HOSTNAME
echo "***Hostname is \"$HOSTNAME\"***"
echo "***Adding hostname to bash config file***"
echo "export HOSTNAME_URL=\"$HOSTNAME\"" >> ~/.bashrc
echo "***Applying changes***"
exec bash -l
