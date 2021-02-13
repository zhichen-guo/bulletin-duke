#!/bin/bash
sudo chown -R $USER:$USER .
echo "*** Building docker image ***"
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
docker exec -i Bulletin bash < start_production.sh