#!/bin/bash
mysqld --user=mysql &
sleep 3

if  ! mysql -e "USE ${DB_NAME};" 2>/dev/null;
then
    echo "Setting up the initial database..."
    
    # Set the root password (without initial authentication)
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
    
    # All subsequent commands use authentication
    mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root -p${DB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
    mysql -u root -p${DB_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"
    
    echo "Database successfully set up"
fi

mysqladmin -u root --password=${DB_ROOT_PASSWORD} shutdown

exec mysqld_safe --user=mysql