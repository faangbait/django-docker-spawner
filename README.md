# django-docker-spawner

This is a working solution for a single-node/devbox that I use to spawn django projects at independent IPs, e.g. on their own subnet. It can also spawn other stuff; like a rabbitmq server, at its own IP.

## Set Up IPVLAN Routing

Deploy an external IPVLAN network using a command similar to:

```docker network create -d ipvlan --subnet=10.0.3.0/24 --gateway=10.0.3.1 -o parent=eno2 dockernet```

Test deploy some containers with commands like the following; this should prove you can ping your new containers at the corresponding ips.

```
docker run --net=dockernet -it --name testbox --rm alpine /bin/sh

docker run --net=dockernet -it --name testbox2 --rm alpine /bin/sh
```

Each container instance should be accessible at its own IP address (e.g. 10.0.3.2, 10.0.3.3)

For more information about my external network so you can customize this command for yourself, consider:

- This is running on a server PC on interface eno2
- My router is the 10.0.3.1 gateway for the 10.0.3.0/24 network; providing dns and dhcp services.

## Deploying a new django project into the subnet
1. Clone/cd into this repo
2. Probably edit my docker-compose.yaml's postgres volume unless you're also /home/ss/
3. Run ./start_project.sh
4. Enter the project name; it will become the folder name in this directory. Keep it simple; no spaces.

## Advanced networking stacks - isolation of frontend/backend - vlans
Instructions split off into cables.madeof.glass.md because this gets complicated
