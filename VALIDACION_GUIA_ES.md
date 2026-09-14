# Guía rápida de validación y defensa para Inception (español)

Esta guía está pensada para que la ejecutes en tu máquina virtual antes de la evaluación. Te muestra los pasos más importantes, los comandos exactos y una explicación breve de lo que hace cada uno.

No hace falta ejecutar todo a la vez. Lo importante es demostrar que el proyecto funciona, que está bien montado y que sabes explicarlo.

---

## 1) Preparación inicial

### Paso 1: limpiar el entorno Docker

```bash
docker stop $(docker ps -qa)
docker rm $(docker ps -qa)
docker rmi -f $(docker images -qa)
docker volume rm $(docker volume ls -q)
docker network rm $(docker network ls -q) 2>/dev/null
```

Explicación:
- Detiene y elimina todos los contenedores activos.
- Borra imágenes, volúmenes y redes para dejar el sistema limpio.
- Es importante antes de empezar una validación nueva.

---

## 2) Comprobar que la estructura del proyecto es correcta

### Paso 2: listar archivos importantes

```bash
ls -al
ls -al srcs
find srcs -maxdepth 3 -type f | sort
```

Explicación:
- Comprueba que el repositorio tiene la estructura esperada.
- Debe haber `Makefile` en la raíz y `srcs/docker-compose.yml` dentro de `srcs`.
- Deben existir los Dockerfiles por servicio.

---

## 3) Verificar que no hay cosas prohibidas

### Paso 3: buscar elementos no permitidos

```bash
grep -RIn -- '--link\|network: host\|links:' srcs Makefile
grep -RIn -- 'tail -f\|sleep infinity\|while true' .
```

Explicación:
- `--link` y `network: host` están prohibidos.
- `tail -f`, `sleep infinity` y `while true` son trampas típicas y no deben aparecer.
- Si aparecen, el proyecto puede ser rechazado.

---

## 4) Verificar que el Makefile y Docker Compose están bien escritos

### Paso 4: revisar el Makefile

```bash
cat Makefile
```

Explicación:
- Debe existir en la raíz.
- Debe crear los directorios necesarios y levantar la pila con Docker Compose.

### Paso 5: revisar docker-compose

```bash
cat srcs/docker-compose.yml
```

Explicación:
- Debe haber una red Docker definida.
- Deben existir 3 servicios: `nginx`, `wordpress` y `mariadb`.
- Debe haber `ports: - "443:443"` para NGINX.
- Debe haber volúmenes persistentes y dependencias entre contenedores.

---

## 5) Levantar la infraestructura

### Paso 6: construir y arrancar los contenedores

```bash
make
```

Explicación:
- Ejecuta el `Makefile` para crear los directorios y levantar los servicios con `docker compose up -d --build`.
- Es el arranque principal del proyecto.

Si quieres comprobar el estado de arranque también puedes hacer:

```bash
docker compose -f srcs/docker-compose.yml ps
```

Explicación:
- Muestra si los contenedores están corriendo o fallando.
- Deben aparecer 3 contenedores activos.

---

## 6) Verificar que los servicios están funcionando

### Paso 7: ver logs de los servicios

```bash
docker compose -f srcs/docker-compose.yml logs
```

Explicación:
- Te ayuda a ver si hubo errores de arranque, conexión o configuración.
- Es útil para detectar si WordPress no termina de instalarse o MariaDB no está listo.

### Paso 8: revisar la red Docker

```bash
docker network ls
docker network inspect eduaserr_inception
```

Explicación:
- `docker network ls` confirma que existe la red del proyecto.
- `docker network inspect` muestra que los contenedores están conectados entre sí.

---

## 7) Verificar que NGINX solo sirve por HTTPS en el puerto 443

### Paso 9: comprobar si el puerto 80 no responde

```bash
curl -I http://eduaserr.42.fr
```

Explicación:
- Debe fallar o no abrir la página.
- El sitio debe estar accesible solamente por HTTPS, no por HTTP.

### Paso 10: comprobar HTTPS

```bash
curl -k -I https://eduaserr.42.fr
```

Explicación:
- `-k` ignora el certificado self-signed para poder comprobar la respuesta HTTPS.
- Debe devolver un resultado correcto dentro del sitio.

### Paso 11: comprobar TLS 1.2 y TLS 1.3

```bash
openssl s_client -connect localhost:443 -tls1_2
openssl s_client -connect localhost:443 -tls1_3
```

Explicación:
- Demuestra que la configuración usa TLSv1.2 o TLSv1.3.
- Si responde correctamente, el requisito está cubierto.

---

## 8) Verificar WordPress personalizado y que no salga la pantalla de instalación

### Paso 12: abrir la web en el navegador

```text
https://eduaserr.42.fr
https://eduaserr.42.fr/wp-admin
```

Explicación:
- La página principal debe mostrar tu sitio WordPress ya configurado.
- No debe aparecer la pantalla de instalación de WordPress.
- En `/wp-admin` debe abrir el panel de administración.

