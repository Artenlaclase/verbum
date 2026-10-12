# Verbum (v1.1) — Sagrada Escritura y Calendario Litúrgico

> *"Verbum Domini manet in aeternum"* — La Palabra del Señor permanece para siempre.

Aplicación devocional multiplataforma (**iOS, Android, Web y Desktop**) construida con **Flutter 3**, **Riverpod** y arquitectura **Offline-First** sobre **SQLite**, según las especificaciones técnicas del **Informe Técnico — MVP "Verbum" (v1.1)**.

---

## 📖 Funcionalidades Implementadas (Alcance MVP v1.1)

### 1. 🆕 Lectura Continua ("Modo Corrido")
- **Lectura fluida y sin distracciones**: Scroll infinito entre capítulos consecutivos.
- **Transición automática**: Al llegar al final de un capítulo, carga el siguiente de forma continua.
- **Marcador de posición automático (`marcador_lectura`)**: Registro periódico en SQLite cada 30 segundos y botón flotante *"Guardar marcador aquí"*.
- **Acceso directo en Inicio**: Tarjeta *"Continuar en [Libro C:V]"* con reanudación instantánea.
- **Ajustes de lectura**: Modo Pergamino (sepia), Noche (carbón litúrgico) y Claro, más tamaño tipográfico dinámico.

### 2. 🆕 Perfil de Usuario Local y Estudio Personal
- **100% Offline-First y privado**: Sin backend en el MVP, datos almacenados en el dispositivo (`perfil`).
- **Personalización**: Nombre, selector de símbolos sagrados/emojis y fecha de inicio.
- **Estadísticas devocionales en tiempo real**:
  - Racha de días consecutivos de lectura.
  - Total de capítulos leídos.
  - Pasajes guardados en el perfil.
  - Anotaciones y subrayados.
- **Mis Pasajes Guardados (`pasajes_guardados`)**:
  - Guardado desde cualquier versículo con título opcional, etiquetas temáticas (*Fe, Oración, Consuelo, Esperanza, Gratitud, Amor, Paz, Sabiduría*) y colores personalizados.
  - Filtro por etiquetas temáticas.
  - Copia rápida al portapapeles y enlace de apertura directa en el contexto bíblico.
- **Herramientas de estudio**: Subrayados con paleta de 5 colores litúrgicos, notas personales e historial cronológico de lectura.
- **Exportación e Importación de Respaldo (JSON)**: Permite respaldar y migrar datos entre dispositivos sin servidor.

### 3. Motor del Calendario Litúrgico Católico
- **Algoritmo astronómico Meeus/Jones/Butcher (Computus)**: Cálculo exacto de la fecha del Domingo de Pascua para cualquier año gregoriano.
- **Tiempos móviles y festividades**: Miércoles de Ceniza, Cuaresma, Domingo de Ramos, Semana Santa, Triduo Pascual, Resurrección, Pascua, Pentecostés, Jesucristo Rey del Universo.
- **Paleta Litúrgica Oficial**:
  - 🟣 **Morado (`#6A2C8F`)**: Adviento, Cuaresma, Penitencial.
  - ⚪ **Blanco / Marfil (`#F5F1E8`)**: Navidad, Pascua, Solemnidades.
  - 🔴 **Rojo (`#B22234`)**: Pentecostés, Mártires, Viernes Santo.
  - 🟢 **Verde (`#2E7D32`)**: Tiempo Ordinario.
  - 🌸 **Rosa (`#E8A0BF`)**: Gaudete (III Adviento) y Laetare (IV Cuaresma).
  - 🟡 **Dorado (`#C9A227`)**: Solemnidades especiales y Reyes.
- **Ciclos Litúrgicos**: Dominical (A, B, C) y Ferial (I, II).
- **Tarjeta "Hoy" en Inicio**: Tiempo actual, fiesta, ciclo, rango y citas de las lecturas del día con enlace de apertura en la Biblia.
- **Vista mensual interactiva**: Calendario con indicadores de color litúrgico por día y panel de detalles.

### 4. Sagrada Escritura (RVR09) y Búsqueda
- **Canon de 66 libros**: 39 del Antiguo Testamento y 27 del Nuevo Testamento con conteo de capítulos y abreviaturas canónicas.
- **Búsqueda inteligente**:
  - Por citas bíblicas directas (ej: `Jn 3:16`, `Juan 3:16-21`, `Salmo 23`, `1 Cor 13:4-8`).
  - Por texto libre o palabras clave (ej: `amor`, `paz`, `fe`, `luz`).

