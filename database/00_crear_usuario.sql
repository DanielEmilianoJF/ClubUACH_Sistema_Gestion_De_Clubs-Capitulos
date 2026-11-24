-- ClubUACH - 00_crear_usuario.sql
-- Crea el usuario (esquema) CLUBUACH dentro de la base FREEPDB1.
--
-- EJECUTAR COMO: SYSTEM conectado a localhost:1521 / servicio FREEPDB1
-- (en SQL Developer: abrir este archivo y presionar F5 "Ejecutar script")

-- Si el usuario ya existe, lo borra junto con todos sus objetos.
BEGIN
    EXECUTE IMMEDIATE 'DROP USER clubuach CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN RAISE; END IF;  -- ORA-01918: el usuario no existe
END;
/

CREATE USER clubuach IDENTIFIED BY "ClubUach2026"
    DEFAULT TABLESPACE users
    QUOTA UNLIMITED ON users;

GRANT CREATE SESSION,
      CREATE TABLE,
      CREATE VIEW,
      CREATE SEQUENCE,
      CREATE TRIGGER,
      CREATE PROCEDURE
   TO clubuach;

-- Listo. Ahora crea una conexión nueva en SQL Developer:
--   Usuario: clubuach   Contraseña: ClubUach2026
--   Host: localhost   Puerto: 1521   Nombre del servicio: FREEPDB1
-- y con esa conexión ejecuta 01, 02, 03 y 04 en orden.
