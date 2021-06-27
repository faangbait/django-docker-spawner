#!/bin/bash
echo New Project Name?
read PROJNAME

tar -xvf newproject.tar.gz
mv newproj "$PROJNAME"
echo "  $PROJNAME:" >> docker-compose.yaml
echo "    build: $PROJNAME/" >> docker-compose.yaml
echo "    command: python manage.py runserver 0.0.0.0:80" >> docker-compose.yaml
echo "    volumes:" >> docker-compose.yaml
echo "      - ./$PROJNAME:/code" >> docker-compose.yaml
echo "    ports:" >> docker-compose.yaml
echo "      - \"80:80\"" >> docker-compose.yaml
echo "    networks:" >> docker-compose.yaml
echo "      default:" >> docker-compose.yaml

sudo docker-compose run "$PROJNAME" django-admin startproject "$PROJNAME" .
sudo chown -R $USER:$USER .
