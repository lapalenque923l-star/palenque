#!/bin/bash
# =============================================================================
# despliegue-joomla.sh - Script automático despliegue Joomla 5 + LAMP
# Autor: Luis Palenque Nalda
# Uso: chmod +x despliegue-joomla.sh && sudo ./despliegue-joomla.sh
# =============================================================================

set -e  # Salir en error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Configuración (personalizable)
DOMAIN="localhost"
JOOMLA_DB="joomla_db"
JOOMLA_USER="joomla_user"
JOOMLA_PASS="JoomlaPass123!"
MYSQL_ROOT_PASS="RootPass123!"
JOOMLA_VERSION="5.1"
DOCROOT="/var/www/joomla"

if [ "$EUID" -ne 0 ]; then
  error "Ejecuta con sudo: sudo ./despliegue-joomla.sh"
fi

log "Iniciando despliegue Joomla en $(hostname)..."

# 1. UPDATE sistema
log "1. Actualizando sistema..."
apt update && apt upgrade -y

# 2. Instalar LAMP + PHP extensions Joomla
log "2. Instalando Apache2, MariaDB, PHP..."
apt install -y apache2 mariadb-server mariadb-client \
  php php-mysql php-xml php-mbstring php-curl php-gd php-zip php-intl \
  php-apcu php-redis wget unzip

# 3. Configurar MariaDB
log "3. Configurando MariaDB..."
systemctl start mariadb
systemctl enable mariadb

mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root';"
mysql -e "CREATE USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASS';"
mysql -e "GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Crear DB y usuario Joomla
mysql -u root -p"$MYSQL_ROOT_PASS" -e "
CREATE DATABASE IF NOT EXISTS $JOOMLA_DB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$JOOMLA_USER'@'localhost' IDENTIFIED BY '$JOOMLA_PASS';
GRANT ALL ON $JOOMLA_DB.* TO '$JOOMLA_USER'@'localhost';
FLUSH PRIVILEGES;
"

# 4. Descargar Joomla
log "4. Descargando Joomla $JOOMLA_VERSION..."
cd /tmp
wget "https://github.com/joomla/joomla-cms/releases/download/$JOOMLA_VERSION.0/Joomla_$JOOMLA_VERSION.0-Stable-Full_Package.zip"
unzip -q "Joomla_$JOOMLA_VERSION.0-Stable-Full_Package.zip"

# 5. Configurar Apache
log "5. Configurando Apache VirtualHost..."
mkdir -p "$DOCROOT"
rsync -av /tmp/*/ "$DOCROOT/"
chown -R www-data:www-data "$DOCROOT"
chmod -R 755 "$DOCROOT"

cat > /etc/apache2/sites-available/joomla.conf << EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot $DOCROOT
    <Directory $DOCROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/joomla_error.log
    CustomLog \${APACHE_LOG_DIR}/joomla_access.log combined
</VirtualHost>
EOF

a2ensite joomla.conf
a2dissite 000-default.conf
a2enmod rewrite
systemctl restart apache2
systemctl enable apache2

# 6. Configuración de seguridad básica
log "6. Seguridad básica..."
mysql -u root -p"$MYSQL_ROOT_PASS" -e "UPDATE mysql.user SET plugin='' WHERE User='root';"
mysqladmin -u root -p"$MYSQL_ROOT_PASS" flush-privileges

# 7. Abrir navegador (opcional)
log "¡DESPLIEGUE COMPLETADO!"
log "Accede: http://$DOMAIN"
log "Admin Joomla: http://$DOMAIN/administrator"
log "DB: $JOOMLA_DB | User: $JOOMLA_USER | Pass: $JOOMLA_PASS"
log "MySQL Root: $MYSQL_ROOT_PASS"

echo -e "${GREEN}
PROXIMOS PASOS:
1. Completa instalación web en http://localhost
2. Borra /var/www/joomla/installation/
3. Configura tu dominio real
${NC}"

# Limpiar
rm -rf /tmp/Joomla_*.zip /tmp/*/
