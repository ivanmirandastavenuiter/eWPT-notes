#!/bin/bash

# Start Metasploitable 2 services (MySQL, Apache, and the rest)
/bin/services.sh

# Wait for MySQL to accept connections (give up after ~60s)
for _ in $(seq 1 60); do
    mysqladmin -u root ping &>/dev/null && break
    sleep 1
done

# MySQL 5.0 root password (legacy hash). First boot: blank password; later boots
# (mysql_data volume persists): already 'root'.
SQL="USE mysql; UPDATE user SET Password = OLD_PASSWORD('root') WHERE User = 'root'; FLUSH PRIVILEGES;"
mysql -u root -e "$SQL" 2>/dev/null || mysql -u root -proot -e "$SQL" || echo "WARNING: could not set MySQL root password"

# Mutillidae: database 'owasp10' and password 'root'
CONFIG_FILE="/var/www/mutillidae/config.inc"
if [ -f "$CONFIG_FILE" ]; then
    sed -i "s/'metasploit'/'owasp10'/g" "$CONFIG_FILE"
    sed -i 's/"metasploit"/"owasp10"/g' "$CONFIG_FILE"
    sed -i "s/\$dbpass = '[^']*';/\$dbpass = 'root';/g" "$CONFIG_FILE"
fi

# DVWA: password 'root' (db_user is already root, db_database is already 'dvwa')
DVWA_CONFIG="/var/www/dvwa/config/config.inc.php"
if [ -f "$DVWA_CONFIG" ]; then
    sed -i "s/\(db_password' \] *= *\)'[^']*'/\1'root'/" "$DVWA_CONFIG"
fi

# Keep the container in the foreground; exit cleanly on docker stop
trap 'exit 0' TERM INT
tail -f /dev/null &
wait $!
