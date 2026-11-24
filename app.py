# app.py
# ClubUACH - Sistema de Gestión de Capítulo Estudiantil
# Aplicación web hecha con Flask y Oracle Database.
#
# Para correrla:  python app.py   y abrir http://127.0.0.1:5000

import os
from datetime import datetime
from functools import wraps

import oracledb
from dotenv import load_dotenv
from flask import Flask, abort, flash, redirect, render_template, request, session, url_for
from werkzeug.security import check_password_hash, generate_password_hash

from db import conectar, consultar, consultar_uno, ejecutar, mensaje_error

load_dotenv()
app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "clave-de-desarrollo")

MESES = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]


# Filtros para las plantillas (cómo se muestran fechas y dinero)
@app.template_filter("fecha")
def formato_fecha(valor):
    """datetime(2026, 2, 5) -> '05 feb 2026'"""
    if not valor:
        return "—"
    return f"{valor.day:02d} {MESES[valor.month - 1]} {valor.year}"


@app.template_filter("iso")
def formato_iso(valor):
    """Fecha en formato AAAA-MM-DD, el que usan los <input type="date">"""
    if not valor:
        return ""
    if isinstance(valor, str):
        return valor
    return valor.strftime("%Y-%m-%d")


@app.template_filter("dinero")
def formato_dinero(valor):
    return f"${valor or 0:,.2f}"


@app.context_processor
def variables_globales():
    """Variables disponibles en todas las plantillas."""
    hoy = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    return {"hoy": hoy, "usuario": session.get("usuario")}


def leer_fecha(texto):
    """Convierte '2026-11-20' (lo que manda el formulario) a datetime."""
    return datetime.strptime(texto, "%Y-%m-%d") if texto else None


# Inicio de sesión y permisos
def login_requerido(funcion):
    """Solo deja pasar a usuarios que iniciaron sesión."""
    @wraps(funcion)
    def verificar(*args, **kwargs):
        if "usuario" not in session:
            return redirect(url_for("login"))
        return funcion(*args, **kwargs)
    return verificar


def solo_admin(funcion):
    """Solo deja pasar a la mesa directiva."""
    @wraps(funcion)
    def verificar(*args, **kwargs):
        if "usuario" not in session:
            return redirect(url_for("login"))
        if not session["usuario"]["es_admin"]:
            abort(403)
        return funcion(*args, **kwargs)
    return verificar


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        correo = request.form["correo"].strip().lower()
        password = request.form["password"]

        miembro = consultar_uno("""
            SELECT m.id_miembro, m.nombre, m.password_hash, m.estatus,
                   r.nombre AS rol, r.es_directiva
              FROM miembro m JOIN rol r ON r.id_rol = m.id_rol
             WHERE LOWER(m.correo) = :correo""", {"correo": correo})

        if miembro is None or not check_password_hash(miembro["password_hash"], password):
            flash("Correo o contraseña incorrectos.", "danger")
        elif miembro["estatus"] != "ACTIVO":
            flash("Tu cuenta está inactiva.", "warning")
        else:
            session["usuario"] = {
                "id": miembro["id_miembro"],
                "nombre": miembro["nombre"],
                "rol": miembro["rol"],
                "es_admin": miembro["es_directiva"] == 1,
            }
            return redirect(url_for("inicio"))

    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


# Inicio (mesa directiva) y perfil (miembro)
@app.route("/")
@login_requerido
def inicio():
    # Un miembro normal va directo a su perfil
    if not session["usuario"]["es_admin"]:
        return redirect(url_for("mi_perfil"))

    datos = consultar_uno("""
        SELECT (SELECT COUNT(*) FROM miembro WHERE estatus = 'ACTIVO') AS miembros,
               (SELECT COUNT(*) FROM evento
                 WHERE fn_semestre(fecha) = fn_semestre(SYSDATE))     AS eventos,
               (SELECT COUNT(*) FROM constancia)                      AS constancias,
               (SELECT COUNT(*) FROM v_pagos_pendientes)              AS pendientes,
               fn_semestre(SYSDATE)                                   AS semestre
          FROM dual""")
    proximos = consultar("""
        SELECT * FROM v_evento_detalle
         WHERE fecha >= TRUNC(SYSDATE)
         ORDER BY fecha""")
    return render_template("inicio.html", datos=datos, proximos=proximos)


