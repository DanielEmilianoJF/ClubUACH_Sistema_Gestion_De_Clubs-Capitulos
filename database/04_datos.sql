-- ClubUACH - 04_datos.sql
-- Datos de ejemplo para probar y demostrar el sistema.
--
-- EJECUTAR COMO: clubuach (F5 en SQL Developer), al final.
--
-- Todos los usuarios de ejemplo tienen la contraseña:  clubuach123
--   Administrador (Presidente): admin@clubuach.mx
--   Miembro:                    miembro@clubuach.mx
SET DEFINE OFF;

-- Borra datos anteriores para poder volver a ejecutar el script
DELETE FROM constancia;
DELETE FROM pago;
DELETE FROM participacion_proyecto;
DELETE FROM proyecto;
DELETE FROM asistencia;
DELETE FROM evento;
DELETE FROM tipo_evento;
DELETE FROM miembro;
DELETE FROM rol;

-- Reinicia la numeración de los folios de constancia
ALTER SEQUENCE seq_folio_constancia RESTART START WITH 1;

-- Roles
INSERT INTO rol (id_rol, nombre, descripcion, es_directiva) VALUES (1, 'Presidente', 'Representa al capítulo y coordina a la mesa directiva', 1);
INSERT INTO rol (id_rol, nombre, descripcion, es_directiva) VALUES (2, 'Secretario', 'Lleva las minutas, la asistencia y las constancias', 1);
INSERT INTO rol (id_rol, nombre, descripcion, es_directiva) VALUES (3, 'Tesorero', 'Administra las cuotas y los pagos', 1);
INSERT INTO rol (id_rol, nombre, descripcion, es_directiva) VALUES (4, 'Staff', 'Apoya en la logística de los eventos', 0);
INSERT INTO rol (id_rol, nombre, descripcion, es_directiva) VALUES (5, 'Miembro', 'Integrante del capítulo', 0);

-- Miembros (contraseña de todos: clubuach123)
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (1, 'Daniel Emiliano', 'Jiménez Frade', 'admin@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 123 4567', '376976', 'Ingeniería en Ciencias de la Computación', 6, DATE '2025-01-20', 'ACTIVO', 1);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (2, 'Andrea', 'Domínguez Rodríguez', 'andrea.dominguez@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 234 5678', '374234', 'Ingeniería en Ciencias de la Computación', 6, DATE '2025-01-20', 'ACTIVO', 2);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (3, 'Luis Fernando', 'Chávez Ortega', 'luis.chavez@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 345 6789', '371120', 'Ingeniería en Sistemas Computacionales en Hardware', 7, DATE '2025-01-22', 'ACTIVO', 3);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (4, 'Mariana', 'Holguín Baeza', 'miembro@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 456 7890', '380451', 'Ingeniería en Ciencias de la Computación', 4, DATE '2025-08-18', 'ACTIVO', 5);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (5, 'Jorge Alberto', 'Rascón Villalobos', 'jorge.rascon@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 567 8901', '378302', 'Ingeniería en Software', 5, DATE '2025-08-18', 'ACTIVO', 4);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (6, 'Valeria', 'Sáenz Ochoa', 'valeria.saenz@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 678 9012', '382215', 'Ingeniería en Software', 3, DATE '2026-01-26', 'ACTIVO', 4);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (7, 'Carlos', 'Loya Armendáriz', 'carlos.loya@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 789 0123', '379840', 'Ingeniería en Ciencias de la Computación', 5, DATE '2025-08-20', 'ACTIVO', 5);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (8, 'Sofía', 'Terrazas Muñoz', 'sofia.terrazas@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 890 1234', '383377', 'Ingeniería Matemática', 3, DATE '2026-01-26', 'ACTIVO', 5);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (9, 'Diego', 'Prieto Gallegos', 'diego.prieto@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 901 2345', '381009', 'Ingeniería en Sistemas Computacionales en Hardware', 4, DATE '2025-08-25', 'ACTIVO', 5);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (10, 'Fernanda', 'Olivas Quezada', 'fernanda.olivas@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 012 3456', '384512', 'Ingeniería en Ciencias de la Computación', 2, DATE '2026-08-17', 'ACTIVO', 5);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (11, 'Ricardo', 'Ponce Estrada', 'ricardo.ponce@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 111 2233', '377654', 'Ingeniería en Software', 7, DATE '2025-01-22', 'ACTIVO', 5);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (12, 'Ximena', 'Carrasco Lozoya', 'ximena.carrasco@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 222 3344', '384990', 'Ingeniería Matemática', 2, DATE '2026-08-17', 'ACTIVO', 5);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (13, 'Emilio', 'Barraza Nevárez', 'emilio.barraza@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 333 4455', '375432', 'Ingeniería en Ciencias de la Computación', 8, DATE '2025-01-20', 'INACTIVO', 5);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (14, 'Paola', 'Rentería Soto', 'paola.renteria@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 444 5566', '382876', 'Ingeniería en Software', 3, DATE '2026-01-28', 'ACTIVO', 5);
INSERT INTO miembro (id_miembro, nombre, apellidos, correo, password_hash, telefono, matricula, carrera, semestre, fecha_ingreso, estatus, id_rol) VALUES
 (15, 'Andrés', 'Molinar Ibarra', 'andres.molinar@clubuach.mx', 'pbkdf2:sha256:1000000$klDZ0CIxlkFeBonX$e8c017431be1ff4020c02264799667c7269dd059c3f03b0b960c2f7567322b9b', '614 555 6677', '380123', 'Ingeniería en Sistemas Computacionales en Hardware', 4, DATE '2025-08-18', 'ACTIVO', 5);

