# django-docker-spawner

0. Deploy an external IPVLAN network using a command similar to:

```docker network create -d ipvlan --subnet=10.0.3.0/24 --gateway=10.0.3.1 -o parent=eno2 dockernet```

```
[slightly more tasteful version]
docker network create -d ipvlan --subnet=10.0.10.0/24 --gateway=10.0.10.1 -o parent=eno2.10 dockernet
```

```docker run --net=dockernet --options```

This will make sure that each django instance is accessible at its own IP address (e.g. 10.0.3.2, 10.0.3.3)

For more information about my external network so you can configure this command for yourself, consider:

- This is running on a server PC on interface eno2
- My router is the 10.0.3.1 gateway for the 10.0.3.0/24 network
- This step (or a similar ipvlan) step is required, so that all django instances are served on port 80.

1. Clone/cd into the repo
2. Probably edit docker-compose.yaml's postgres volume unless you're also /home/ss/
3. Run ./start_project.sh
4. Enter the project name; will become the folder name in this directory. Keep it simple; no spaces.