def datos_del_miembro(id_miembro):
    """Junta todo lo de un miembro: datos, eventos, proyectos y pagos.
    Se usa en 'Mi perfil' y en el detalle que ve la mesa directiva."""
    miembro = consultar_uno("""
        SELECT m.*, r.nombre AS rol
          FROM miembro m JOIN rol r ON r.id_rol = m.id_rol
         WHERE m.id_miembro = :id""", {"id": id_miembro})
    eventos = consultar("""
        SELECT e.id_evento, e.titulo, e.fecha, a.estatus, c.folio
          FROM asistencia a
          JOIN evento e ON e.id_evento = a.id_evento
          LEFT JOIN constancia c ON c.id_asistencia = a.id_asistencia
         WHERE a.id_miembro = :id
         ORDER BY e.fecha DESC""", {"id": id_miembro})
    proyectos = consultar("""
        SELECT p.id_proyecto, p.titulo, p.estado, pp.funcion
          FROM participacion_proyecto pp
          JOIN proyecto p ON p.id_proyecto = pp.id_proyecto
         WHERE pp.id_miembro = :id""", {"id": id_miembro})
    pagos = consultar("""
        SELECT concepto, monto, fecha_pago, metodo
          FROM pago WHERE id_miembro = :id
         ORDER BY fecha_pago DESC""", {"id": id_miembro})
    asistencia = consultar_uno(
        "SELECT * FROM v_asistencia_miembro WHERE id_miembro = :id", {"id": id_miembro})
    debe_cuota = consultar_uno(
        "SELECT 1 AS si FROM v_pagos_pendientes WHERE id_miembro = :id", {"id": id_miembro})
    return dict(miembro=miembro, eventos=eventos, proyectos=proyectos, pagos=pagos,
                asistencia=asistencia, debe_cuota=debe_cuota is not None)


@app.route("/mi-perfil")
@login_requerido
def mi_perfil():
    datos = datos_del_miembro(session["usuario"]["id"])
    return render_template("perfil.html", es_mi_perfil=True, **datos)


# Miembros
ROLES_SQL = "SELECT id_rol, nombre FROM rol ORDER BY id_rol"


@app.route("/miembros")
@solo_admin
def miembros():
    buscar = request.args.get("buscar", "").strip()
    lista = consultar("""
        SELECT m.id_miembro, m.nombre, m.apellidos, m.correo, m.matricula,
               m.carrera, m.semestre, m.estatus, r.nombre AS rol
          FROM miembro m JOIN rol r ON r.id_rol = m.id_rol
         WHERE UPPER(m.nombre || ' ' || m.apellidos || ' ' || m.matricula)
               LIKE '%' || UPPER(:buscar) || '%'
         ORDER BY m.apellidos""", {"buscar": buscar})
    return render_template("miembros.html", miembros=lista, buscar=buscar)


@app.route("/miembros/<int:id_miembro>")
@solo_admin
def miembro_detalle(id_miembro):
    datos = datos_del_miembro(id_miembro)
    if datos["miembro"] is None:
        abort(404)
    return render_template("perfil.html", es_mi_perfil=False, **datos)


def datos_formulario_miembro():
    """Lee los campos del formulario de miembro."""
    f = request.form
    return {
        "nombre": f["nombre"].strip(),
        "apellidos": f["apellidos"].strip(),
        "correo": f["correo"].strip().lower(),
        "telefono": f["telefono"].strip(),
        "matricula": f["matricula"].strip(),
        "carrera": f["carrera"].strip(),
        "semestre": int(f["semestre"]),
        "fecha_ingreso": leer_fecha(f["fecha_ingreso"]) or datetime.now(),
        "estatus": f["estatus"],
        "id_rol": int(f["id_rol"]),
    }


@app.route("/miembros/nuevo", methods=["GET", "POST"])
@solo_admin
def miembro_nuevo():
    if request.method == "POST":
        datos = datos_formulario_miembro()
        datos["password_hash"] = generate_password_hash(request.form["password"])
        try:
            ejecutar("""
                INSERT INTO miembro (nombre, apellidos, correo, password_hash, telefono,
                                     matricula, carrera, semestre, fecha_ingreso, estatus, id_rol)
                VALUES (:nombre, :apellidos, :correo, :password_hash, :telefono,
                        :matricula, :carrera, :semestre, :fecha_ingreso, :estatus, :id_rol)""", datos)
            flash("Miembro registrado.", "success")
            return redirect(url_for("miembros"))
        except oracledb.DatabaseError as e:
            flash(mensaje_error(e), "danger")
    return render_template("miembro_form.html", m=request.form, roles=consultar(ROLES_SQL), nuevo=True)


