#!/bin/bash

# Configuración
USER_REPO="kr3s4l4"
NOMBRE_REPO="Cheatsheet"

echo "[*] Repositorio: $USER_REPO/$NOMBRE_REPO"
read -p "[?] ¿Estás en el directorio con los archivos .txt? (s/n): " confirm
if [[ "$confirm" != "s" ]]; then
    echo "[!] Ejecuta el script dentro de la carpeta que contiene los .txt"
    exit 1
fi

# Convertir cada .txt a .md con formato bonito
for archivo in *.txt; do
    [ -f "$archivo" ] || continue
    base="${archivo%.txt}"
    echo "[+] Convirtiendo $archivo -> ${base}.md"

    # Cabecera
    echo "# ${base}" > "${base}.md"
    echo "" >> "${base}.md"
    echo "---" >> "${base}.md"
    echo "" >> "${base}.md"

    # Leer línea por línea
    while IFS= read -r linea; do
        # Si la línea parece un comando (empieza con espacio, $, #, o palabras comunes)
        if [[ "$linea" =~ ^[[:space:]]+[\$\#] ]] || \
           [[ "$linea" =~ ^[[:space:]]+(cat|echo|python|nc|bash|curl|wget|sqlmap|nmap|whoami|id|find|grep) ]]; then
            # Escapar backticks
            linea_escapada=$(echo "$linea" | sed 's/`/\\`/g')
            echo '    `'"$linea_escapada"'`' >> "${base}.md"
        elif [[ "$linea" == \#* ]]; then
            # Comentarios normales
            echo "$linea" >> "${base}.md"
        else
            echo "$linea" >> "${base}.md"
        fi
    done < "$archivo"
    echo "" >> "${base}.md"
done

# Generar README.md
echo "[+] Generando README.md"
cat > README.md << EOF
# Cheatsheet para Hacking y CTFs

Este repositorio contiene mis cheatsheets y payloads útiles.

## Contenido
$(for f in *.md; do [[ "$f" != "README.md" ]] && echo "- [\`${f%.md}\`]($f)"; done)

---
**Uso educativo**
EOF

# Inicializar git y subir a GitHub
echo "[+] Inicializando repositorio git"
git init
git add .
git commit -m "Initial commit: cheatsheets"

# Usar GitHub CLI si está instalado
if command -v gh &> /dev/null; then
    echo "[+] Usando GitHub CLI"
    gh repo create "$USER_REPO/$NOMBRE_REPO" --public --description "Cheatsheets for hacking" --source=. --push
else
    echo "[!] GitHub CLI no instalado. Crea el repositorio manualmente en:"
    echo "    https://github.com/$USER_REPO/$NOMBRE_REPO"
    echo "    Luego ejecuta:"
    echo "        git remote add origin https://github.com/$USER_REPO/$NOMBRE_REPO.git"
    echo "        git push -u origin main"
fi

echo "[✔] Proceso completado"
