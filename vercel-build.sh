#!/bin/bash
set -e

echo "=================================================="
echo "      VERBUM — Compilación para Vercel Web       "
echo "=================================================="

# 1. Comprobar si Flutter ya se encuentra disponible en el entorno
if command -v flutter &> /dev/null; then
  echo "✓ Flutter SDK detectado en el PATH del sistema."
else
  echo "Instalando Flutter SDK (rama stable)..."
  if [ ! -d "_flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 _flutter
  fi
  export PATH="$PATH:$(pwd)/_flutter/bin"
fi

# 2. Configuración no interactiva
flutter config --no-analytics
flutter config --enable-web

echo "Versión de Flutter:"
flutter --version

# 3. Obtención de dependencias
echo "Descargando dependencias de Flutter..."
flutter pub get

# 4. Compilación de producción
echo "Compilando aplicación Flutter Web en modo Release..."
flutter build web --release

# 5. Verificación del artefacto de salida
if [ -f "build/web/index.html" ]; then
  echo "=================================================="
  echo "✓ Compilación completada con éxito en build/web"
  echo "=================================================="
else
  echo "Error: No se encontró build/web/index.html"
  exit 1
fi
