#!/bin/bash
#===============================================================================
# despliegue-joomla-gui.sh - Script JOOMLA COMPLETO con WHIPTAIL GUI 
# Interfaz gráfica + Preparado para vídeo demo
# Autor: Luis Palenque Nalda| Uso: sudo ./despliegue-joomla-gui.sh
#===============================================================================

set -e

# ════════════════════════════════════════════════════════════════════════════
# COLORES Y FUNCIONES UTILIDADES
# ════════════════════════════════════════════════════════════════════════════
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

progreso() {
  local msg="$1"
  for i in {1..100}; do
    whiptail --title "$msg" --gauge "Progreso $i%" 8 60 $i 2>&1 1>/dev/null
    sleep 0.03
  done
}

# ════════════════════════════════════════════════════════════════════════════
# VERIFICACIONES INICIALES
# ════════════════════════════════════════════════════════════════════════════
if [ "$EUID" -ne 0 ]; then
  error "Ejecuta con sudo: sudo ./despliegue-joomla-gui.sh"
fi

if ! command -v whiptail &> /dev/null; then
  log "Instalando whiptail..."
  apt update && apt install -y whiptail
fi

# ════════════════════════════════════════════════════════════════════════════
# MENÚ PRINCIPAL WHIPTAIL
# ════════════════════════════════════════════════════════════════════════════
MENU_CHOICE=$(whiptail \
  --title "Despliegue Automático Joomla 5 + LAMP" \
  --backtitle "ASIR - Práctica Bash" \
  --menu "Selecciona operación:" 22 75 6 \
  "1)" "INSTALAR Joomla Completo (LAMP + DB + Web)" \
  "2)" "Solo Base de Datos MariaDB" \
  "3)" "Solo Apache + PHP" \
  "4)" "Configurar Dominio Personalizado" \
  "5)" "Ver Configuración Actual" \
  "6)" "Backup Joomla" \
  "0)" "Salir" \
  3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 1 ]; then
  whiptail --msgbox "¡Cancelado!" 8 40
  exit 0
fi

case $MENU_CHOICE in
  1) instalar_joomla_completo ;;
  2) configurar_db ;;
  3) instalar_webserver ;;
  4) configurar_dominio ;;
  5) mostrar_config ;;
  6) backup_joomla ;;
  0) whiptail --msgbox "¡Gracias por usar Despliegue Joomla!" 8 50; exit 0 ;;
esac

# ════════════════════════════════════════════════════════════════════════════
# FUNCIÓN 1: INSTALACIÓN COMPLETA JOOMLA (MENÚ 1)
# ════════════════════════════════════════════════════════════════════════════
instalar_joomla_completo() {
  # Recoger parámetros con inputbox
  DB_NAME=$(whiptail --inputbox "Nombre Base Datos:" 10 50 "joomla_$(date +%Y%m%d)" 3>&1 1>&2 2>&3)
  DB_USER=$(whiptail --inputbox "Usuario BD:" 10 50 "joomla_user" 3>&1 1>&2 2>&3)
  DB_PASS=$(whiptail --passwordbox "Contraseña BD (fuerte):" 10 50 3>&1 1>&2 2>&3)
  MYSQL_ROOT=$(whiptail --passwordbox "MySQL Root Password:" 10 50 3>&1 1>&2 2>&3)
  DOMINIO=$(whiptail --inputbox "Dominio (localhost):" 10 50 "localhost" 3>&1 1>&2 2>&3)
  JOOMLA_DIR="/var/www/$DOMINIO"

  if ! whiptail --yesno "¿Confirmar instalación?\n\nDB: $DB_NAME\nUser: $DB_USER\nDomain: $DOMINIO" 12 60; then
    return 1
  fi

  # 1. Update sistema
  (progreso "Actualizando sistema Ubuntu/Debian") &
  PID=$!; apt update -qq && apt upgrade -qq -y; kill $PID

  # 2. LAMP Stack
  (progreso "Instalando Apache2 + MariaDB + PHP 8.x") &
  PID=$!; apt install -y -qq apache2 mariadb-server wget unzip \
    php8.2 php8.2-mysql php8.2-xml php8.2-mbstring php8.2-curl \
    php8.2-gd php8.2-zip php8.2-intl php8.2-apcu; kill $PID

  systemctl enable --now apache2 mariadb &>/dev/null

  # 3. Secure MariaDB
  (progreso "Segurizando MariaDB...") &
  PID=$!; mysql -e "
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root';
  CREATE USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT';
  GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
  " &>/dev/null; kill $PID

  # 4. Joomla DB
  mysql -u root -p"$MYSQL_ROOT" -e "
  CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
  GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost';
  FLUSH PRIVILEGES;
  "

  # 5. Download Joomla 5.1
  cd /tmp
  (progreso "Descargando Joomla 5.1 oficial...") &
  PID=$!; wget -q "https://github.com/joomla/joomla-cms/releases/download/5.1.0/Joomla_5.1.0-Stable-Full_Package.zip"; kill $PID
  unzip -q "Joomla_5.1.0-Stable-Full_Package.zip"
  
  mkdir -p "$JOOMLA_DIR"
  rsync -a /tmp/joomla/ "$JOOMLA_DIR/"
  chown -R www-data:www-data "$JOOMLA_DIR"
  chmod -R 755 "$JOOMLA_DIR"

  # 6. Apache VirtualHost
  cat > /etc/apache2/sites-available/$DOMINIO.conf << EOF
<VirtualHost *:80>
    ServerName $DOMINIO
    DocumentRoot $JOOMLA_DIR
    <Directory $JOOMLA_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/$DOMINIO-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMINIO-access.log combined
</VirtualHost>
EOF

  a2ensite "$DOMINIO.conf"
  a2dissite 000-default.conf
  a2enmod rewrite
  systemctl reload apache2

  whiptail --msgbox "¡JOOMLA INSTALADO!\n\n Sitio: http://$DOMINIO\n Admin: http://$DOMINIO/administrator\n\n DB: $DB_NAME\n $DB_USER / $DB_PASS\n\n Borra installation/ tras configurar" 15 70
}

# ════════════════════════════════════════════════════════════════════════════
# OTRAS FUNCIONES (resumidas para brevedad)
# ════════════════════════════════════════════════════════════════════════════
configurar_db() {
  whiptail --msgbox "Función DB standalone - Implementar según necesidades" 10 50
}

instalar_webserver() {
  whiptail --msgbox "Solo LAMP stack sin Joomla - Implementar" 10 50
}

configurar_dominio() {
  whiptail --msgbox "Reconfigurar VirtualHost - Pendiente" 10 50
}

mostrar_config() {
  whiptail --textbox /etc/apache2/sites-available/000-default.conf 20 80
}

backup_joomla() {
  whiptail --msgbox "Backup automático - Implementar mysqldump" 10 50
}

# ════════════════════════════════════════════════════════════════════════════
# FIN - Volver al menú
# ════════════════════════════════════════════════════════════════════════════
whiptail --msgbox "Operación completada.\n Presiona Enter para volver al menú..." 10 60
exec "$0"  # Reinicia script (loop menú)