-- Tipos de evento
INSERT INTO tipo_evento (id_tipo_evento, nombre) VALUES (1, 'Taller');
INSERT INTO tipo_evento (id_tipo_evento, nombre) VALUES (2, 'Plática');
INSERT INTO tipo_evento (id_tipo_evento, nombre) VALUES (3, 'Reunión');
INSERT INTO tipo_evento (id_tipo_evento, nombre) VALUES (4, 'Congreso');
INSERT INTO tipo_evento (id_tipo_evento, nombre) VALUES (5, 'Hackathon');

-- Eventos: semestre 2026-1, semestre 2026-2 y próximos eventos
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (1, 'Reunión de arranque 2026-1', 'Presentación de la mesa directiva y plan de trabajo del semestre.', DATE '2026-02-05', '13:00', '14:00', 'Sala de juntas, Facultad de Ingeniería', 40, 3, 1);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (2, 'Taller de Git y GitHub', 'Control de versiones desde cero: commits, ramas y pull requests.', DATE '2026-02-19', '16:00', '18:00', 'Laboratorio de Cómputo 3', 25, 1, 2);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (3, 'Plática: Mi primer empleo en tecnología', 'Egresados comparten cómo consiguieron su primer trabajo.', DATE '2026-03-12', '12:00', '13:30', 'Auditorio de la Facultad de Ingeniería', 80, 2, 5);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (4, 'Taller de SQL con Oracle', 'Consultas, JOINs y vistas sobre Oracle Database XE.', DATE '2026-04-09', '16:00', '18:30', 'Laboratorio de Cómputo 3', 25, 1, 1);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (5, 'Hackathon ClubUACH 2026', '24 horas para construir una solución para el campus.', DATE '2026-05-15', '09:00', '21:00', 'Edificio de Posgrado, Facultad de Ingeniería', 60, 5, 3);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (6, 'Reunión de arranque 2026-2', 'Bienvenida a nuevos miembros y calendario del semestre.', DATE '2026-08-20', '13:00', '14:00', 'Sala de juntas, Facultad de Ingeniería', 40, 3, 1);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (7, 'Taller de Python y Flask', 'Construye tu primera aplicación web con Python.', DATE '2026-09-10', '16:00', '18:00', 'Laboratorio de Cómputo 1', 25, 1, 2);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (8, 'Plática: Ciberseguridad para estudiantes', 'Buenas prácticas para proteger tus cuentas y proyectos.', DATE '2026-09-24', '12:00', '13:00', 'Auditorio de la Facultad de Ingeniería', 80, 2, 6);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (9, 'Congreso Regional de Computación', 'Viaje grupal al congreso regional con ponencias y talleres.', DATE '2026-10-15', '08:00', '18:00', 'Centro de Convenciones Chihuahua', 30, 4, 1);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (10, 'Taller de diseño web responsivo', 'HTML, CSS y Bootstrap 5 para que tu sitio se vea bien en el celular.', DATE '2026-11-05', '16:00', '18:00', 'Laboratorio de Cómputo 1', 25, 1, 5);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (11, 'Plática: Cómo preparar tu entrevista técnica', 'Reclutadores explican qué buscan en un becario.', DATE '2026-11-26', '12:00', '13:30', 'Auditorio de la Facultad de Ingeniería', 80, 2, 2);
INSERT INTO evento (id_evento, titulo, descripcion, fecha, hora_inicio, hora_fin, lugar, cupo, id_tipo_evento, id_responsable) VALUES
 (12, 'Reunión de cierre 2026-2', 'Resultados del semestre y elección de la nueva mesa directiva.', DATE '2026-12-03', '13:00', '14:30', 'Sala de juntas, Facultad de Ingeniería', 40, 3, 1);

