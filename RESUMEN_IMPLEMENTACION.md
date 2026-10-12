# Informe Técnico de Implementación — Verbum (v1.1)

**Fecha:** 12 de Octubre de 2026  
**Proyecto:** Verbum — Sagrada Escritura y Calendario Litúrgico  
**Versión Implementada:** MVP v1.1  
**Plataformas:** Flutter Multiplataforma (iOS, Android, Web, Windows Desktop)  
**Arquitectura:** Offline-First (SQLite local) + State Management reactivo (Riverpod 3)  

---

## 1. Resumen Ejecutivo de lo Realizado

Se ha inicializado y configurado la totalidad de la base técnica del proyecto **Verbum v1.1** en esta carpeta de trabajo, cubriendo tanto los requerimientos originales como las dos nuevas funcionalidades clave incorporadas en la versión 1.1 del informe técnico:

1. **Lectura Continua ("Modo Corrido")**: Experiencia de lectura fluida con scroll vertical infinito entre capítulos consecutivos, guardado periódico cada 30 segundos en la base de datos local y tarjeta de reanudación rápida en la pantalla de inicio.
2. **Perfil Devocional y Pasajes Guardados**: Perfil de usuario 100% local (sin backend en el MVP) con cálculo de racha de días consecutivos de lectura, estadísticas en vivo, sistema de guardado de pasajes con etiquetas temáticas y colores, subrayados, notas y copia de seguridad exportable e importable en formato JSON.
3. **Motor del Calendario Litúrgico Católico**: Algoritmo de cálculo astronómico/eclesiástico de Computus (**Meeus/Jones/Butcher**) para la determinación exacta de la Pascua y tiempos litúrgicos móviles, paleta de colores canónicos y ciclos de lecturas.
4. **Navegación y Búsqueda Bíblica (RVR09)**: Canon de los 66 libros bíblicos (Antiguo y Nuevo Testamento) en dominio público, visor por capítulos, menú contextual por versículo y buscador por texto libre o por citas directas (`Jn 3:16`, `Salmo 23`, etc.).

---

## 2. Pila Tecnológica y Dependencias Configuradas

| Capa / Componente | Tecnología | Justificación Técnica |
| :--- | :--- | :--- |
| **Framework Base** | Flutter 3.38.9 / Dart 3.10.8 | Base de código única para móvil, web y escritorio. |
| **Gestor de Estado** | `flutter_riverpod` (v3.3.2) | Estado desacoplado, testable y reactivo mediante `NotifierProvider`. |
| **Base de Datos Local** | `sqflite` + `sqflite_common_ffi` + `sqflite_common_ffi_web` | SQLite nativo en Android/iOS, FFI en Windows/Desktop e IndexedDB en Web. |
| **Tipografía Sacra** | `google_fonts` | Tipografía clásica (*Cinzel*, *Merriweather* y *Plus Jakarta Sans*). |
| **Internacionalización** | `intl` | Manejo y formateo de fechas y calendarios. |
| **Almacenamiento Clave-Valor** | `shared_preferences` | Almacenamiento rápido de flags y preferencias. |

---

## 3. Modelo de Datos Implementado (SQLite)

