#!/bin/bash
mysqld --user=mysql &
sleep 3

if  ! mysql -e "USE ${DB_NAME};" 2>/dev/null;
then
    echo "Configurando base de datos inicial..."
    
    # Establecer contraseña de root (sin autenticación inicial)
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
    
    # Todos los comandos posteriores usan autenticación
    mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root -p${DB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
    mysql -u root -p${DB_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"
    
    echo "Base de datos configurada correctamente."
fi

mysqladmin -u root --password=${DB_ROOT_PASSWORD} shutdown

exec mysqld_safe --user=mysql