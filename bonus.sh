# Progreso visual
progreso() {
  for i in {1..100}; do
    whiptail --gauge "Progreso $i%" 6 50 $i
    sleep 0.05
  done
}

# Backup automático
backup_joomla() {
  whiptail --yesno "¿Hacer backup antes?" && mysqldump -u root -pPass joomla_db > backup.sql
}

# Logs en tiempo real
tail -f /var/log/apache2/joomla_error.log | whiptail --tailbox 20 80
