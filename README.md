# ClubUACH · Sistema de Gestión de Capítulo Estudiantil

Aplicación web que reemplaza las hojas de cálculo y los chats con los que un club o capítulo estudiantil de la UACH lleva sus listas. Centraliza en una base de datos Oracle la información de **miembros, eventos, asistencia, constancias, proyectos y cuotas**, y genera reportes para la mesa directiva.

> Proyecto final de **Fundamentos de Bases de Datos** · Facultad de Ingeniería, UACH · Grupo 6CC2
> Profesor: José Saúl De Lira Miramontes
> Equipo: Andrea Domínguez Rodríguez (374234) · Daniel Emiliano Jiménez Frade (376976)

## Funciones

| Módulo | Qué hace |
|---|---|
| Inicio de sesión | Dos perfiles: **mesa directiva** (administra todo) y **miembro** (consulta su información). Contraseñas guardadas con hash PBKDF2. |
| Miembros | Alta, edición, búsqueda, baja/reactivación. |
| Eventos | Calendario de talleres, pláticas, reuniones, congresos y hackathons con responsable y cupo. |
| Asistencia | Inscripción (respetando el cupo), pase de lista y autoinscripción del miembro. |
| Constancias | Emisión masiva por evento con **folio único** (`CUACH-2026-00001`), versión para imprimir o guardar en PDF y página pública para verificar un folio. |
| Proyectos | Proyectos del capítulo, líder y participantes con su función. |
| Pagos | Registro de cuotas y otros pagos por miembro. |
| Reportes | Asistencia por miembro, eventos por semestre, pagos pendientes y participación por proyecto, con una gráfica de eventos por semestre. |

## Tecnologías

- **Base de datos:** Oracle Database 23ai Free en Docker, administrada con Oracle SQL Developer 26.2
- **Backend:** Python 3 + Flask, acceso a datos con `python-oracledb` (modo *thin*, sin Instant Client)
- **Frontend:** HTML5, CSS3, JavaScript, Bootstrap 5 y plantillas Jinja2, Chart.js para gráficas
- **Herramientas:** Git y GitHub

## Estructura del repositorio

```
clubuach/
├── database/              Scripts de la base de datos (ejecutar en orden)
│   ├── 00_crear_usuario.sql   crea el usuario/esquema CLUBUACH (como SYSTEM)
│   ├── 01_tablas.sql          9 tablas, llaves, restricciones e índices
│   ├── 02_logica.sql          función, trigger y procedimientos PL/SQL
│   ├── 03_vistas.sql          vistas para reportes
│   └── 04_datos.sql           datos de ejemplo
├── templates/             pantallas HTML (Jinja2 + Bootstrap)
├── static/                CSS, logos y librerías (Bootstrap, iconos, Chart.js)
├── manuales/
│   ├── Manual Técnico.pdf
│   └── Manual de Usuario.pdf
├── app.py                 aplicación Flask (todas las rutas)
├── db.py                  conexión a Oracle y funciones de consulta
├── requirements.txt
└── .env.example           variables de conexión
```

## Instalación rápida

**Requisitos:** Oracle Database 23ai Free (en Docker), Python 3.10 o superior. El servicio de la base de datos se llama `FREEPDB1`.

1. **Base de datos.** En SQL Developer, conectado como `SYSTEM` al servicio `FREEPDB1`, ejecuta `database/00_crear_usuario.sql` (F5). Luego conéctate como `clubuach` / `ClubUach2026` y ejecuta `01` a `04` en orden.
2. **Aplicación.**
   ```bash
   git clone <url-del-repositorio>
   cd clubuach
   python -m venv venv
   venv\Scripts\activate          # Windows  (en Linux/Mac: source venv/bin/activate)
   pip install -r requirements.txt
   copy .env.example .env          # Windows  (en Linux/Mac: cp .env.example .env)
   python app.py
   ```
3. Abre <http://127.0.0.1:5000>.

**Cuentas de prueba** (contraseña `clubuach123`):

| Perfil | Correo |
|---|---|
| Mesa directiva (Presidente) | `admin@clubuach.mx` |
| Miembro | `miembro@clubuach.mx` |

## Documentación

- [Manual Técnico](manuales/Manual%20T%C3%A9cnico.pdf): requerimientos, arquitectura, base de datos, reglas de negocio y seguridad.
- [Manual de Usuario](manuales/Manual%20de%20Usuario.pdf): cómo usar cada pantalla, con capturas.
