# linux_privilege_escalation_checks

---

# ======================================================
# LINUX - COMANDOS DE ENUMERACIÓN PARA ESCALADA
# ======================================================

# Información básica
id
whoami
uname -a
hostname
cat /etc/os-release
cat /etc/issue
env
set

# Usuarios y grupos
cat /etc/passwd
cat /etc/shadow (solo root)
cat /etc/group
sudo -l
sudo -ll (más detalle)

# Procesos
ps aux
ps auxf
top -n 1 -b
pstree -a

# Red
netstat -tulpn
ss -tulpn
ip a
route -n
arp -a
cat /etc/resolv.conf

# Cron y tareas programadas
crontab -l
ls -la /etc/cron*
ls -la /etc/cron.d/
cat /etc/anacrontab

# Servicios (systemd)
systemctl list-units --type=service --all
ls -la /etc/systemd/system/

# Archivos SUID/SGID
find / -perm -4000 -type f 2>/dev/null
find / -perm -2000 -type f 2>/dev/null

# Directorios escribibles por el usuario
find / -writable -type d 2>/dev/null
find / -writable -type f 2>/dev/null | head -20

# Archivos de configuración con contraseñas
grep -r "password" /etc/ 2>/dev/null
grep -r "passwd" /var/www/ 2>/dev/null
grep -r "DB_PASSWORD" /var/www/ 2>/dev/null

# Historial de comandos
cat ~/.bash_history
cat ~/.zsh_history
cat ~/.history
cat /root/.bash_history (si permiso)

# Capabilities
getcap -r / 2>/dev/null

# Procesos con capabilities (Linux)
grep Cap /proc/*/status 2>/dev/null

# Directorios compartidos, montajes
mount
df -h

# Kernel exploits (buscar exploit sugerido)
uname -a | xargs searchsploit

# Variables de entorno con rutas modificadas
echo $PATH
find / -perm -4000 -ls 2>/dev/null

# SSH keys
ls -la ~/.ssh/
ls -la /root/.ssh/
cat ~/.ssh/id_rsa (si existe)

# Docker / LXC
docker images
docker ps -a
lxc-ls