Se implementaron en [lib/core/database/schema.dart](file:///c:/proyectos/Verbumv1/lib/core/database/schema.dart) todas las tablas definidas en la Sección 5 del informe técnico:

### 3.1 Tablas Bíblicas
- `versiones`: Versión bíblica (`codigo: 'RVR09'`, `licencia: 'public-domain'`).
- `libros`: Metadatos de los 66 libros bíblicos (`id`, `testamento`, `nombre`, `abreviatura`, `orden`).
- `versiculos`: Texto versicular indexado (`idx_vers_busqueda`).

### 3.2 Tablas Litúrgicas
- `tiempos_liturgicos`: Tiempos canónicos (`id`, `nombre`, `color`, `fecha_inicio`, `fecha_fin`, `anio_liturgico`).
- `celebraciones`: Fiestas y solemnidades (`fecha`, `nombre`, `rango`, `color`, `es_movil`).
- `lecturas_diarias`: Referencias litúrgicas del leccionario (`fecha`, `ciclo`, `anio_par`, `tipo`, `referencia`).

### 3.3 Tablas de Perfil y Estudio Personal (v1.1)
- `perfil`: Usuario local (`id`, `nombre`, `avatar`, `fecha_creacion`, `preferencias`).
- `pasajes_guardados`: Textos guardados por el usuario con snapshot (`perfil_id`, `titulo`, `referencia_inicio`, `referencia_fin`, `texto_snapshot`, `etiqueta`, `color`, `fecha_guardado`). Índices creados: `idx_pasajes_perfil`, `idx_pasajes_etiqueta`.
- `marcador_lectura`: Marcador único del usuario (`perfil_id UNIQUE`, `libro_id`, `capitulo`, `versiculo`, `modo`, `fecha_actualizacion`).
- `historial_lectura`: Registro cronológico de lecturas (`idx_historial_perfil`).
- `subrayados`: Resaltados por versículo (`perfil_id`, `versiculo_id`, `color`, `fecha_creacion`).
- `notas`: Anotaciones personales (`perfil_id`, `versiculo_id`, `contenido`, `fecha_modificacion`).
- `favoritos`: Versículos marcados con etiquetas.

---

## 4. Módulos y Arquitectura del Código

El código fuente está estructurado de forma modular y por capas dentro de `lib/`:

```text
lib/
├── core/
│   ├── database/
│   │   ├── database_helper.dart            # Singleton SQLite con lazy initialization
│   │   ├── platform_init.dart              # Export condicional de plataformas
│   │   ├── platform_init_io.dart           # Soporte FFI Windows/Desktop/Móvil
│   │   ├── platform_init_web.dart          # Soporte Web SQLite
│   │   └── schema.dart                     # DDL de todas las tablas e índices
│   ├── providers/
│   │   └── app_providers.dart              # Notifiers y Providers de Riverpod 3
│   ├── theme/
│   │   ├── app_theme.dart                  # Temas Claro (Pergamino) y Oscuro (Carbón)
│   │   └── liturgical_colors.dart          # Paleta litúrgica oficial
│   └── utils/
│       └── bible_reference_parser.dart     # Analizador de citas bíblicas
├── features/
│   ├── bible/
│   │   ├── data/
│   │   │   ├── bible_initial_data.dart     # 66 libros y versículos semilla RVR09
│   │   │   └── bible_repository.dart       # Consultas y búsquedas en BD
│   │   ├── models/
│   │   │   ├── bible_book.dart
│   │   │   └── bible_verse.dart
│   │   └── presentation/
│   │       ├── bible_screen.dart           # Selector AT/NT y selector de capítulos
│   │       ├── chapter_reader_screen.dart  # Lector con menú contextual interactivo
│   │       ├── continuous_reader_screen.dart # Modo Corrido con scroll infinito
│   │       └── search_screen.dart          # Búsqueda por cita y por término
│   ├── liturgical_calendar/
│   │   ├── data/
│   │   │   └── liturgical_calculator.dart  # Motor Computus (Meeus/Jones/Butcher)
│   │   ├── models/
│   │   │   ├── daily_reading.dart
│   │   │   └── liturgical_day.dart
│   │   └── presentation/
│   │       └── calendar_screen.dart        # Calendario mensual interactivo
│   ├── profile/
│   │   ├── data/
│   │   │   └── profile_repository.dart     # CRUD perfil, racha, marcadores y JSON
│   │   ├── models/
│   │   │   ├── bookmark.dart
│   │   │   ├── reading_history.dart
│   │   │   ├── saved_passage.dart
│   │   │   ├── user_annotation.dart
│   │   │   └── user_profile.dart
│   │   └── presentation/
│   │       ├── profile_screen.dart         # Estadísticas, racha, ajustes y backup
│   │       └── saved_passages_screen.dart  # Pasajes guardados con filtros
│   └── home/
│       └── presentation/
│           ├── home_screen.dart            # Dashboard de Inicio con navegación
│           └── widgets/
│               ├── continue_reading_card.dart # Reanudación de lectura
│               ├── quick_actions_grid.dart # Rejilla de accesos rápidos
│               └── today_liturgical_card.dart # Tarjeta del día litúrgico
└── main.dart                               # Entrypoint con ProviderScope
```

---

## 5. Pruebas y Aseguramiento de Calidad (QA)

Se desarrollaron y ejecutaron pruebas automáticas mediante `flutter test` con un **100% de aprobación (8/8 tests exitosos)**:

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

## 6. Instrucciones de Ejecución

Para correr el proyecto en cualquier entorno:

```powershell
# En Windows Desktop (nativo):
flutter run -d windows

# En Navegador Web (Chrome):
flutter run -d chrome

# Para ejecutar las pruebas unitarias:
flutter test
```

---

## 7. Próximos Pasos Recomendados (Hacia Fase 2)
- Integración del texto bíblico completo para los 66 libros en archivo empaquetado de alta compresión.
- Carga de calendarios litúrgicos particulares por conferencia episcopal (archivos JSON por país).
- Preparación del esquema de sincronización remota hacia FastAPI + PostgreSQL cuando se inicie la Fase 2 en la nube.
