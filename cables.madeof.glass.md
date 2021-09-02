# more advanced django/microservices routing documentation

The goal of this documentation is to expand on the generic django spawner to provide multiple vlanned subnets. The goal is to establish Traefik as a reverse proxy to serve content out of multiple docker-compose stacks that can't speak to each other.

In a perfect world, the architecture of this would look similar to:

- A traefik proxy providing REST API and other frontend services for users
- Internal developer-oriented stacks that are still ip accessible from inside the LAN, but would NOT be accessible over Traefik. For instance, a HashiCorp vault for keeping secrets or certificate stores.
- Specific backend stacks to support each of the front-end microservices. For example, a compose file launching django, nginx, redis, postgres. This microservice compose stack would be entirely isolated from a second microservice compose stack, even if the second stack also was django/nginx/redis/postgres.


```
[slightly more tasteful version with vlan support]

  ip link add link eno2 name eno2.10 type vlan id 10 # these are test commands; migrate this to /etc/network/interfaces
  ip link set up eno2.10
  docker network create -d ipvlan --subnet=10.0.10.0/24 --gateway=10.0.10.1 -o parent=eno2.10 dockernet

[also requires switch configuration]
  Add VLAN Interface >
  VLAN_ID: 10
  Interface: eth2
  Address: 10.0.10.1/24
  
[after these steps, everything should be pingable from everywhere else]

[static ip addressing in docker-compose; top level key]
networks:
  default:
    external:
      name: dockernet
  dockernet:
    external: true

services:
  traefik:
    image: "traefik:v2.5"
    networks:
      dockernet:
        ipv4_address: 10.0.10.250
    container_name: "traefik"

```