-- Asistencia
-- Eventos pasados (1 a 10): cada miembro activo se registró a la
-- mayoría; la mayoría asistió y algunos faltaron.
-- Eventos próximos (11 y 12): solo registros.
BEGIN
    FOR e IN (SELECT id_evento, fecha FROM evento ORDER BY id_evento) LOOP
        FOR m IN (SELECT id_miembro, fecha_ingreso FROM miembro ORDER BY id_miembro) LOOP
            -- solo se registra si ya era miembro y con un patrón fijo
            IF m.fecha_ingreso <= e.fecha AND MOD(m.id_miembro + e.id_evento, 4) <> 0 THEN
                INSERT INTO asistencia (id_evento, id_miembro, fecha_registro, estatus)
                VALUES (e.id_evento, m.id_miembro, e.fecha - 3,
                        CASE
                            WHEN e.fecha > SYSDATE THEN 'REGISTRADO'
                            WHEN MOD(m.id_miembro * 7 + e.id_evento, 5) = 0 THEN 'FALTO'
                            ELSE 'ASISTIO'
                        END);
            END IF;
        END LOOP;
    END LOOP;
END;
/

-- Constancias: se emiten para los asistentes de los eventos pasados
-- (el trigger trg_constancia_folio genera el folio).
-- El evento 10 se deja sin constancias para demostrar la emisión
-- desde la aplicación.
INSERT INTO constancia (id_asistencia, fecha_emision)
SELECT a.id_asistencia, e.fecha + 2
  FROM asistencia a
  JOIN evento e ON e.id_evento = a.id_evento
 WHERE a.estatus = 'ASISTIO'
   AND e.id_evento <= 9
 ORDER BY e.fecha, a.id_miembro;

-- Proyectos
INSERT INTO proyecto (id_proyecto, titulo, descripcion, fecha_inicio, fecha_fin, estado, id_lider) VALUES
 (1, 'Sitio web del capítulo', 'Página oficial con eventos, galería y formulario de contacto.', DATE '2026-02-10', DATE '2026-05-30', 'TERMINADO', 2);
INSERT INTO proyecto (id_proyecto, titulo, descripcion, fecha_inicio, fecha_fin, estado, id_lider) VALUES
 (2, 'App de préstamo de material de laboratorio', 'Aplicación para apartar y devolver material del laboratorio.', DATE '2026-08-25', NULL, 'EN_CURSO', 1);
INSERT INTO proyecto (id_proyecto, titulo, descripcion, fecha_inicio, fecha_fin, estado, id_lider) VALUES
 (3, 'Tutorías de programación', 'Asesorías semanales para alumnos de primer semestre.', DATE '2026-09-01', DATE '2026-12-05', 'EN_CURSO', 7);
INSERT INTO proyecto (id_proyecto, titulo, descripcion, fecha_inicio, fecha_fin, estado, id_lider) VALUES
 (4, 'Robot seguidor de línea', 'Prototipo para el concurso estatal de robótica 2027.', DATE '2027-01-20', NULL, 'PLANEADO', 3);

INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (1, 2, 'Líder de proyecto');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (1, 4, 'Diseño de interfaz');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (1, 5, 'Desarrollo frontend');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (1, 11, 'Contenido y fotografía');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (2, 1, 'Líder de proyecto');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (2, 4, 'Desarrollo backend');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (2, 6, 'Base de datos');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (2, 9, 'Pruebas');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (2, 14, 'Desarrollo frontend');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (3, 7, 'Coordinador');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (3, 8, 'Tutora de matemáticas');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (3, 10, 'Tutora de Python');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (3, 12, 'Tutora de C');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (4, 3, 'Líder de proyecto');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (4, 9, 'Electrónica');
INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion) VALUES (4, 15, 'Programación del microcontrolador');