@app.route("/miembros/<int:id_miembro>/editar", methods=["GET", "POST"])
@solo_admin
def miembro_editar(id_miembro):
    if request.method == "POST":
        datos = datos_formulario_miembro()
        datos["id"] = id_miembro
        try:
            ejecutar("""
                UPDATE miembro
                   SET nombre = :nombre, apellidos = :apellidos, correo = :correo,
                       telefono = :telefono, matricula = :matricula, carrera = :carrera,
                       semestre = :semestre, fecha_ingreso = :fecha_ingreso,
                       estatus = :estatus, id_rol = :id_rol
                 WHERE id_miembro = :id""", datos)
            # La contraseña solo se cambia si escribieron una nueva
            if request.form["password"]:
                ejecutar("UPDATE miembro SET password_hash = :h WHERE id_miembro = :id",
                         {"h": generate_password_hash(request.form["password"]), "id": id_miembro})
            flash("Datos actualizados.", "success")
            return redirect(url_for("miembro_detalle", id_miembro=id_miembro))
        except oracledb.DatabaseError as e:
            flash(mensaje_error(e), "danger")

    miembro = consultar_uno("SELECT * FROM miembro WHERE id_miembro = :id", {"id": id_miembro})
    return render_template("miembro_form.html", m=miembro, roles=consultar(ROLES_SQL),
                           nuevo=False, id_miembro=id_miembro)


@app.route("/miembros/<int:id_miembro>/estatus", methods=["POST"])
@solo_admin
def miembro_estatus(id_miembro):
    """Da de baja o reactiva a un miembro."""
    ejecutar("""
        UPDATE miembro
           SET estatus = CASE estatus WHEN 'ACTIVO' THEN 'INACTIVO' ELSE 'ACTIVO' END
         WHERE id_miembro = :id""", {"id": id_miembro})
    return redirect(url_for("miembro_detalle", id_miembro=id_miembro))


# Eventos y asistencia
@app.route("/eventos")
@login_requerido
def eventos():
    semestre = request.args.get("semestre", "")
    lista = consultar("""
        SELECT * FROM v_evento_detalle
         WHERE :semestre IS NULL OR semestre = :semestre
         ORDER BY fecha DESC""", {"semestre": semestre or None})
    semestres = consultar("SELECT DISTINCT fn_semestre(fecha) AS s FROM evento ORDER BY 1 DESC")
    return render_template("eventos.html", eventos=lista, semestres=semestres, semestre=semestre)


@app.route("/eventos/<int:id_evento>")
@login_requerido
def evento_detalle(id_evento):
    evento = consultar_uno("SELECT * FROM v_evento_detalle WHERE id_evento = :id", {"id": id_evento})
    if evento is None:
        abort(404)

    # Lista de asistencia (con su constancia, si ya tiene)
    asistentes = consultar("""
        SELECT a.id_asistencia, a.estatus, m.id_miembro,
               m.nombre || ' ' || m.apellidos AS miembro, m.matricula, c.folio
          FROM asistencia a
          JOIN miembro m ON m.id_miembro = a.id_miembro
          LEFT JOIN constancia c ON c.id_asistencia = a.id_asistencia
         WHERE a.id_evento = :id
         ORDER BY m.apellidos""", {"id": id_evento})

    # Miembros activos que todavía no están registrados en este evento
    disponibles = consultar("""
        SELECT id_miembro, nombre || ' ' || apellidos AS miembro
          FROM miembro m
         WHERE estatus = 'ACTIVO'
           AND id_miembro NOT IN (SELECT id_miembro FROM asistencia WHERE id_evento = :id)
         ORDER BY apellidos""", {"id": id_evento})

    # ¿El usuario que está viendo la página ya está registrado?
    mi_registro = next((a for a in asistentes if a["id_miembro"] == session["usuario"]["id"]), None)

    return render_template("evento_detalle.html", e=evento, asistentes=asistentes,
                           disponibles=disponibles, mi_registro=mi_registro)


def datos_formulario_evento():
    f = request.form
    return {
        "titulo": f["titulo"].strip(),
        "descripcion": f["descripcion"].strip(),
        "fecha": leer_fecha(f["fecha"]),
        "hora_inicio": f["hora_inicio"],
        "hora_fin": f["hora_fin"],
        "lugar": f["lugar"].strip(),
        "cupo": int(f["cupo"]),
        "id_tipo_evento": int(f["id_tipo_evento"]),
        "id_responsable": int(f["id_responsable"]),
    }


