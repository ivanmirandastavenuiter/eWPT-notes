#!/bin/bash

# 1. Arrancar los servicios internos de Metasploitable 2 (MySQL y Apache)
/bin/services.sh

# 2. Esperar a que MySQL responda por completo
until mysqladmin -u root ping &>/dev/null; do
    sleep 1
done

# 3. Aplicar la contraseña de root para MySQL 5.0
mysql -u root -e "USE mysql; UPDATE user SET Password = OLD_PASSWORD('root') WHERE User = 'root'; FLUSH PRIVILEGES;"

# 4. Configurar Mutillidae: base de datos 'owasp10' y contraseña 'root'
CONFIG_FILE="/var/www/mutillidae/config.inc"
if [ -f "$CONFIG_FILE" ]; then
    # Reemplazar 'metasploit' por 'owasp10' (cubriendo comillas simples y dobles)
    sed -i "s/'metasploit'/'owasp10'/g" "$CONFIG_FILE"
    sed -i 's/"metasploit"/"owasp10"/g' "$CONFIG_FILE"
    
    # Actualizar la contraseña de la base de datos
    sed -i "s/\$dbpass = '[^']*';/\$dbpass = 'root';/g" "$CONFIG_FILE"
fi

# 5. Mantener el contenedor vivo en primer plano
tail -f /dev/null