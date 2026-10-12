# Informe Técnico de Implementación — Verbum (v1.1)

**Fecha de actualización:** 12 de Octubre de 2026  
**Proyecto:** Verbum — Sagrada Escritura y Calendario Litúrgico  
**Versión Implementada:** MVP v1.1  
**Plataformas:** Flutter Multiplataforma (iOS, Android, Web, Windows Desktop)  
**Arquitectura:** Offline-First (SQLite local + SharedPreferences Web) + State Management reactivo (Riverpod 3)  

---

## 1. Resumen Ejecutivo de lo Realizado

Se ha implementado la totalidad de la base técnica del proyecto **Verbum v1.1**, cubriendo los requerimientos originales del informe técnico MVP y las funcionalidades clave de la versión 1.1:

1. **Biblia RVR09 Completa (66 libros)**: Los 66 libros de la Biblia Reina-Valera 1909 (dominio público) están empaquetados como archivos JSON individuales en `assets/bible/books/`. Cada archivo contiene todos los capítulos y versículos del libro, cargados bajo demanda con caché en memoria para rendimiento óptimo.

2. **Lectura Continua ("Modo Corrido")**: Experiencia de lectura fluida con scroll vertical infinito entre capítulos consecutivos, guardado periódico cada 30 segundos, tarjeta de reanudación rápida en la pantalla de inicio, tres modos de color (Pergamino, Noche, Claro) y ajuste de tamaño de fuente.

3. **Perfil Devocional y Pasajes Guardados**: Perfil de usuario 100% local (sin backend) con cálculo de racha de días de lectura, estadísticas en vivo, sistema de guardado de pasajes con 8 etiquetas temáticas y 5 colores, subrayados por versículo (5 colores), notas personales, y copia de seguridad exportable/importable en formato JSON.

4. **Motor del Calendario Litúrgico Católico**: Algoritmo de cálculo astronómico/eclesiástico de Computus (**Meeus/Jones/Butcher**) para la determinación exacta de la Pascua y todos los tiempos litúrgicos móviles. Calendario mensual interactivo con indicadores de color litúrgico por día, ciclos dominicales (A/B/C) y feriales (Par/Impar).

5. **Navegación y Búsqueda Bíblica**: Canon de los 66 libros con selector de testamento (AT/NT/Todos), selector de capítulos con rejilla interactiva, menú contextual por versículo (guardar, subrayar, anotar, copiar) y buscador dual (por texto libre y por citas directas como `Jn 3:16`, `Salmo 23`, `1 Cor 13:4-8`).

6. **Compatibilidad Web**: Toda la funcionalidad opera en Web usando `SharedPreferences` como almacenamiento alternativo cuando SQLite no está disponible, y `rootBundle` para cargar los archivos JSON bíblicos desde los assets empaquetados.

---

## 2. Pila Tecnológica y Dependencias Configuradas

| Capa / Componente | Tecnología | Justificación Técnica |
| :--- | :--- | :--- |
| **Framework Base** | Flutter 3.38.9 / Dart 3.10.8 | Base de código única para móvil, web y escritorio. |
| **Gestor de Estado** | `flutter_riverpod` (v3.3.2) | Estado desacoplado, testable y reactivo mediante `NotifierProvider`. |
| **Base de Datos Local** | `sqflite` + `sqflite_common_ffi` + `sqflite_common_ffi_web` | SQLite nativo en Android/iOS, FFI en Windows/Desktop e IndexedDB en Web. |
| **Tipografía Sacra** | `google_fonts` | Tipografía clásica (*Cinzel*, *Merriweather* y *Plus Jakarta Sans*). |
| **Internacionalización** | `intl` | Manejo y formateo de fechas y calendarios. |
| **Almacenamiento Clave-Valor** | `shared_preferences` | Almacenamiento rápido de flags, preferencias y respaldo Web. |

---

## 3. Datos Bíblicos: Texto Completo RVR09

### 3.1 Estructura de Assets

Todos los 66 libros de la Biblia Reina-Valera 1909 están almacenados como archivos JSON individuales en:

```
assets/bible/books/
├── 1.json   → Génesis (202 KB, 50 capítulos)
├── 2.json   → Éxodo (169 KB, 40 capítulos)
├── ...
├── 43.json  → Juan (103 KB, 21 capítulos)
├── ...
└── 66.json  → Apocalipsis (64 KB, 22 capítulos)
```

Cada archivo JSON tiene la estructura:
```json
{
  "1": { "1": "EN el principio crió Dios...", "2": "Y la tierra estaba..." },
  "2": { "1": "Y fueron acabados...", ... }
}
```

El tamaño total combinado de los 66 archivos JSON es de aproximadamente **4.5 MB**, empaquetados en los assets de Flutter con carga bajo demanda y caché en memoria por libro.

