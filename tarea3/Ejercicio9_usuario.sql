CREATE USER 'rrhh_consulta'@'localhost' IDENTIFIED BY 'RRHH2025';
GRANT SELECT ON jardineria.v_empleados_rrhh TO 'rrhh_consulta'@'localhost';
FLUSH PRIVILEGES;