---

## 🏛️ Estructura del Código

```text
lib/
├── core/
│   ├── database/
│   │   ├── database_helper.dart            # Inicializador Singleton SQLite
│   │   ├── platform_init.dart              # Inicialización condicional multiplataforma
│   │   ├── platform_init_io.dart           # FFI para Windows/Desktop/Móvil
│   │   ├── platform_init_web.dart          # Soporte Web SQLite
│   │   └── schema.dart                     # Esquema DDL según informe v1.1
│   ├── providers/
│   │   └── app_providers.dart              # Gestión de estado con Riverpod 3 (Notifiers)
│   ├── theme/
│   │   ├── app_theme.dart                  # Tipografía Cinzel/Merriweather y estilos
│   │   └── liturgical_colors.dart          # Paleta litúrgica oficial
│   └── utils/
│       └── bible_reference_parser.dart     # Parser de citas bíblicas
├── features/
│   ├── bible/
│   │   ├── data/
│   │   │   ├── bible_initial_data.dart     # Canon bíblico y versículos semilla RVR09
│   │   │   └── bible_repository.dart       # Acceso y búsquedas en SQLite
│   │   ├── models/
│   │   │   ├── bible_book.dart
│   │   │   └── bible_verse.dart
│   │   └── presentation/
│   │       ├── bible_screen.dart           # Índice de libros y selector de capítulos
│   │       ├── chapter_reader_screen.dart  # Lector por capítulo con subrayados y notas
│   │       ├── continuous_reader_screen.dart # 🆕 Modo Corrido con scroll infinito y auto-guardado
│   │       └── search_screen.dart          # Búsqueda por cita y por texto
│   ├── liturgical_calendar/
│   │   ├── data/
│   │   │   └── liturgical_calculator.dart  # Motor litúrgico (Computus Meeus/Jones/Butcher)
│   │   ├── models/
│   │   │   ├── daily_reading.dart
│   │   │   └── liturgical_day.dart
│   │   └── presentation/
│   │       └── calendar_screen.dart        # Vista mensual litúrgica
│   ├── profile/
│   │   ├── data/
│   │   │   └── profile_repository.dart     # CRUD de perfil, pasajes, marcador y backup JSON
│   │   ├── models/
│   │   │   ├── bookmark.dart               # 🆕 Marcador de lectura continua
│   │   │   ├── reading_history.dart        # 🆕 Historial de lecturas
│   │   │   ├── saved_passage.dart          # 🆕 Pasajes guardados en el perfil
│   │   │   ├── user_annotation.dart        # Subrayados y notas
│   │   │   └── user_profile.dart           # Perfil local del usuario
│   │   └── presentation/
│   │       ├── profile_screen.dart         # Estadísticas, racha, preferencias y backup
│   │       └── saved_passages_screen.dart  # 🆕 Lista de pasajes con filtros temáticos
│   └── home/
│       └── presentation/
│           ├── home_screen.dart            # Pantalla principal e IndexedStack
│           └── widgets/
│               ├── continue_reading_card.dart # 🆕 Tarjeta "Continuar lectura"
│               ├── quick_actions_grid.dart # Rejilla de navegación
│               └── today_liturgical_card.dart # Tarjeta "Hoy" litúrgica
└── main.dart                               # Entrypoint con ProviderScope
```

---

## 🚀 Cómo Ejecutar el Proyecto

### Requisitos previos
- **Flutter SDK**: 3.x+
- **Dart SDK**: 3.x+

### Ejecución en Desktop (Windows)
```bash
flutter run -d windows
```

### Ejecución en Web (Chrome / Edge)
```bash
flutter run -d chrome
```

### Ejecutar Pruebas
```bash
flutter test
```

---

## 📋 Cumplimiento Legal y Licencias (MVP)
- **Texto Bíblico**: Reina-Valera 1909 (RVR09), libre de derechos y en dominio público.
- **Calendario Litúrgico**: Algoritmo de cálculo propio basado en fuentes astronómicas y canónicas abiertas.
- **Sin Dependencias de Backend en MVP**: Privacidad garantizada mediante almacenamiento local SQLite y exportación JSON abierta.