### 3.2 Datos Semilla en Memoria

En `bible_initial_data.dart` se mantiene una colección representativa de versículos fundamentales (Juan 1, 3, 5, 14; Salmos 23, 91, 121; Génesis 1; Mateo 5-6; Romanos 8; 1 Corintios 13; Filipenses 4; Proverbios 3) para funcionamiento inmediato antes de que se carguen los JSON completos.

---

## 4. Modelo de Datos (SQLite + SharedPreferences)

Se implementaron en `lib/core/database/schema.dart` todas las tablas definidas en la Sección 5 del informe técnico:

### 4.1 Tablas Bíblicas
- `versiones`: Versión bíblica (`codigo: 'RVR09'`, `licencia: 'public-domain'`).
- `libros`: Metadatos de los 66 libros bíblicos (`id`, `testamento`, `nombre`, `abreviatura`, `orden`).
- `versiculos`: Texto versicular indexado (`idx_vers_busqueda`).

### 4.2 Tablas Litúrgicas
- `tiempos_liturgicos`: Tiempos canónicos (`id`, `nombre`, `color`, `fecha_inicio`, `fecha_fin`, `anio_liturgico`).
- `celebraciones`: Fiestas y solemnidades (`fecha`, `nombre`, `rango`, `color`, `es_movil`).
- `lecturas_diarias`: Referencias litúrgicas del leccionario (`fecha`, `ciclo`, `anio_par`, `tipo`, `referencia`).

### 4.3 Tablas de Perfil y Estudio Personal (v1.1)
- `perfil`: Usuario local (`id`, `nombre`, `avatar`, `fecha_creacion`, `preferencias`).
- `pasajes_guardados`: Textos guardados con snapshot y etiquetas temáticas. Índices: `idx_pasajes_perfil`, `idx_pasajes_etiqueta`.
- `marcador_lectura`: Marcador único de lectura continua (`perfil_id UNIQUE`).
- `historial_lectura`: Registro cronológico de lecturas (`idx_historial_perfil`).
- `subrayados`: Resaltados por versículo con 5 colores disponibles.
- `notas`: Anotaciones personales por versículo.
- `favoritos`: Versículos marcados con etiquetas.

### 4.4 Respaldo Web (SharedPreferences)
Todas las operaciones de perfil, marcadores, pasajes guardados, historial, subrayados y notas tienen respaldo automático en `SharedPreferences` para funcionamiento completo en la plataforma Web donde SQLite no está disponible nativamente.

---

## 5. Módulos y Arquitectura del Código

El código fuente está estructurado de forma modular y por capas dentro de `lib/`:

```text
lib/
├── core/
│   ├── database/
│   │   ├── database_helper.dart            # Singleton SQLite con lazy initialization
│   │   ├── platform_init.dart              # Export condicional de plataformas
│   │   ├── platform_init_interface.dart    # Interfaz abstracta de inicialización
│   │   ├── platform_init_io.dart           # Soporte FFI Windows/Desktop/Móvil
│   │   ├── platform_init_web.dart          # Soporte Web SQLite
│   │   └── schema.dart                     # DDL de todas las tablas e índices
│   ├── providers/
│   │   └── app_providers.dart              # Notifiers y Providers de Riverpod 3
│   ├── theme/
│   │   ├── app_theme.dart                  # Temas Claro (Pergamino) y Oscuro (Carbón)
│   │   └── liturgical_colors.dart          # Paleta litúrgica oficial con gradientes
│   └── utils/
│       └── bible_reference_parser.dart     # Analizador de citas bíblicas (regex)
├── features/
│   ├── bible/
│   │   ├── data/
│   │   │   ├── bible_initial_data.dart     # 66 libros + versículos semilla RVR09
│   │   │   └── bible_repository.dart       # Carga JSON + consultas + búsquedas
│   │   ├── models/
│   │   │   ├── bible_book.dart             # Modelo BibleBook con toMap/fromMap
│   │   │   └── bible_verse.dart            # Modelo BibleVerse con referencia calculada
│   │   └── presentation/
│   │       ├── bible_screen.dart           # Selector AT/NT con filtro y selector capítulos
│   │       ├── chapter_reader_screen.dart  # Lector con menú contextual interactivo
│   │       ├── continuous_reader_screen.dart # Modo Corrido con scroll infinito
│   │       └── search_screen.dart          # Búsqueda dual: cita directa y texto libre
│   ├── liturgical_calendar/
│   │   ├── data/
│   │   │   └── liturgical_calculator.dart  # Motor Computus (Meeus/Jones/Butcher)
│   │   ├── models/
│   │   │   ├── daily_reading.dart          # Modelo DailyReading con tipo de lectura
│   │   │   └── liturgical_day.dart         # Modelo LiturgicalDay completo
│   │   └── presentation/
│   │       └── calendar_screen.dart        # Calendario mensual interactivo con detalle
│   ├── profile/
│   │   ├── data/
│   │   │   └── profile_repository.dart     # CRUD perfil, racha, marcadores, JSON backup
│   │   ├── models/
│   │   │   ├── bookmark.dart               # Marcador de lectura continua
│   │   │   ├── reading_history.dart        # Historial de lectura
│   │   │   ├── saved_passage.dart          # Pasaje guardado con snapshot
│   │   │   ├── user_annotation.dart        # UserHighlight + UserNote
│   │   │   └── user_profile.dart           # Perfil de usuario con preferencias
│   │   └── presentation/
│   │       ├── profile_screen.dart         # Estadísticas, racha, ajustes y backup
│   │       └── saved_passages_screen.dart  # Pasajes guardados con filtros por etiqueta
│   └── home/
│       └── presentation/
│           ├── home_screen.dart            # Dashboard con BottomNavigationBar (5 tabs)
│           └── widgets/
│               ├── continue_reading_card.dart # Tarjeta de reanudación lectura
│               ├── quick_actions_grid.dart # Rejilla de 6 accesos rápidos
│               └── today_liturgical_card.dart # Tarjeta del día litúrgico con gradiente
└── main.dart                               # Entrypoint con ProviderScope + SQLite init
```