Si quieres revisar desde terminal también puedes mirar el contenido descargado:

```bash
docker exec -it wordpress ls -la /var/www/html
```

Explicación:
- Muestra que WordPress está instalado en el volumen del servicio `wordpress`.

---

## 9) Verificar la base de datos MariaDB

### Paso 13: comprobar que el contenedor está healthy

```bash
docker ps
```

Explicación:
- Debes ver que `mariadb` está en estado `healthy`.
- Si la base de datos está lista, esto suele aparecer correctamente.

### Paso 14: entrar en MariaDB

```bash
docker exec -it mariadb mariadb -u root -p
```

Explicación:
- Abre una sesión dentro del contenedor MariaDB.
- Te permite comprobar la base de datos del proyecto.

Dentro de MariaDB puedes probar:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

Explicación:
- Debe existir la base de datos `wordpress`.
- Deben existir las tablas de WordPress.
- Esto demuestra que la configuración de la base de datos quedó bien hecha.

---

## 10) Verificar volúmenes y persistencia

### Paso 15: listar los volúmenes

```bash
docker volume ls
docker volume inspect <nombre_del_volumen>
```

Explicación:
- `docker volume ls` lista los volúmenes del proyecto.
- `docker volume inspect` muestra en qué ruta del host están almacenados los datos.

En la práctica deberían verse rutas tipo:

```text
/home/<tu_usuario>/data/mariadb
/home/<tu_usuario>/data/wordpress
```

Explicación:
- Los datos persistentes de la base de datos y del sitio web deben guardarse fuera de los contenedores.
- Esto es importante para que no se pierdan tras un `make down` o reinicio del sistema.

---

## 11) Verificar que el proyecto admite reinicios sin perder datos

### Paso 16: parar la pila y volver a levantarla

```bash
make down
make
```

Explicación:
- `make down` corta los contenedores sin borrar los datos persistentes.
- `make` vuelve a levantarlos.
- Si WordPress y la base de datos siguen funcionando, la persistencia está bien hecha.

---

## 12) Preparación para la defensa oral

### Respuestas rápidas que debes saber decir

#### 1. ¿Qué es Docker?
> Docker permite ejecutar aplicaciones dentro de contenedores aislados, con su propio entorno y dependencias, sin necesidad de una máquina virtual completa.

#### 2. ¿Qué es Docker Compose?
> Es una herramienta que define y gestiona varios contenedores con una misma configuración, conectándolos con redes y volúmenes.

#### 3. ¿Por qué usar Docker frente a una máquina virtual?
> Las VMs emulan un sistema completo y consumen más recursos. Docker comparte el kernel del host y es más ligero, rápido y eficiente.

#### 4. ¿Qué diferencia hay entre imagen y contenedor?
> La imagen es la plantilla; el contenedor es la ejecución real de esa imagen.

#### 5. ¿Qué hace la red Docker?
> Permite que los servicios se conecten entre sí por nombre, como `wordpress` con `mariadb`.

#### 6. ¿Qué hace el volumen?
> Guarda datos fuera de los contenedores para que no se pierdan al reiniciar o borrar contenedores.

#### 7. ¿Qué muestra que WordPress está bien instalado?
> Que la web carga correctamente, no aparece la pantalla de instalación y el panel `/wp-admin` funciona.

#### 8. ¿Qué muestra que MariaDB está bien configurada?
> Que el contenedor está healthy y que la base de datos `wordpress` contiene tablas de WordPress.

---

## 13) Checklist mínimo para la evaluación

Si quieres una versión corta para no perderte, haz esta lista:

- [ ] `make` levanta la infraestructura
- [ ] `docker compose -f srcs/docker-compose.yml ps` muestra 3 contenedores
- [ ] `docker network inspect eduaserr_inception` muestra la red
- [ ] `curl -k -I https://eduaserr.42.fr` responde bien
- [ ] `curl -I http://eduaserr.42.fr` falla o no responde
- [ ] `openssl s_client -connect localhost:443 -tls1_2` funciona
- [ ] `openssl s_client -connect localhost:443 -tls1_3` funciona
- [ ] El sitio carga en `https://eduaserr.42.fr`
- [ ] `/wp-admin` abre el panel de administración
- [ ] `docker exec -it mariadb mariadb -u root -p` entra en MariaDB
- [ ] `SHOW DATABASES;` y `USE wordpress; SHOW TABLES;` muestran la base de datos

---

## 14) Resumen final

Si haces estas comprobaciones y puedes explicar cada una con una frase simple, estarás muy bien preparado para la evaluación.

Lo más importante no es ejecutar cien comandos, sino demostrar que:
- la aplicación arranca,
- el sitio está disponible por HTTPS,
- WordPress no está en instalación,
- MariaDB está funcionando,
- los datos persisten,
- y sabes explicar el porqué técnico de cada elemento.

Si necesitas, puedes usar esta guía como “guion de defensa” durante la entrevista. Es una versión simple, clara y práctica.