def catalogos_evento():
    tipos = consultar("SELECT id_tipo_evento, nombre FROM tipo_evento ORDER BY nombre")
    responsables = consultar("""
        SELECT id_miembro, nombre || ' ' || apellidos AS nombre
          FROM miembro WHERE estatus = 'ACTIVO' ORDER BY apellidos""")
    return tipos, responsables


@app.route("/eventos/nuevo", methods=["GET", "POST"])
@solo_admin
def evento_nuevo():
    if request.method == "POST":
        try:
            ejecutar("""
                INSERT INTO evento (titulo, descripcion, fecha, hora_inicio, hora_fin,
                                    lugar, cupo, id_tipo_evento, id_responsable)
                VALUES (:titulo, :descripcion, :fecha, :hora_inicio, :hora_fin,
                        :lugar, :cupo, :id_tipo_evento, :id_responsable)""", datos_formulario_evento())
            flash("Evento creado.", "success")
            return redirect(url_for("eventos"))
        except oracledb.DatabaseError as e:
            flash(mensaje_error(e), "danger")
    tipos, responsables = catalogos_evento()
    return render_template("evento_form.html", e=request.form, tipos=tipos,
                           responsables=responsables, nuevo=True)


@app.route("/eventos/<int:id_evento>/editar", methods=["GET", "POST"])
@solo_admin
def evento_editar(id_evento):
    if request.method == "POST":
        datos = datos_formulario_evento()
        datos["id"] = id_evento
        try:
            ejecutar("""
                UPDATE evento
                   SET titulo = :titulo, descripcion = :descripcion, fecha = :fecha,
                       hora_inicio = :hora_inicio, hora_fin = :hora_fin, lugar = :lugar,
                       cupo = :cupo, id_tipo_evento = :id_tipo_evento,
                       id_responsable = :id_responsable
                 WHERE id_evento = :id""", datos)
            flash("Evento actualizado.", "success")
            return redirect(url_for("evento_detalle", id_evento=id_evento))
        except oracledb.DatabaseError as e:
            flash(mensaje_error(e), "danger")
    evento = consultar_uno("SELECT * FROM evento WHERE id_evento = :id", {"id": id_evento})
    tipos, responsables = catalogos_evento()
    return render_template("evento_form.html", e=evento, tipos=tipos,
                           responsables=responsables, nuevo=False, id_evento=id_evento)


@app.route("/eventos/<int:id_evento>/eliminar", methods=["POST"])
@solo_admin
def evento_eliminar(id_evento):
    ejecutar("DELETE FROM evento WHERE id_evento = :id", {"id": id_evento})
    flash("Evento eliminado.", "success")
    return redirect(url_for("eventos"))


@app.route("/eventos/<int:id_evento>/registrar", methods=["POST"])
@login_requerido
def asistencia_registrar(id_evento):
    """Registra a un miembro en el evento usando el procedimiento
    sp_registrar_asistencia, que revisa el cupo en la base de datos.
    - Un miembro se registra a sí mismo.
    - La mesa directiva puede registrar a cualquiera."""
    if session["usuario"]["es_admin"] and "id_miembro" in request.form:
        id_miembro = int(request.form["id_miembro"])
        estatus = request.form["estatus"]
    else:
        id_miembro = session["usuario"]["id"]
        estatus = "REGISTRADO"
    try:
        with conectar() as conexion:
            conexion.cursor().callproc("sp_registrar_asistencia", [id_evento, id_miembro, estatus])
            conexion.commit()
        flash("Registro guardado.", "success")
    except oracledb.DatabaseError as e:
        flash(mensaje_error(e), "danger")
    return redirect(url_for("evento_detalle", id_evento=id_evento))


@app.route("/eventos/<int:id_evento>/pase-de-lista", methods=["POST"])
@solo_admin
def pase_de_lista(id_evento):
    """Guarda si cada persona asistió o faltó.
    El formulario manda un campo 'estatus_<id_asistencia>' por persona."""
    for campo, estatus in request.form.items():
        if campo.startswith("estatus_"):
            id_asistencia = int(campo.replace("estatus_", ""))
            ejecutar("""
                UPDATE asistencia SET estatus = :estatus
                 WHERE id_asistencia = :id
                   AND id_asistencia NOT IN (SELECT id_asistencia FROM constancia)""",
                     {"estatus": estatus, "id": id_asistencia})
    flash("Pase de lista guardado.", "success")
    return redirect(url_for("evento_detalle", id_evento=id_evento))


