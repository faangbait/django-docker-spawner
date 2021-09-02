# more advanced django/microservices routing documentation

The goal of this documentation is to expand on the generic django spawner to provide multiple vlanned subnets. The goal is to establish Traefik as a reverse proxy to serve content out of multiple docker-compose stacks that can't speak to each other.

In a perfect world, the architecture of this would look similar to:

- A traefik proxy providing REST API and other frontend services for users
- Internal developer-oriented stacks that are still ip accessible from inside the LAN, but would NOT be accessible over Traefik. For instance, a HashiCorp vault for keeping secrets or certificate stores.
- Specific backend stacks to support each of the front-end microservices. For example, a compose file launching django, nginx, redis, postgres. This microservice compose stack would be entirely isolated from a second microservice compose stack, even if the second stack also was django/nginx/redis/postgres.

## Building out VLANs

I use an EdgeRouter Lite, which has vlans available in the interface. These vlans have to be built first.
```
Add VLAN Interface >
  VLAN_ID: 10
  Interface: eth2
  Address: 10.0.10.1/24

Add VLAN Interface >
  VLAN_ID: 20
  Interface: eth2
  Address: 10.0.20.1/24

Add VLAN Interface >
  VLAN_ID: 30
  Interface: eth2
  Address: 10.0.30.1/24

```

Prior to creating the docker networks, these vlans must be "real" to the server. 

```
#/etc/network/interfaces

auto eno2
allow-hotplug eno2
iface eno2 inet static
  address 10.0.0.250
  gateway 10.0.0.1
  netmask 255.255.255.0
  dns-nameservers 9.9.9.9 8.8.8.8
  pre-up ip link set dev $IFACE up
  pre-down ip link set dev $IFACE down
  
auto eno2.10
allow-hotplug eno2.10
iface eno2.10 inet static
  address 10.0.10.254
  netmask 255.255.255.0
  dns-nameservers 9.9.9.9 8.8.8.8
  vlan-raw-device eno2
  post-up echo 1 > /proc/sys/net/ipv4/ip_forward
  post-up iptables -t nat -A POSTROUTING -s '10.0.10.0/24' -o eno2 -j MASQUERADE
  post-down iptables -t nat -A POSTROUTING -s '10.0.10.0/24' -o eno2 -j MASQUERADE
  
auto eno2.20
allow-hotplug eno2.20
iface eno2.10 inet static
  address 10.0.20.254
  netmask 255.255.255.0
  dns-nameservers 9.9.9.9 8.8.8.8
  vlan-raw-device eno2
  post-up echo 1 > /proc/sys/net/ipv4/ip_forward
  post-up iptables -t nat -A POSTROUTING -s '10.0.20.0/24' -o eno2 -j MASQUERADE
  post-down iptables -t nat -A POSTROUTING -s '10.0.20.0/24' -o eno2 -j MASQUERADE
  
auto eno2.30
allow-hotplug eno2.30
iface eno2.10 inet static
  address 10.0.30.254
  netmask 255.255.255.0
  dns-nameservers 9.9.9.9 8.8.8.8
  vlan-raw-device eno2
  post-up echo 1 > /proc/sys/net/ipv4/ip_forward
  post-up iptables -t nat -A POSTROUTING -s '10.0.30.0/24' -o eno2 -j MASQUERADE
  post-down iptables -t nat -A POSTROUTING -s '10.0.30.0/24' -o eno2 -j MASQUERADE
  

```

Once the vlans are established, docker starts to not behave like a dick when you create networks for them.

```
docker network create -d ipvlan --subnet=10.0.10.0/24 --gateway=10.0.10.1 -o parent=eno2.10 frontend
docker network create -d ipvlan --subnet=10.0.20.0/24 --gateway=10.0.20.1 -o parent=eno2.20 backend
docker network create -d ipvlan --subnet=10.0.30.0/24 --gateway=10.0.30.1 -o parent=eno2.30 foobar-stack
```

For a compose stack like the .30 example, your compose.yml file might look like the following:

```
networks:
  default:
    external:
      name: foobar-stack
  foobar-stack:
    external: true

services:
  nginx:
    image: "whatever"
    networks:
      foobar-stack:
        ipv4_address: 10.0.30.10
  redis:
    image: "whatever"
    networks:
      foobar-stack:
        ipv4_address: 10.0.30.11

```