**Total de archivos Dart:** 35 archivos de código fuente.

---

## 6. Pantallas y Funcionalidades Implementadas

### 6.1 Pantalla de Inicio (`HomeScreen`)
- Encabezado "VERBUM v1.1" con saludo personalizado al usuario
- Tarjeta litúrgica del día con color canónico, celebración, ciclos y referencias
- Tarjeta "Continuar Lectura" con marcador del modo corrido
- Rejilla de 6 accesos rápidos (Biblia, Modo Corrido, Calendario, Guardados, Buscar, Perfil)
- Cita devocional "PALABRA DE VIDA" (Salmos 119:105)
- Barra de navegación inferior con 5 pestañas

### 6.2 Pantalla de la Biblia (`BibleScreen`)
- Filtro por testamento: Todos (66), Antiguo Testamento (39), Nuevo Testamento (27)
- Lista de libros con icono de abreviatura coloreado (dorado NT, verde AT)
- Selector de capítulos en modal con rejilla de 5 columnas
- Acceso directo al Modo Corrido desde cada libro

### 6.3 Lector de Capítulos (`ChapterReaderScreen`)
- Visualización versículo por versículo con tipografía Merriweather
- Números de versículo resaltados en dorado litúrgico
- Navegación entre capítulos con flechas (← anterior / siguiente →)
- Menú contextual por versículo al tocar:
  - Guardar en perfil con título, etiqueta temática y color
  - Añadir nota personal
  - Subrayar con 5 colores
  - Copiar versículo al portapapeles
- Ajuste de tamaño de fuente (14-32 pt)
- Cambio a Modo Corrido desde la barra de acciones
- Registro automático en historial de lectura

### 6.4 Modo Corrido (`ContinuousReaderScreen`)
- Scroll vertical infinito entre capítulos consecutivos
- Separadores solemnes de capítulo con tipografía Cinzel
- Carga predictiva del siguiente capítulo
- Guardado automático del marcador cada 30 segundos
- Botón flotante "Marcador" con referencia actual en tiempo real
- 3 modos de color: Pergamino, Noche, Claro
- Ajuste de tamaño de fuente (14-34 pt)
- Modo pantalla completa (ocultar AppBar)
- Transición automática entre libros al final del último capítulo

### 6.5 Búsqueda Bíblica (`SearchScreen`)
- Campo de búsqueda con autoenfoque
- Sugerencias rápidas: Jn 3:16, Salmo 23, Mateo 5:3, Romanos 8:28, etc.
- Búsqueda por cita directa (parser regex) o por palabra clave
- Resultados con referencia resaltada y texto completo
- Navegación directa al lector de capítulos desde resultados

### 6.6 Calendario Litúrgico (`CalendarScreen`)
- Vista mensual con selector de mes (← / →)
- Botón "Ir a Hoy" en barra de acciones
- Cada día muestra indicador de color litúrgico
- Al seleccionar un día: tarjeta detallada con:
  - Fecha, tiempo litúrgico, color, grado, ciclos
  - Referencias bíblicas asignadas (Primera, Salmo, Segunda, Evangelio)
  - Botón para abrir cada referencia en el buscador

### 6.7 Pasajes Guardados (`SavedPassagesScreen`)
- Filtro por etiqueta temática (Todos, Fe, Oración, Consuelo, Esperanza, etc.)
- Tarjetas con borde coloreado según etiqueta del pasaje
- Texto snapshot con referencia y fecha de guardado
- Botón de eliminación con confirmación

