# User Documentation

## Services

The stack provides a WordPress website through three containers:

- NGINX: HTTPS entry point on port 443.
- WordPress and PHP-FPM: website application.
- MariaDB: WordPress database.

## Start and Stop

From the repository root:

```bash
make
```

Stop the stack without deleting persistent data:

```bash
make down
```

## Access

Add the local domain to `/etc/hosts` if necessary:

```text
127.0.0.1 eduaserr.42.fr
```

Open the website at:

```text
https://eduaserr.42.fr
```

The administration panel is available at:

```text
https://eduaserr.42.fr/wp-admin
```

The certificate is self-signed, so the browser may display a warning.

## Credentials

Credentials are stored locally in `srcs/.env`. This file is not public and
must not be committed. The administrator username must not contain `admin` or
`administrator`.

## Checks

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs
curl -k -I https://eduaserr.42.fr
```

MariaDB should be `healthy`, and the HTTPS request should return a successful
HTTP response.
