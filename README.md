# Verbum (v1.1) — Sagrada Escritura y Calendario Litúrgico

> *"Verbum Domini manet in aeternum"* — La Palabra del Señor permanece para siempre.

Aplicación devocional multiplataforma (**iOS, Android, Web y Desktop**) construida con **Flutter 3**, **Riverpod**, almacenamiento local **SQLite / SharedPreferences** y sincronización automática en la nube con **Firebase Authentication & Cloud Firestore (`verbumv1`)**.

---

## 📖 Funcionalidades Implementadas (Verbum v1.1)

### 1. 🌿 Pantalla de Inicio Devocional (Orden de Lectura Diaria)
1. **Guía Bíblica para tu Día (`thematic_suggestions`)**:
   - Selector de temas espirituales cotidianos (*Paz, Fortaleza, Esperanza, Sabiduría, Perdón, Gratitud, Amor, Oración, Familia, Amistad, Propósito*).
   - Botón circular de flecha (`›` / `‹`) en pantallas móviles para recorrer todas las categorías de forma fluida.
   - Tarjetas de versículos recomendados con lectura del capítulo completo en un toque.
2. **Modo Corrido (`ContinueReadingCard`)**:
   - Ubicado justo debajo de la Guía Bíblica para retomar la lectura secuencial de la Biblia.
   - Todo lector nuevo o sin sesión inicia siempre desde cero en **`Génesis 1:1`** (*Paso 0 · Comenzar desde el principio*).
3. **Calendario Litúrgico "Hoy" (`TodayLiturgicalCard`)**:
   - Tiempo litúrgico actual, color oficial, fiesta o solemnidad, ciclo dominical/ferial y citas de las lecturas del día con apertura directa en la Biblia.

### 2. 📜 Lectura Continua ("Modo Corrido") y Lector por Capítulos
- **Scroll infinito canónico**: Transición continua entre capítulos y libros consecutivos de los 66 libros de la Biblia (Reina-Valera 1909).
- **Marcador dinámico (`marcador_lectura`)**: Auto-guardado cada 30 segundos, botón flotante de marcador y opción de fijar el marcador en cualquier versículo específico.
- **Menú interactivo en cada versículo (tanto en Modo Corrido como por Capítulos)**:
  - Al tocar cualquier versículo se despliega el panel para **Guardar en mi perfil**, **Añadir nota personal**, **Subrayar versículo** (paleta de 5 colores), **Fijar marcador aquí** o **Copiar versículo**.
- **Ajustes de lectura**: Modos *Pergamino* (sepia), *Noche* (carbón litúrgico) y *Claro*, con ajuste dinámico de tamaño tipográfico.

### 3. 🔐 Cuenta Verbum, Verificación de Correo y Sincronización Automática (Firebase)
- **Autenticación con Firebase (`verbumv1`)**:
  - Inicio de sesión con **Google** en un clic o con **Correo electrónico y Contraseña**.
  - **Validación de correo real con cuenta regresiva (`02:00`)**: Al crear una cuenta con correo, se valida el dominio, se envía un enlace real de verificación y se abre un temporizador de 2 minutos. Si el correo no se confirma a tiempo, la sesión se cancela y la cuenta no verificada se elimina automáticamente.
- **Sincronización 100% automática en segundo plano**:
  - Al iniciar sesión o crear cuenta, el perfil, marcador, pasajes guardados, notas, subrayados e historial se sincronizan automáticamente con **Cloud Firestore** (`users/{uid}`) sin necesidad de botones manuales.
  - En el documento raíz `users/{uid}` se almacena explícitamente el `email`, `uid`, `nombre` y `ultima_sincronizacion`.
