+++
title = "Fully Self Hosted Bitwarden password manager, with Docker, Postgres and Traefik"
date = "2021-04-20"
+++

Recently LastPass changed it's free tier to only allow either browser of app access. This spurred me on to finish a fully self hosted setup. I have some servers sitting in my home running docker containers. This makes it easy to throw in additional containers, all behind a Traefik container that handles an SSL certificate.

You will want to populate a `.env` file with the used variables. This setup example will go to AWS Route 53 to validate domain ownership for SSL cert generation and will also dump the database daily to a specific location (with bonus cleanup). I would suggest you backup this dump and the Bitwarden persistent volume to somewhere remote. You will likely want to encrypt this, for obvious reasons!

This is the outcome of many hours of tweaking and troubleshooting. I hope this helps someone.

## Prerequisites

* A DNS record that matches the below example (`pass.{DOMAIN}`)and points to where ever you host this service.

```bash
version: "3.8"

services:
  traefik:
    image: "traefik:v2.3"
    container_name: "traefik"
    environment:
      - AWS_ACCESS_KEY_ID=${TRAEFIK_AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${TRAEFIK_AWS_SECRET_ACCESS_KEY}
      - AWS_REGION=${AWS_REGION}
      - AWS_HOSTED_ZONE_ID=${ROUTE53_HOSTED_ZONE_ID}
    command:
      - "--log=true"
      - "--log.level=INFO" # (Default: error) DEBUG, INFO, WARN, ERROR, FATAL, PANIC
      #- "--accessLog=true"
      - "--global.sendAnonymousUsage=true"
      #- "--api.insecure=true"
      #- "--api=true"
      #- "--api.dashboard=true"
      - "--providers.docker=true"
      - "--providers.docker.endpoint=unix:///var/run/docker.sock"
      - "--providers.docker.exposedbydefault=false"
      - "--entryPoints.http.address=:80"
      - "--entryPoints.https.address=:443"
      - "--entryPoints.traefik.address=:8080"
      - "--entrypoints.https.http.tls.certResolver=dns-route53"
      - "--entrypoints.public.http.tls.certResolver=dns-route53"
      - "--entrypoints.https.http.tls.domains[0].main=*.${DOMAIN}"
      - "--certificatesresolvers.dns-route53.acme.dnsChallenge=true"
      - "--certificatesResolvers.dns-route53.acme.dnsChallenge.provider=route53"
      #- "--certificatesResolvers.dns-route53.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory" # LetsEncrypt Staging Server
      - "--certificatesResolvers.dns-route53.acme.email=dns@${DOMAIN}"
      - "--certificatesResolvers.dns-route53.acme.storage=/letsencrypt/acme.json"
      - "--certificatesResolvers.dns-route53.acme.dnsChallenge.delayBeforeCheck=60"
      - "--certificatesResolvers.dns-route53.acme.dnsChallenge.resolvers=1.1.1.1:53,1.0.0.1:53"
    security_opt:
      - no-new-privileges:true
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "/etc/localtime:/etc/localtime:ro"
      - "/root/letsencrypt:/letsencrypt"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.rule=Host(`traefik.${DOMAIN}`)"
      - "traefik.http.services.traefik.loadbalancer.server.port=8080"
      - "traefik.http.routers.traefik.entryPoints=https"
      #- "traefik.http.routers.traefik.service=api@internal"
    restart: always

  bitwarden:
    image: "bitwardenrs/server:latest"
    container_name: "bitwarden"
    user: ${UID}:${GID}
    environment:
      DOMAIN: "https://pass.${DOMAIN}"
      DATABASE_URL: "postgresql://bitwarden:${BITWADEN_DB_PASSWORD}@bitwarden-postgres:5432/bitwarden"
      DATA_FOLDER: /data
      SIGNUPS_ALLOWED: "false"
      INVITATIONS_ALLOWED: "false"
      SHOW_PASSWORD_HINT: "false"
      ICON_BLACKLIST_NON_GLOBAL_IPS: "false"
      WEBSOCKET_ENABLED: "true" # Important for dynamic updates
      LOG_FILE: "/data/bitwarden.log"
      LOG_LEVEL: "info" # This is default, but setting it explicit
      EXTENDED_LOGGING: "true"
    volumes:
      - /tempvol/config-bitwarden:/data/ # Somewhere to persist data
      - /etc/localtime:/etc/localtime:ro
    security_opt:
      - no-new-privileges=true
    healthcheck:
      test: ["CMD", "curl", "-fL", "http://127.0.0.1:80"]
      interval: 2s
      timeout: 5s
      retries: 3
      start_period: 10s
    depends_on:
      - traefik
      - bitwarden-postgres
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.bitwarden.entrypoints=http"
      - "traefik.http.routers.bitwarden.rule=Host(`pass.${DOMAIN}`)"
      - "traefik.http.middlewares.bitwarden-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.bitwarden.middlewares=bitwarden-https-redirect"
      - "traefik.http.routers.bitwarden.service=bitwarden"
      - "traefik.http.services.bitwarden.loadbalancer.server.port=80"
      #
      - "traefik.http.routers.bitwarden-secure.entrypoints=https"
      - "traefik.http.routers.bitwarden-secure.rule=Host(`pass.${DOMAIN}`)"
      - "traefik.http.routers.bitwarden-secure.tls=true"
      - "traefik.http.routers.bitwarden-secure.tls.certresolver=dns-route53"
      - "traefik.http.routers.bitwarden-secure.service=bitwarden-secure"
      - "traefik.http.services.bitwarden-secure.loadbalancer.server.port=80"
      #
      - "traefik.http.routers.bitwarden-ws.entrypoints=https"
      - "traefik.http.routers.bitwarden-ws.rule=Host(`pass.${DOMAIN}`) && Path(`/notifications/hub`)"
      - "traefik.http.middlewares.bitwarden-ws-strip.stripprefix.prefixes=/notifications/hub"
      - "traefik.http.routers.bitwarden-ws.middlewares=bitwarden-ws-strip"
      - "traefik.http.routers.bitwarden-ws.tls=true"
      - "traefik.http.routers.bitwarden-ws.tls.certresolver=dns-route53"
      - "traefik.http.routers.bitwarden-ws.service=bitwarden-ws"
      - "traefik.http.services.bitwarden-ws.loadbalancer.server.port=3012"
    restart: always

  bitwarden-postgres:
    container_name: "bitwarden-postgres"
    image: "postgres:13-alpine"
    #user: ${UID}:${GID}
    environment:
      POSTGRES_USER: "bitwarden"
      POSTGRES_PASSWORD: "${BITWADEN_DB_PASSWORD}"
      POSTGRES_DB: "bitwarden"
    security_opt:
      - no-new-privileges:true
    volumes:
      - /tempvol/config-postgres-bitwarden:/var/lib/postgresql/data
      - /etc/localtime:/etc/localtime:ro
    restart: always

  bitwarden-postgres-backup:
    container_name: "bitwarden-postgres-backup"
    image: "postgres:13-alpine"
    environment:
      BACKUP_NUM_KEEP: 7
      BACKUP_FREQUENCY: "1d"
    volumes:
      - /tank/backups/databases/bitwarden:/dump
      - /etc/localtime:/etc/localtime:ro
    depends_on:
      - bitwarden-postgres
    entrypoint: |
      bash -c 'bash -s <<EOF
      trap "break;exit" SIGHUP SIGINT SIGTERM
      sleep 1s
      while /bin/true; do
        PGPASSWORD=${BITWADEN_DB_PASSWORD} pg_dump --host=bitwarden-postgres --username=bitwarden bitwarden | gzip -c > /dump/dump_\`date +%d-%m-%Y"_"%H_%M_%S\`.sql.gz
        (ls -t /dump/dump*.sql.gz|head -n $$BACKUP_NUM_KEEP;ls /dump/dump*.sql.gz)|sort|uniq -u|xargs rm -- {}
        sleep $$BACKUP_FREQUENCY
      done
      EOF'
    restart: always
```