-- Pagos
-- Cuota 2026-1: la pagaron todos los que ya eran miembros.
-- Cuota 2026-2: varios todavía no la pagan (aparecen en "pagos pendientes").
INSERT INTO pago (id_miembro, concepto, monto, fecha_pago, metodo)
SELECT id_miembro, 'Cuota semestral 2026-1', 300, DATE '2026-02-02' + MOD(id_miembro * 3, 20),
       CASE MOD(id_miembro, 3) WHEN 0 THEN 'EFECTIVO' WHEN 1 THEN 'TRANSFERENCIA' ELSE 'TARJETA' END
  FROM miembro
 WHERE fecha_ingreso <= DATE '2026-02-15';

INSERT INTO pago (id_miembro, concepto, monto, fecha_pago, metodo)
SELECT id_miembro, 'Cuota semestral 2026-2', 300, DATE '2026-08-24' + MOD(id_miembro * 5, 30),
       CASE MOD(id_miembro, 3) WHEN 0 THEN 'EFECTIVO' WHEN 1 THEN 'TRANSFERENCIA' ELSE 'TARJETA' END
  FROM miembro
 WHERE estatus = 'ACTIVO'
   AND id_miembro NOT IN (7, 9, 12, 15);

INSERT INTO pago (id_miembro, concepto, monto, fecha_pago, metodo) VALUES (1, 'Inscripción Congreso Regional', 450, DATE '2026-10-01', 'TRANSFERENCIA');
INSERT INTO pago (id_miembro, concepto, monto, fecha_pago, metodo) VALUES (2, 'Inscripción Congreso Regional', 450, DATE '2026-10-02', 'TARJETA');
INSERT INTO pago (id_miembro, concepto, monto, fecha_pago, metodo) VALUES (4, 'Inscripción Congreso Regional', 450, DATE '2026-10-03', 'EFECTIVO');
INSERT INTO pago (id_miembro, concepto, monto, fecha_pago, metodo) VALUES (5, 'Playera del capítulo', 250, DATE '2026-09-05', 'EFECTIVO');
INSERT INTO pago (id_miembro, concepto, monto, fecha_pago, metodo) VALUES (8, 'Playera del capítulo', 250, DATE '2026-09-06', 'TRANSFERENCIA');
INSERT INTO pago (id_miembro, concepto, monto, fecha_pago, metodo) VALUES (11, 'Playera del capítulo', 250, DATE '2026-09-08', 'EFECTIVO');

-- Ajusta las columnas IDENTITY para que los siguientes registros que
-- cree la aplicación continúen después de los ids de ejemplo.
ALTER TABLE rol                    MODIFY id_rol           GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE);
ALTER TABLE miembro                MODIFY id_miembro       GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE);
ALTER TABLE tipo_evento            MODIFY id_tipo_evento   GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE);
ALTER TABLE evento                 MODIFY id_evento        GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE);
ALTER TABLE asistencia             MODIFY id_asistencia    GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE);
ALTER TABLE proyecto               MODIFY id_proyecto      GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE);
ALTER TABLE participacion_proyecto MODIFY id_participacion GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE);
ALTER TABLE pago                   MODIFY id_pago          GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE);
ALTER TABLE constancia             MODIFY id_constancia    GENERATED BY DEFAULT AS IDENTITY (START WITH LIMIT VALUE);

COMMIT;

-- Comprobación rápida: cuántos registros hay en cada tabla
SELECT 'rol' AS tabla, COUNT(*) AS registros FROM rol UNION ALL
SELECT 'miembro', COUNT(*) FROM miembro UNION ALL
SELECT 'tipo_evento', COUNT(*) FROM tipo_evento UNION ALL
SELECT 'evento', COUNT(*) FROM evento UNION ALL
SELECT 'asistencia', COUNT(*) FROM asistencia UNION ALL
SELECT 'proyecto', COUNT(*) FROM proyecto UNION ALL
SELECT 'participacion_proyecto', COUNT(*) FROM participacion_proyecto UNION ALL
SELECT 'pago', COUNT(*) FROM pago UNION ALL
SELECT 'constancia', COUNT(*) FROM constancia;
