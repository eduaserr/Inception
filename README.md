*This project has been created as part of the 42 curriculum by eduaserr.*

# Description

Inception is a system administration project based on Docker. Its goal is to
build and run a small WordPress infrastructure in a Debian virtual machine,
using custom Dockerfiles and Docker Compose.

The infrastructure contains three dedicated services:

- NGINX: the only public entry point, serving HTTPS on port 443.
- WordPress with PHP-FPM: the website application, without NGINX.
- MariaDB: the WordPress database, without NGINX.

The services communicate through the private `eduaserr_inception` Docker
network. WordPress connects to MariaDB at `mariadb:3306`, while NGINX sends
PHP requests to `wordpress:9443`. Only port 443 is published on the host.

## Project Structure

```text
Inception/
|-- Makefile                         # Main build, start, stop and clean commands
|-- README.md                        # Project overview and technical choices
|-- USER_DOC.md                      # End-user and administrator instructions
|-- DEV_DOC.md                       # Developer setup and maintenance commands
`-- srcs/
	|-- .env                         # Local variables and credentials
	|-- docker-compose.yml           # Services, network, volumes and dependencies
	`-- requirements/
		|-- mariadb/
		|   |-- Dockerfile            # MariaDB image build
		|   |-- conf/mariadb.conf    # MariaDB server configuration
		|   `-- tools/mariadb.sh      # Database initialization and startup
		|-- nginx/
		|   |-- Dockerfile            # NGINX image and TLS certificate
		|   `-- conf/nginx.conf       # HTTPS and FastCGI configuration
		`-- wordpress/
			|-- Dockerfile            # PHP-FPM, WP-CLI and PHP extensions
			`-- tools/config.sh       # WordPress download and installation
```

This modular structure keeps image construction, service configuration and
startup logic separated by responsibility.

## Main Design Choices

### Virtual Machines and Docker

A virtual machine includes a complete guest operating system for each
instance. Docker containers share the host kernel, so they start faster and
use fewer resources. This project still runs inside a VM because the subject
requires it, and Docker runs the isolated services inside that VM.

### Secrets and Environment Variables

Docker secrets are preferable for confidential values because they avoid
placing passwords directly in configuration. This project uses the required
local `srcs/.env` file for variables and credentials. It must remain outside
the Git repository and is excluded from the build contexts with `.dockerignore`.

### Docker Network and Host Network

The user-defined `eduaserr_inception` bridge network lets containers resolve
each other by service name while keeping internal ports private. Host
networking would remove this isolation and is not used.

### Docker Volumes and Bind Mounts

Docker volumes keep data after containers are removed. The two named volumes
are backed by the required host paths:

```text
/home/eduaserr/data/mariadb
/home/eduaserr/data/wordpress
```

This keeps database data and website files persistent while the containers and
images remain replaceable.

# Instructions

## Prerequisites

Use a Debian 12 virtual machine without a graphical environment. Install
Docker, Docker Compose V2, Git and Make. Add the project domain to the local

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
```


### Instalación manual
Si el comando anterior no instala Docker Compose correctamente, añade el repositorio oficial de Docker.

```bash
sudo apt update && sudo apt install -y ca-certificates curl gnupg
```
Crea la carpeta para las claves:
sudo install -m 0755 -d /etc/apt/keyrings

Descarga la clave de Docker y repositorio de Debian oficial
```bash
sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" |
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Instala Docker y sus plugins:
```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
```
Inicia docker y añade al usuario al grupo docker
```bash
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```
reinicia o -> newgrp docker

Comprueba la instalación:
```bash
docker --version
docker compose version
```

Create `srcs/.env` with the values expected by `docker-compose.yml`. Keep the
file local and use an administrator username that does not contain `admin` or
`administrator`.

## Build and Run

From the repository root:

```bash
docker compose --env-file srcs/.env -f srcs/docker-compose.yml config
make
```

The Makefile creates the data directories and runs Docker Compose with
`--build`. Each service is built from its own Dockerfile; ready-made service
images are not used as the base images.

Stop the stack without deleting persistent data:

```bash
make down
```

For a complete reset, `make fclean` removes Docker resources and the data
directory. Use it only when the stored WordPress and MariaDB data may be
deleted.

# Checks

Run these commands after starting the stack:

```bash
docker compose -f srcs/docker-compose.yml ps
docker images
docker network inspect eduaserr_inception
docker volume ls
curl -k -I https://eduaserr.42.fr
```

The expected result is three running containers, MariaDB marked `healthy`, a
user-defined Docker network, two persistent volumes and an HTTPS response.
The website must not be available through HTTP port 80.

Check TLS explicitly:

```bash
openssl s_client -connect localhost:443 -tls1_2
openssl s_client -connect localhost:443 -tls1_3
```

Open the website at `https://eduaserr.42.fr` and the administration panel at
`https://eduaserr.42.fr/wp-admin`. The certificate is self-signed, so a browser
warning is expected. The WordPress installation page must not be displayed.

MariaDB can be checked with:

```bash
docker exec -it mariadb mariadb -u root -p
```

The `wordpress` database and its tables must exist. Changes made in WordPress
must remain after `make down`, a new `make` and a VM reboot.

# Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress developer documentation](https://developer.wordpress.org/)
- [MariaDB documentation](https://mariadb.com/docs/)
- [Debian documentation](https://www.debian.org/doc/)
- [42 Inception repository](https://github.com/eduaserr/42cursus)

AI was used to explain Docker and Docker Compose concepts, compare virtual
machines, networks, volumes and secrets, troubleshoot MariaDB and PHP-FPM
startup, review the Compose configuration, and prepare concise project
documentation. The implementation and final tests were performed by the
author.