- **Reinicio a cero al cerrar sesión**:
  - En **Mi Perfil Devocional** se presenta un único botón directo (**«Iniciar Sesión»** / **«Cerrar Sesión»**).
  - Al cerrar sesión, la aplicación limpia los datos locales y vuelve a **cero** (`Génesis 1:1`, estadísticas en `0`, pasajes e historial vacíos).
  - La lectura bíblica es siempre libre, mientras que **guardar pasajes, crear notas/subrayados y llevar el historial de lectura** requiere iniciar sesión.

### 4. 🕊️ Modelo Devocional: «Camino Abierto» y «Custodio de la Palabra»
- **Camino Abierto (Gratuito)**:
  - Acceso íntegro a los 66 libros de la Sagrada Escritura, Modo Corrido, Guía Bíblica Diaria y Calendario Litúrgico.
  - Estudio personal con sesión iniciada de hasta **5 pasajes guardados** y **10 notas o subrayados**.
- **Custodio de la Palabra (Alianza de Sostenimiento)**:
  - Pasajes guardados, notas y subrayados **ilimitados**.
  - Desbloqueo de **«Ajustes del Scriptorium»** (cambio de tema visual global y exportación/importación del Relicario en JSON).
  - **Lista prioritaria de interesados**: Al presionar *«Unirme como Custodio de la Palabra»*, la aplicación informa que la función estará disponible próximamente y registra automáticamente el correo electrónico del usuario en Firestore (`custodio_interesados/{uid}` y `users/{uid}`) para contactarlo en cuanto se habilite.

### 5. ⛪ Motor del Calendario Litúrgico Católico
- **Algoritmo astronómico Meeus/Jones/Butcher (Computus)**: Cálculo exacto del Domingo de Pascua y todas las fiestas móviles (Miércoles de Ceniza, Cuaresma, Semana Santa, Triduo Pascual, Pentecostés, Cristo Rey).
- **Paleta Litúrgica Oficial**:
  - 🟣 **Morado (`#6A2C8F`)**: Adviento, Cuaresma, Penitencial.
  - ⚪ **Blanco / Marfil (`#F5F1E8`)**: Navidad, Pascua, Solemnidades.
  - 🔴 **Rojo (`#B22234`)**: Pentecostés, Mártires, Viernes Santo.
  - 🟢 **Verde (`#2E7D32`)**: Tiempo Ordinario.
  - 🌸 **Rosa (`#E8A0BF`)**: Gaudete (III Adviento) y Laetare (IV Cuaresma).
  - 🟡 **Dorado (`#C9A227`)**: Solemnidades especiales.

---

## 🏛️ Estructura del Código