### 6.8 Perfil Devocional (`ProfileScreen`)
- Avatar seleccionable (8 símbolos devocionales)
- Nombre editable
- Versión de la Biblia activa (RVR09 — Dominio Público)
- 4 estadísticas en tiempo real:
  - 🔥 Días de racha
  - 📖 Capítulos leídos (únicos)
  - 🔖 Pasajes guardados
  - ✏️ Notas y subrayados
- Acceso al historial de lectura cronológico
- Selector de tema visual (Sistema, Claro-Pergamino, Oscuro-Carbón)
- Exportar perfil como JSON (copiar al portapapeles)
- Importar perfil desde JSON (pegar y restaurar)

---

## 7. Diseño Visual y Temas

### 7.1 Paleta Litúrgica (`liturgical_colors.dart`)
- **Morado** (#6A2C8F): Adviento, Cuaresma
- **Blanco** (#FFFFFF): Navidad, Pascua, solemnidades
- **Rojo** (#B22234): Pentecostés, mártires, Viernes Santo
- **Verde** (#2E7D32): Tiempo Ordinario
- **Dorado** (#C9A227): Solemnidades especiales, acento primario
- **Rosa** (#D4799E): Gaudete (3er Adviento), Laetare (4ta Cuaresma)
- **Negro** (#1A1A1A): Difuntos
- Gradientes suaves y función de contraste automático para legibilidad

### 7.2 Temas de la Aplicación (`app_theme.dart`)
- **Claro (Pergamino)**: Fondo cálido #F9F6F0, card white, texto oscuro
- **Oscuro (Carbón)**: Fondo profundo #0D0F12, card #16181D, texto suave
- Tipografías: Cinzel (títulos), Merriweather (lectura), Plus Jakarta Sans (UI)

---

## 8. Pruebas y Aseguramiento de Calidad (QA)

Se desarrollaron pruebas automáticas en `test/`:

1. **`test/liturgical_calculator_test.dart`**:
   - Verificación del Domingo de Pascua para años clave (2024, 2025, 2026).
   - Verificación de solemnidades fijas (Navidad, Santa María Madre de Dios).
   - Verificación de tiempos penitenciales y móviles (Miércoles de Ceniza en morado, Viernes Santo en rojo).

2. **`test/bible_reference_test.dart`**:
   - Citas simples (`Jn 3:16`).
   - Rangos de versículos (`Juan 3:16-21`).
   - Capítulos completos (`Salmo 23`).
   - Libros con prefijo numeral (`1 Cor 13:4-8`).

3. **`test/widget_test.dart`**:
   - Prueba de humo del árbol de widgets y renderizado de `VerbumApp` con Riverpod.

---

## 9. Estado Actual y Verificaciones

### 9.1 Verificaciones realizadas
- ✅ La app compila y corre correctamente en **Web (Chrome)** en `http://localhost:50563/`
- ✅ Todos los textos bíblicos se cargan correctamente desde los JSON empaquetados
- ✅ La navegación entre capítulos (flechas ← →) funciona sin texto ilegible
- ✅ El Modo Corrido carga capítulos consecutivamente con scroll infinito
- ✅ El calendario litúrgico calcula correctamente tiempos y colores
- ✅ El perfil, estadísticas y pasajes guardados operan en Web con SharedPreferences
- ✅ La búsqueda por cita y por palabra funciona correctamente
- ✅ Los 66 archivos JSON están presentes y correctamente declarados en `pubspec.yaml`

### 9.2 Problemas conocidos resueltos
- **Textos no cargaban en Web**: Se implementó fallback a `SharedPreferences` y carga de JSON via `rootBundle` para todas las funcionalidades de datos.
- **Texto ilegible en navegación**: Se verificó y corrigió la carga de versículos al cambiar de capítulo con las flechas de navegación.

---

## 10. Instrucciones de Ejecución

```powershell
# En Windows Desktop (nativo):
flutter run -d windows

# En Navegador Web (Chrome):
flutter run -d chrome

# Para ejecutar las pruebas unitarias:
flutter test
```

---

## 11. Próximos Pasos Recomendados (Hacia Fase 2)

- Integración de leccionarios litúrgicos particulares por conferencia episcopal (archivos JSON por país).
- Preparación del esquema de sincronización remota hacia FastAPI + PostgreSQL cuando se inicie la Fase 2 en la nube.
- Sistema de notificaciones locales para recordatorios de lectura diaria.
- Widget de lectura para pantallas de inicio (Android/iOS).
- Integración de versiones bíblicas adicionales (Biblia de Jerusalén, NBV, etc.) bajo las licencias correspondientes.
