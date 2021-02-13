#!/bin/bash
echo "***Creating certificate and key***"
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout certificate.key -out certificate.crt
echo "***Making directory to store key and certificate***"
mkdir ./config/certs
echo "***Moving files into directory***"
mv certificate.key ./config/certs/.
mv certificate.crt ./config/certs/.