```text
lib/
├── core/
│   ├── database/
│   │   ├── database_helper.dart                  # Inicializador Singleton SQLite
│   │   ├── platform_init.dart                    # Inicialización condicional multiplataforma
│   │   ├── platform_init_io.dart                 # FFI para Windows/Desktop/Móvil
│   │   ├── platform_init_web.dart                # Soporte Web
│   │   └── schema.dart                           # Esquema DDL SQLite
│   ├── providers/
│   │   └── app_providers.dart                    # Proveedores reactivos Riverpod + VerbumPlanLimits
│   ├── services/
│   │   ├── auth_service.dart                     # Firebase Auth, validación de correo y verificación 02:00
│   │   └── firestore_sync_service.dart           # Sincronización automática con Cloud Firestore
│   ├── theme/
│   │   ├── app_theme.dart                        # Tipografía Cinzel/Merriweather y estilos
│   │   └── liturgical_colors.dart                # Paleta litúrgica oficial
│   └── utils/
│       └── bible_reference_parser.dart           # Parser de citas bíblicas
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── auth_screen.dart                  # Login/Registro con Google, Correo y reloj de verificación
│   ├── bible/
│   │   ├── data/
│   │   │   ├── bible_initial_data.dart           # Canon bíblico de 66 libros RVR09
│   │   │   └── bible_repository.dart             # Acceso y búsquedas en SQLite / JSON
│   │   ├── models/
│   │   │   ├── bible_book.dart
│   │   │   └── bible_verse.dart
│   │   └── presentation/
│   │       ├── bible_screen.dart                 # Índice de libros, capítulos y acceso a Modo Corrido
│   │       ├── chapter_reader_screen.dart        # Lector por capítulo con pasajes, notas y subrayados
│   │       ├── continuous_reader_screen.dart     # Modo Corrido interactivo (notas, guardados, subrayados)
│   │       └── search_screen.dart                # Búsqueda por cita y por palabra clave
│   ├── thematic_suggestions/
│   │   ├── data/
│   │   │   └── thematic_data.dart                # Catálogo de temas y pasajes espirituales
│   │   ├── models/
│   │   │   └── bible_theme.dart
│   │   └── presentation/
│   │       └── thematic_suggestions_widget.dart  # Guía Bíblica para tu Día con navegación móvil
│   ├── liturgical_calendar/
│   │   ├── data/
│   │   │   └── liturgical_calculator.dart        # Motor litúrgico (Computus Meeus/Jones/Butcher)
│   │   ├── models/
│   │   │   ├── daily_reading.dart
│   │   │   └── liturgical_day.dart
│   │   └── presentation/
│   │       └── calendar_screen.dart              # Vista mensual litúrgica interactiva
│   ├── profile/
│   │   ├── data/
│   │   │   └── profile_repository.dart           # Gestión de perfil, estudio personal y reinicio al cerrar sesión
│   │   ├── models/
│   │   │   ├── bookmark.dart                     # Marcador de lectura (inicio en Génesis 1:1)
│   │   │   ├── reading_history.dart              # Historial cronológico de lecturas
│   │   │   ├── saved_passage.dart                # Pasajes guardados con etiquetas
│   │   │   ├── user_annotation.dart              # Subrayados y notas personales
│   │   │   └── user_profile.dart                 # Perfil del usuario
│   │   └── presentation/
│   │       ├── profile_screen.dart               # Perfil devocional, botón de sesión y Alianza Custodio
│   │       └── saved_passages_screen.dart        # Lista de pasajes guardados con filtros temáticos
│   └── home/
│       └── presentation/
│           ├── home_screen.dart                  # Inicio: 1.º Guía Bíblica, 2.º Modo Corrido, 3.º Calendario
│           └── widgets/
│               ├── continue_reading_card.dart    # Tarjeta de Modo Corrido (desde Génesis 1:1)
│               ├── quick_actions_grid.dart       # Accesos rápidos
│               └── today_liturgical_card.dart    # Tarjeta litúrgica "Hoy"
├── firebase_options.dart                         # Configuración multiplataforma de Firebase (verbumv1)
└── main.dart                                     # Entrypoint con inicialización de Firebase y ProviderScope
```

---

## 🚀 Cómo Ejecutar el Proyecto

### Requisitos previos
- **Flutter SDK**: 3.x+
- **Dart SDK**: 3.x+
- Proyecto Firebase `verbumv1` con **Authentication** (Google y Correo/Contraseña habilitados) y **Cloud Firestore** activo con las reglas de `firestore.rules`.

### Ejecución en Web (Chrome — Puerto Fijo Recomendado en Windows)
Para evitar bloqueos de puertos reservados en Windows y mantener la sesión persistente en `localhost`:
```bash
flutter run -d chrome --web-hostname=localhost --web-port=7357
```

### Ejecución en Desktop (Windows)
```bash
flutter run -d windows
```

### Ejecutar Pruebas
```bash
flutter test
```

---

## 📋 Cumplimiento Legal y Licencias
- **Texto Bíblico**: Reina-Valera 1909 (RVR09), libre de derechos y en dominio público.
- **Calendario Litúrgico**: Algoritmo de cálculo propio basado en fuentes astronómicas y canónicas abiertas.
- **Privacidad y Seguridad**: Reglas de aislamiento por usuario (`request.auth.uid == userId`) en Cloud Firestore (`firestore.rules`).