@app.route("/eventos/<int:id_evento>/constancias", methods=["POST"])
@solo_admin
def constancias_emitir(id_evento):
    """Llama al procedimiento sp_emitir_constancias. El trigger
    trg_constancia_folio genera el folio de cada constancia."""
    with conectar() as conexion:
        cursor = conexion.cursor()
        emitidas = cursor.var(int)
        cursor.callproc("sp_emitir_constancias", [id_evento, emitidas])
        conexion.commit()
    flash(f"Se emitieron {emitidas.getvalue()} constancias.", "success")
    return redirect(url_for("evento_detalle", id_evento=id_evento))


# Proyectos
ESTADOS = ["PLANEADO", "EN_CURSO", "TERMINADO", "CANCELADO"]
MIEMBROS_ACTIVOS_SQL = """
    SELECT id_miembro, nombre || ' ' || apellidos AS nombre
      FROM miembro WHERE estatus = 'ACTIVO' ORDER BY apellidos"""


@app.route("/proyectos")
@login_requerido
def proyectos():
    lista = consultar("""
        SELECT v.*, p.descripcion
          FROM v_participacion_proyecto v
          JOIN proyecto p ON p.id_proyecto = v.id_proyecto
         ORDER BY v.fecha_inicio DESC""")
    return render_template("proyectos.html", proyectos=lista)


@app.route("/proyectos/<int:id_proyecto>")
@login_requerido
def proyecto_detalle(id_proyecto):
    proyecto = consultar_uno("""
        SELECT p.*, m.nombre || ' ' || m.apellidos AS lider
          FROM proyecto p JOIN miembro m ON m.id_miembro = p.id_lider
         WHERE p.id_proyecto = :id""", {"id": id_proyecto})
    if proyecto is None:
        abort(404)
    participantes = consultar("""
        SELECT pp.id_participacion, pp.funcion, m.nombre || ' ' || m.apellidos AS miembro
          FROM participacion_proyecto pp
          JOIN miembro m ON m.id_miembro = pp.id_miembro
         WHERE pp.id_proyecto = :id""", {"id": id_proyecto})
    return render_template("proyecto_detalle.html", p=proyecto, participantes=participantes,
                           miembros=consultar(MIEMBROS_ACTIVOS_SQL))


def datos_formulario_proyecto():
    f = request.form
    return {
        "titulo": f["titulo"].strip(),
        "descripcion": f["descripcion"].strip(),
        "fecha_inicio": leer_fecha(f["fecha_inicio"]),
        "fecha_fin": leer_fecha(f["fecha_fin"]),
        "estado": f["estado"],
        "id_lider": int(f["id_lider"]),
    }


@app.route("/proyectos/nuevo", methods=["GET", "POST"])
@solo_admin
def proyecto_nuevo():
    if request.method == "POST":
        try:
            ejecutar("""
                INSERT INTO proyecto (titulo, descripcion, fecha_inicio, fecha_fin, estado, id_lider)
                VALUES (:titulo, :descripcion, :fecha_inicio, :fecha_fin, :estado, :id_lider)""",
                     datos_formulario_proyecto())
            flash("Proyecto creado.", "success")
            return redirect(url_for("proyectos"))
        except oracledb.DatabaseError as e:
            flash(mensaje_error(e), "danger")
    return render_template("proyecto_form.html", p=request.form, lideres=consultar(MIEMBROS_ACTIVOS_SQL),
                           estados=ESTADOS, nuevo=True)


@app.route("/proyectos/<int:id_proyecto>/editar", methods=["GET", "POST"])
@solo_admin
def proyecto_editar(id_proyecto):
    if request.method == "POST":
        datos = datos_formulario_proyecto()
        datos["id"] = id_proyecto
        try:
            ejecutar("""
                UPDATE proyecto
                   SET titulo = :titulo, descripcion = :descripcion, fecha_inicio = :fecha_inicio,
                       fecha_fin = :fecha_fin, estado = :estado, id_lider = :id_lider
                 WHERE id_proyecto = :id""", datos)
            flash("Proyecto actualizado.", "success")
            return redirect(url_for("proyecto_detalle", id_proyecto=id_proyecto))
        except oracledb.DatabaseError as e:
            flash(mensaje_error(e), "danger")
    proyecto = consultar_uno("SELECT * FROM proyecto WHERE id_proyecto = :id", {"id": id_proyecto})
    return render_template("proyecto_form.html", p=proyecto, lideres=consultar(MIEMBROS_ACTIVOS_SQL),
                           estados=ESTADOS, nuevo=False, id_proyecto=id_proyecto)


