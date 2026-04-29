# windows_privilege_escalation_checks

---

# ======================================================
# WINDOWS - COMANDOS DE ENUMERACIÓN PARA ESCALADA
# ======================================================

# Información de usuario y sistema
whoami
whoami /priv
whoami /groups
systeminfo
hostname
set

# Parches y hotfixes
wmic qfe get hotfixid,description,installedon
systeminfo | findstr /i "hotfix"

# Usuarios y grupos
net user
net user %USERNAME%
net localgroup administrators
net group "Domain Admins" (si dominio)

# Conexiones de red y puertos
netstat -ano
netstat -anob (si admin)
arp -a
route print

# Procesos y servicios
tasklist
tasklist /svc
wmic process list full
sc query
sc query state= all
wmic service list brief

# Tareas programadas
schtasks /query /fo LIST /v

# Archivos interesantes (permisos, configuración)
dir /s *flag*.*
dir /s *.* | findstr /i "password"
findstr /si "password" *.config *.xml *.txt *.ini

# Registro de Windows (claves sensibles)
reg query HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
reg query HKLM\SYSTEM\CurrentControlSet\Services\ /s /v "ImagePath" 2>nul | findstr /i ".*\.exe"

# Permisos de directorios (verificar escritura)
icacls C:\Windows\Temp
icacls C:\ProgramData
icacls %APPDATA%

# AlwaysInstallElevated
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated

# PowerShell history
type %userprofile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt

# Credenciales almacenadas
cmdkey /list
dir /s /a "*.kdbx"
vaultcmd /listcreds:

# WSL (si instalado)
wsl whoami
wsl cat /etc/passwd

# Herramientas de transferencia disponibles
where nc
where curl
where wget
where certutil
where powershell

