-- ClubUACH - 03_vistas.sql
-- Vistas para los reportes de la mesa directiva.
--
-- EJECUTAR COMO: clubuach (F5 en SQL Developer), después de 02_logica.sql

-- Detalle de cada evento con su tipo, responsable y número de inscritos
-- (la usa la aplicación para listar eventos).
CREATE OR REPLACE VIEW v_evento_detalle AS
SELECT e.id_evento,
       e.titulo,
       e.descripcion,
       e.fecha,
       e.hora_inicio,
       e.hora_fin,
       e.lugar,
       e.cupo,
       fn_semestre(e.fecha)                     AS semestre,
       t.id_tipo_evento,
       t.nombre                                 AS tipo,
       m.id_miembro                             AS id_responsable,
       m.nombre || ' ' || m.apellidos           AS responsable,
       (SELECT COUNT(*) FROM asistencia a
         WHERE a.id_evento = e.id_evento)       AS inscritos,
       (SELECT COUNT(*) FROM asistencia a
         WHERE a.id_evento = e.id_evento
           AND a.estatus = 'ASISTIO')           AS asistentes
  FROM evento e
  JOIN tipo_evento t ON t.id_tipo_evento = e.id_tipo_evento
  JOIN miembro     m ON m.id_miembro     = e.id_responsable;

-- REPORTE 1: asistencia por miembro
CREATE OR REPLACE VIEW v_asistencia_miembro AS
SELECT m.id_miembro,
       m.nombre || ' ' || m.apellidos                              AS miembro,
       m.matricula,
       r.nombre                                                    AS rol,
       COUNT(a.id_asistencia)                                      AS eventos_registrados,
       COUNT(CASE WHEN a.estatus = 'ASISTIO' THEN 1 END)           AS asistencias,
       COUNT(CASE WHEN a.estatus = 'FALTO'   THEN 1 END)           AS faltas,
       CASE WHEN COUNT(CASE WHEN a.estatus IN ('ASISTIO','FALTO') THEN 1 END) = 0
            THEN 0
            ELSE ROUND(100 * COUNT(CASE WHEN a.estatus = 'ASISTIO' THEN 1 END)
                       / COUNT(CASE WHEN a.estatus IN ('ASISTIO','FALTO') THEN 1 END), 1)
       END                                                         AS porcentaje_asistencia
  FROM miembro m
  JOIN rol r             ON r.id_rol = m.id_rol
  LEFT JOIN asistencia a ON a.id_miembro = m.id_miembro
 GROUP BY m.id_miembro, m.nombre, m.apellidos, m.matricula, r.nombre;

-- REPORTE 2: eventos por semestre y tipo
CREATE OR REPLACE VIEW v_eventos_semestre AS
SELECT fn_semestre(e.fecha)                                  AS semestre,
       t.nombre                                              AS tipo,
       COUNT(DISTINCT e.id_evento)                           AS total_eventos,
       COUNT(CASE WHEN a.estatus = 'ASISTIO' THEN 1 END)     AS total_asistentes
  FROM evento e
  JOIN tipo_evento t     ON t.id_tipo_evento = e.id_tipo_evento
  LEFT JOIN asistencia a ON a.id_evento      = e.id_evento
 GROUP BY fn_semestre(e.fecha), t.nombre;

-- REPORTE 3: pagos pendientes
-- Miembros activos que no han pagado la cuota del semestre actual.
CREATE OR REPLACE VIEW v_pagos_pendientes AS
SELECT m.id_miembro,
       m.nombre || ' ' || m.apellidos   AS miembro,
       m.matricula,
       m.correo,
       m.telefono,
       fn_semestre(SYSDATE)             AS semestre,
       (SELECT MAX(p.fecha_pago) FROM pago p
         WHERE p.id_miembro = m.id_miembro
           AND p.concepto LIKE 'Cuota semestral%') AS ultima_cuota
  FROM miembro m
 WHERE m.estatus = 'ACTIVO'
   AND NOT EXISTS (SELECT 1 FROM pago p
                    WHERE p.id_miembro = m.id_miembro
                      AND p.concepto LIKE 'Cuota semestral%'
                      AND fn_semestre(p.fecha_pago) = fn_semestre(SYSDATE));

-- REPORTE 4: participación por proyecto
CREATE OR REPLACE VIEW v_participacion_proyecto AS
SELECT p.id_proyecto,
       p.titulo,
       p.estado,
       p.fecha_inicio,
       p.fecha_fin,
       l.nombre || ' ' || l.apellidos     AS lider,
       COUNT(pp.id_participacion)         AS participantes
  FROM proyecto p
  JOIN miembro l ON l.id_miembro = p.id_lider
  LEFT JOIN participacion_proyecto pp ON pp.id_proyecto = p.id_proyecto
 GROUP BY p.id_proyecto, p.titulo, p.estado, p.fecha_inicio, p.fecha_fin,
          l.nombre, l.apellidos;

-- Constancias con todos sus datos (para mostrarlas e imprimirlas)
CREATE OR REPLACE VIEW v_constancia_detalle AS
SELECT c.id_constancia,
       c.folio,
       c.fecha_emision,
       m.id_miembro,
       m.nombre || ' ' || m.apellidos   AS miembro,
       m.matricula,
       m.carrera,
       e.id_evento,
       e.titulo                         AS evento,
       e.fecha                          AS fecha_evento,
       t.nombre                         AS tipo_evento,
       e.lugar
  FROM constancia c
  JOIN asistencia a  ON a.id_asistencia  = c.id_asistencia
  JOIN miembro m     ON m.id_miembro     = a.id_miembro
  JOIN evento e      ON e.id_evento      = a.id_evento
  JOIN tipo_evento t ON t.id_tipo_evento = e.id_tipo_evento;