@app.route("/proyectos/<int:id_proyecto>/participantes", methods=["POST"])
@solo_admin
def participante_agregar(id_proyecto):
    try:
        ejecutar("""
            INSERT INTO participacion_proyecto (id_proyecto, id_miembro, funcion)
            VALUES (:proyecto, :miembro, :funcion)""",
                 {"proyecto": id_proyecto, "miembro": int(request.form["id_miembro"]),
                  "funcion": request.form["funcion"].strip() or "Colaborador"})
        flash("Participante agregado.", "success")
    except oracledb.DatabaseError as e:
        flash(mensaje_error(e), "danger")
    return redirect(url_for("proyecto_detalle", id_proyecto=id_proyecto))


@app.route("/participaciones/<int:id_participacion>/quitar", methods=["POST"])
@solo_admin
def participante_quitar(id_participacion):
    ejecutar("DELETE FROM participacion_proyecto WHERE id_participacion = :id", {"id": id_participacion})
    return redirect(url_for("proyecto_detalle", id_proyecto=request.form["id_proyecto"]))


# Pagos
@app.route("/pagos", methods=["GET", "POST"])
@solo_admin
def pagos():
    if request.method == "POST":
        try:
            ejecutar("""
                INSERT INTO pago (id_miembro, concepto, monto, fecha_pago, metodo)
                VALUES (:id_miembro, :concepto, :monto, :fecha_pago, :metodo)""", {
                "id_miembro": int(request.form["id_miembro"]),
                "concepto": request.form["concepto"].strip(),
                "monto": float(request.form["monto"]),
                "fecha_pago": leer_fecha(request.form["fecha_pago"]),
                "metodo": request.form["metodo"],
            })
            flash("Pago registrado.", "success")
        except oracledb.DatabaseError as e:
            flash(mensaje_error(e), "danger")
        return redirect(url_for("pagos"))

    lista = consultar("""
        SELECT p.concepto, p.monto, p.fecha_pago, p.metodo, m.id_miembro,
               m.nombre || ' ' || m.apellidos AS miembro
          FROM pago p JOIN miembro m ON m.id_miembro = p.id_miembro
         ORDER BY p.fecha_pago DESC""")
    total = sum(p["monto"] for p in lista)
    semestre = consultar_uno("SELECT fn_semestre(SYSDATE) AS s FROM dual")["s"]
    return render_template("pagos.html", pagos=lista, total=total, semestre=semestre,
                           miembros=consultar(MIEMBROS_ACTIVOS_SQL))


# Reportes (usan las vistas de 03_vistas.sql)
@app.route("/reportes")
@solo_admin
def reportes():
    return render_template(
        "reportes.html",
        asistencia=consultar("SELECT * FROM v_asistencia_miembro ORDER BY porcentaje_asistencia DESC"),
        eventos=consultar("SELECT * FROM v_eventos_semestre ORDER BY semestre DESC, tipo"),
        pendientes=consultar("SELECT * FROM v_pagos_pendientes ORDER BY miembro"),
        proyectos=consultar("SELECT * FROM v_participacion_proyecto ORDER BY participantes DESC"),
        por_semestre=consultar("""
            SELECT semestre, SUM(total_eventos) AS eventos, SUM(total_asistentes) AS asistentes
              FROM v_eventos_semestre GROUP BY semestre ORDER BY semestre"""),
    )


# Constancias
@app.route("/constancias")
@solo_admin
def constancias():
    lista = consultar("SELECT * FROM v_constancia_detalle ORDER BY folio DESC")
    return render_template("constancias.html", constancias=lista)


@app.route("/constancias/<folio>")
@login_requerido
def constancia_ver(folio):
    c = consultar_uno("SELECT * FROM v_constancia_detalle WHERE folio = :folio", {"folio": folio})
    if c is None:
        abort(404)
    # Un miembro solo puede ver sus propias constancias
    if not session["usuario"]["es_admin"] and c["id_miembro"] != session["usuario"]["id"]:
        abort(403)
    return render_template("constancia.html", c=c)


@app.route("/verificar")
def verificar():
    """Página pública para comprobar si un folio existe."""
    folio = request.args.get("folio", "").strip().upper()
    c = None
    if folio:
        c = consultar_uno("SELECT * FROM v_constancia_detalle WHERE folio = :folio", {"folio": folio})
    return render_template("verificar.html", folio=folio, c=c)


if __name__ == "__main__":
    app.run(debug=True)
