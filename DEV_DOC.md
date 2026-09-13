# Developer Documentation

## Prerequisites

Use a Debian 12 virtual machine with Docker, Docker Compose V2, Git, and
Make installed. The project is designed to run without a graphical desktop.

Create `srcs/.env` before starting the stack. It contains the domain name,
database name and host, WordPress user values, and database passwords. Keep it
local and never commit it.

## Build and Launch

From the repository root, validate the Compose file:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml config
```

Build and start all services with the Makefile:

```bash
make
```

The Makefile creates the host data directories and runs:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

The images are built from the Dockerfiles in `srcs/requirements`. No NGINX,
WordPress, or MariaDB image is used as the base service image.

## Service Management

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f
docker compose -f srcs/docker-compose.yml restart
make down
```

Inspect the network and volumes with:

```bash
docker network inspect eduaserr_inception
docker volume ls
docker volume inspect srcs_db-volume
docker volume inspect srcs_wp-volume
```

## Persistence

The database volume stores MariaDB data in:

```text
/home/eduaserr/data/mariadb
```

The WordPress volume stores website files in:

```text
/home/eduaserr/data/wordpress
```

Removing containers with `make down` does not remove these directories. The
`fclean` target is destructive: it removes Docker resources and the data
directory. Use it only when a complete reset is intended.
