# django-docker-spawner

0. Deploy an external network using the following (or similar) command:

docker network create -d ipvlan --subnet=10.0.3.0/24 --gateway=10.0.3.1 -o parent=eno2 dockernet

docker run --net=dockernet --options

1. Clone/cd into the repo
2. Run ./start_project.sh
3. Enter the project name; will become the folder name in this directory. Keep it simple; no spaces.

