# more advanced routing documentation

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

