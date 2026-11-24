-- ClubUACH - 02_logica.sql
-- Lógica en PL/SQL: función de semestre, trigger que genera el folio de
-- cada constancia y procedimientos para registrar asistencia y emitir
-- constancias.
--
-- EJECUTAR COMO: clubuach (F5 en SQL Developer), después de 01_tablas.sql

-- fn_semestre: convierte una fecha en su semestre escolar.
--   enero a junio  -> '2026-1'
--   julio a diciembre -> '2026-2'
CREATE OR REPLACE FUNCTION fn_semestre (p_fecha IN DATE)
RETURN VARCHAR2 DETERMINISTIC
IS
BEGIN
    RETURN TO_CHAR(p_fecha, 'YYYY') || '-' ||
           CASE WHEN EXTRACT(MONTH FROM p_fecha) <= 6 THEN '1' ELSE '2' END;
END fn_semestre;
/

-- trg_constancia_folio: antes de insertar una constancia
--   1) verifica que la asistencia sea ASISTIO (no se dan constancias
--      a quien solo se registró o faltó);
--   2) genera el folio único CUACH-AAAA-NNNNN si no se envió uno.
CREATE OR REPLACE TRIGGER trg_constancia_folio
BEFORE INSERT ON constancia
FOR EACH ROW
DECLARE
    v_estatus asistencia.estatus%TYPE;
BEGIN
    SELECT estatus INTO v_estatus
      FROM asistencia
     WHERE id_asistencia = :NEW.id_asistencia;

    IF v_estatus <> 'ASISTIO' THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Solo se puede emitir constancia a miembros con asistencia confirmada.');
    END IF;

    IF :NEW.fecha_emision IS NULL THEN
        :NEW.fecha_emision := SYSDATE;
    END IF;

    IF :NEW.folio IS NULL THEN
        :NEW.folio := 'CUACH-' || TO_CHAR(:NEW.fecha_emision, 'YYYY') || '-' ||
                      LPAD(seq_folio_constancia.NEXTVAL, 5, '0');
    END IF;
END;
/

-- sp_registrar_asistencia: inscribe a un miembro en un evento
-- respetando el cupo del evento.
CREATE OR REPLACE PROCEDURE sp_registrar_asistencia (
    p_id_evento   IN  asistencia.id_evento%TYPE,
    p_id_miembro  IN  asistencia.id_miembro%TYPE,
    p_estatus     IN  asistencia.estatus%TYPE DEFAULT 'REGISTRADO'
)
IS
    v_cupo      evento.cupo%TYPE;
    v_inscritos NUMBER;
BEGIN
    -- FOR UPDATE bloquea el evento para que dos registros simultáneos
    -- no rebasen el cupo.
    SELECT cupo INTO v_cupo
      FROM evento
     WHERE id_evento = p_id_evento
       FOR UPDATE;

    SELECT COUNT(*) INTO v_inscritos
      FROM asistencia
     WHERE id_evento = p_id_evento;

    IF v_inscritos >= v_cupo THEN
        RAISE_APPLICATION_ERROR(-20002, 'El evento ya alcanzó su cupo máximo.');
    END IF;

    INSERT INTO asistencia (id_evento, id_miembro, estatus)
    VALUES (p_id_evento, p_id_miembro, p_estatus);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20003, 'El miembro ya está registrado en este evento.');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'El evento no existe.');
END sp_registrar_asistencia;
/

-- sp_emitir_constancias: emite constancia a todos los asistentes
-- confirmados de un evento que todavía no tienen una.
-- Devuelve en p_emitidas cuántas constancias se crearon.
CREATE OR REPLACE PROCEDURE sp_emitir_constancias (
    p_id_evento  IN  evento.id_evento%TYPE,
    p_emitidas   OUT NUMBER
)
IS
BEGIN
    INSERT INTO constancia (id_asistencia)
    SELECT a.id_asistencia
      FROM asistencia a
     WHERE a.id_evento = p_id_evento
       AND a.estatus = 'ASISTIO'
       AND NOT EXISTS (SELECT 1 FROM constancia c
                        WHERE c.id_asistencia = a.id_asistencia);
    p_emitidas := SQL%ROWCOUNT;
END sp_emitir_constancias;
/
