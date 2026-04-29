# port_knock_sequences

---

# ======================================================
# PORT KNOCKING SECUENCIAS COMUNES
# ======================================================
# Útil para CTFs que esconden servicios detrás de knock

# Secuencias cortas (2-3 puertos)
1111 2222 3333
1000 2000 3000
1234 5678 9012
22 80 443
12345 54321
7000 8000 9000
2222 3333 4444
21 22 23

# Secuencias más largas
1111 2222 3333 4444
9999 8888 7777 6666
22 80 443 8080
21 22 23 25 80

# Secuencias típicas de herramientas:
# knockd ejemplo
123 456 789
1000 2000 3000 4000

# Secuencias de reverse shell knocking (abre puerto después de knock)
1234 5678
9999 9998 9997

# CTF comunes: puertos incrementales
80 81 82 83
443 444 445

# Con puertos altos aleatorios
30000 31000 32000
50000 50001 50002


