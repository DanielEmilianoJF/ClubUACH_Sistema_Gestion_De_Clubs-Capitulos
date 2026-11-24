# db.py
# Funciones para conectarse a Oracle y ejecutar consultas.
# Los datos de conexión se leen del archivo .env

import os

import oracledb
from dotenv import load_dotenv

load_dotenv()


def conectar():
    """Abre una conexión nueva a Oracle."""
    return oracledb.connect(
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        dsn=os.getenv("DB_DSN"),
    )


def consultar(sql, datos=None):
    """Ejecuta un SELECT y regresa una lista de diccionarios.
    Ejemplo: [{'id_miembro': 1, 'nombre': 'Daniel'}, ...]"""
    with conectar() as conexion:
        cursor = conexion.cursor()
        cursor.execute(sql, datos or {})
        columnas = [columna[0].lower() for columna in cursor.description]
        return [dict(zip(columnas, fila)) for fila in cursor.fetchall()]


def consultar_uno(sql, datos=None):
    """Igual que consultar(), pero regresa solo el primer registro (o None)."""
    filas = consultar(sql, datos)
    return filas[0] if filas else None


def ejecutar(sql, datos=None):
    """Ejecuta un INSERT, UPDATE o DELETE y guarda los cambios (commit)."""
    with conectar() as conexion:
        cursor = conexion.cursor()
        cursor.execute(sql, datos or {})
        conexion.commit()


def mensaje_error(error):
    """Convierte un error de Oracle en un mensaje fácil de entender."""
    error_oracle = error.args[0]
    codigo = error_oracle.code

    # Errores que lanzamos nosotros desde PL/SQL con RAISE_APPLICATION_ERROR
    if 20000 <= codigo <= 20999:
        primera_linea = error_oracle.message.split("\n")[0]
        return primera_linea.split(": ", 1)[1]

    if codigo == 1:
        return "Ya existe un registro con ese dato (correo o matrícula repetidos)."
    if codigo == 2292:
        return "No se puede eliminar porque tiene registros relacionados."
    if codigo == 2290:
        return "Algún dato no cumple las reglas (revisa fechas, horas o montos)."
    return "Error de base de datos: " + error_oracle.message
