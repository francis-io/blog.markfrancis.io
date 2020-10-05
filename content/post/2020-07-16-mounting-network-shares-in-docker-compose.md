+++
title = "Mounting NFS or SAMBA/CIFS shares inside docker containers using Docker Compose"
date = "2019-07-16"
+++


I run some self hosted docker containers for personal use at home. These docker containers need a place to persist data when containers reboot. For a long time, I liked keeping different network services separate, so mounting network shares seemed like an obvious way to go about this, especially if you have a dedicated network storage device already.

You can mount NFS or SAMBA shares on the host machine you run docker containers from, but in my opinion it's much cleaner to define them directly in the docker-compose.yml file. It took some searching because this is not very documented, but you can do exactly this.


## Host requirements
* The packages needed for NFS shares. On Ubuntu this is `nfs-common`.
OR
* The packages you need for SAMBA/CIFS shares. On Ubuntu this is `cifs-utils`.



## Docker-compose.yml example for NFS

```
version: "3.7"

services:
  home-assistant:
  container_name: home-assistant
    image: homeassistant/home-assistant
    ports:
      - "8123:8123"
    volumes:
      - type: volume
        source: home-assistant-data
        target: /config
        volume:
          nocopy: true
    restart: always

volumes:
  home-assistant-data:
    driver_opts:
      type: "nfs"
      o: "addr=192.168.1.10,nolock,soft,rw"
      device: ":/tank/home-assistant-data"

```

## Docker-compose.yml example for SAMBA/CIFS

```
version: "3.7"

services:
  home-assistant:
  container_name: home-assistant
    image: homeassistant/home-assistant
    ports:
      - "8123:8123"
    volumes:
      - type: volume
        source: home-assistant-data
        target: /config
        volume:
          nocopy: true
    restart: always

volumes:
  home-assistant-data:
    driver_opts:
      type: "cifs"
      device: "//192.168.1.10/home-assistant-data"
      o: "addr=192.168.1.10,rw"
      o: "uid=0,username=samba-username,password=samba-password,file_mode=0770,dir_mode=0770"
```
