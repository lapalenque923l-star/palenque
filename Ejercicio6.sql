CREATE USER 'consulta_local'@'localhost' IDENTIFIED BY 'Consulta2025';
GRANT SELECT ON JARDINERIA.* TO 'consulta_local'@'localhost';
FLUSH PRIVILEGES;




