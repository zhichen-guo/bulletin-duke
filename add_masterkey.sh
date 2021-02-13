#!/bin/bash
echo "***Provide your web application's masterkey***"
read -p "Masterkey:" MASTERKEY
echo "***Adding masterkey to bash***"
echo "export BULLETIN_MASTER_KEY=\"$MASTERKEY\"" >> ~/.bashrc