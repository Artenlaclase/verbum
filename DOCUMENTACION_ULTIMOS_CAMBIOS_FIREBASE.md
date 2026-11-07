# Documentación Histórica y Acumulativa de Cambios — Verbum v1.1

**Proyecto:** Verbum — Sagrada Escritura (Reina-Valera 1909) y Calendario Litúrgico  
**Proyecto Firebase:** `verbumv1`  
**Control de versiones:** Archivo incluido en `.gitignore` (documentación técnica local acumulativa).  
**Criterio de registro:** **No se borra ningún cambio previo.** Cada modificación nueva se agrega cronológicamente indicando **qué función había antes, por cuál se cambió y por qué razón**.

---

## Etapa 1: Integración con Firebase (`verbumv1`), Correo Electrónico en Firestore y Reglas de Seguridad

### 1.1. Guardado visible del Correo Electrónico en Cloud Firestore
- **Función anterior:** `FirestoreSyncService.saveProfile()` guardaba únicamente los campos del modelo local `UserProfile` (`nombre`, `avatar_id`, `tema`, `tamano_fuente`, `version_biblia`), omitiendo el correo electrónico de `FirebaseAuth`. Además, el documento raíz `users/{uid}` no tenía campos propios y aparecía en cursiva en la consola de Firebase.
- **Por cuál se cambió:** Se actualizó `FirestoreSyncService` (`lib/core/services/firestore_sync_service.dart`) con el método `_updateRootUserInfo(uid)` y la inyección explícita de `email` y `uid` tanto en el documento raíz `users/{uid}` como en `users/{uid}/data/profile`.
- **Razón del cambio:** Permitir identificar de inmediato el correo electrónico (`email`), nombre y `uid` de cada usuario directamente al abrir la colección `users` en Firebase Console.

### 1.2. Timeouts y Sincronización No Bloqueante al Iniciar Sesión
- **Función anterior:** Las llamadas a Firestore en `AuthScreen` esperaban indefinidamente (`await migrateLocalToFirestore()`) antes de cerrar la pantalla de login.
- **Por cuál se cambió:** Se agregaron `.timeout(const Duration(seconds: 4))` en todas las operaciones de red de `FirestoreSyncService` y se cambió la migración inicial a segundo plano con `unawaited()`.
- **Razón del cambio:** Evitar que el botón de inicio de sesión o registro se quede girando indefinidamente si Firestore tarda en responder o si hay latencia de red.

### 1.3. Reglas de Seguridad (`firestore.rules`)
- **Función anterior:** La base de datos de Cloud Firestore no tenía reglas publicadas para las rutas de usuario, devolviendo `[cloud_firestore/permission-denied]`.
- **Por cuál se cambió:** Se creó y publicó `firestore.rules` autorizando lectura y escritura a cada usuario autenticado sobre su propio árbol `users/{userId}/{document=**}` (`request.auth != null && request.auth.uid == userId`).
- **Razón del cambio:** Proteger la privacidad de cada usuario en la nube mientras se permite la sincronización de su perfil, marcador, pasajes, notas e historial.

---

## Etapa 2: Perfil Devocional, Modelo «Camino Abierto» vs «Custodio de la Palabra», Orden de Inicio y Modo Corrido desde Cero

### 2.1. Ocultación de Ajustes Avanzados y Definición de Límites («Camino Abierto» vs «Custodio de la Palabra»)
- **Función anterior:** La sección *Preferencias y Sistema* (cambio de tema visual, exportar e importar Relicario JSON) estaba visible para todos los usuarios y no existía una distinción entre la versión gratuita y la de sostenimiento.
- **Por cuál se cambió:**
  - Se creó la clase `VerbumPlanLimits` y el proveedor `isCustodioProvider` en `lib/core/providers/app_providers.dart`.
  - Se nombró a la experiencia gratuita **«Camino Abierto»** (lectura bíblica íntegra, Modo Corrido, Guía Bíblica y Calendario Litúrgico libres, con hasta **5 pasajes guardados** y **10 notas/subrayados**) y a la modalidad de apoyo **«Custodio de la Palabra»** (pasajes y notas ilimitados + desbloqueo de **«Ajustes del Scriptorium»**).
- **Razón del cambio:** Ocultar los ajustes avanzados de aplicación para la versión de pago y ofrecer un límite claro y atractivo para pasar a la versión de apoyo utilizando un lenguaje espiritual y devocional que no suene a negocio comercial.

### 2.2. Reordenamiento de la Pantalla de Inicio (`HomeScreen`) y Flecha en Guía Bíblica
- **Función anterior:** En `HomeScreen` aparecía el Calendario Litúrgico antes o entre las secciones, y en la Guía Bíblica Diaria (`ThematicSuggestionsWidget`) en pantallas móviles se mostraba un desvanecido con la categoría «Amistad» cortada/pegada al borde sin una flecha clara.
- **Por cuál se cambió:**
  1. En `lib/features/home/presentation/home_screen.dart` se fijó el orden:
     - **1.º Guía Bíblica para tu Día** (`ThematicSuggestionsWidget`) con insignia destacada.
     - **2.º Modo Corrido** (`ContinueReadingCard`) inmediatamente después de la Guía Bíblica.
     - **3.º Calendario Litúrgico ("Hoy")** (`TodayLiturgicalCard`).
  2. En `lib/features/thematic_suggestions/presentation/thematic_suggestions_widget.dart` se quitó el efecto que dejaba «Amistad» pegada y se dejó **únicamente el botón circular con la flecha (`›` / `‹`)** para desplazar horizontalmente las categorías en tamaño móvil.
- **Razón del cambio:** Dar protagonismo visual a la *Guía Bíblica para tu Día* al abrir la app, continuar de forma natural con el *Modo Corrido*, e indicar claramente con solo una flecha que existen más categorías temáticas en pantallas móviles.

### 2.3. Inicio del Modo Corrido Siempre en Cero (`Génesis 1:1`)
- **Función anterior:** `ContinueReadingCard` y `ContinuousReaderScreen` tenían como valores de respaldo por defecto `libroId: 43, capitulo: 5, versiculo: 21` (**Juan 5:21**), por lo que a los usuarios nuevos siempre les aparecía `Jn 5:21`.
- **Por cuál se cambió:** Se cambió el valor inicial por defecto en `ProfileRepository.getBookmark()`, `ContinueReadingCard`, `ContinuousReaderScreen` y `BibleScreen` a **`Génesis 1:1`** (`libroId: 1, capitulo: 1, versiculo: 1`, mostrando la etiqueta *«Paso 0 · Comenzar desde el principio»*), incluyendo una migración automática para limpiar el antiguo valor por defecto `43:5:21`.
- **Razón del cambio:** Asegurar que toda persona nueva que entre a la aplicación comience el Modo Corrido desde cero (`Génesis 1:1`).

---

## Etapa 3: Validación de Correo Real y Confirmación con Temporizador (`02:00`)

### 3.1. Validación Estricta de Correo y Confirmación por Enlace en 2 Minutos
- **Función anterior:** El formulario de registro solo verificaba que el texto contuviera `@` y `.`, permitiendo crear cuentas con correos inexistentes (como `arte@hjskj.cl`) y dejando la sesión abierta sin comprobar si la casilla era real.
- **Por cuál se cambió:**
  1. Se agregó `AuthService.validateEmailAddress(email)` en `lib/core/services/auth_service.dart` para validar sintaxis y estructura real de dominio/TLD, mostrando *"Ingrese un correo electrónico válido"*.
  2. Al registrarse con correo y contraseña, se envía automáticamente un correo real de verificación (`user.sendEmailVerification()`) y se abre en `AuthScreen` (`lib/features/auth/presentation/auth_screen.dart`) el diálogo `_showEmailVerificationCountdownDialog` con un **reloj en cuenta regresiva de 2 minutos (`02:00`)**.
  3. El diálogo comprueba cada 4 segundos (`checkEmailVerified()`) si el usuario pulsó el enlace recibido en su correo. Si el tiempo se agota o el usuario cancela sin confirmar, se ejecuta `cancelUnverifiedSession()`, que elimina el usuario no verificado y cierra la sesión automáticamente.
- **Razón del cambio:** Impedir el uso de correos falsos o inexistentes y garantizar que toda cuenta creada con correo electrónico pertenezca a una dirección válida y verificada dentro del tiempo límite.

---

## Etapa 4: Reorganización de Sesión, Sincronización Automática y Lista de Interesados en «Custodio de la Palabra»

### 4.1. Al Cerrar Sesión la App Vuelve a Cero y Requiere Iniciar Sesión para Guardar Estudio Personal
- **Función anterior:**
  - Al cerrar sesión en Firebase, los pasajes guardados, notas, subrayados, marcador e historial permanecían almacenados localmente en `SharedPreferences` y `SQLite`, por lo que la app seguía mostrando los datos anteriores.
  - Además, se permitía guardar pasajes o notas en modo local sin haber iniciado sesión.
- **Por cuál se cambió:**
  - Se implementó `ProfileRepository.clearLocalUserData()` en `lib/features/profile/data/profile_repository.dart`, que se ejecuta al cerrar sesión y borra los datos locales del usuario, devolviendo la app a **cero** (`Génesis 1:1`, estadísticas en `0`, pasajes e historial vacíos).
  - Se protegieron las funciones de **guardar pasajes, crear notas personales, subrayar versículos y ver/registrar historial de lectura** (`ProfileRepository`, `ChapterReaderScreen`, `SavedPassagesScreen`, `ProfileScreen`) para que soliciten iniciar sesión cuando el usuario no está autenticado.
- **Razón del cambio:** Cumplir con la reorganización de la app donde al cerrar sesión todo vuelve a cero, y donde guardar pasajes, crear notas y llevar historial de lectura requiere tener sesión iniciada.

### 4.2. Sincronización Automática al Iniciar Sesión o Crear Cuenta (Eliminación del Botón «Sincronizar ahora»)
- **Función anterior:** En `ProfileScreen` existía un botón manual **«Sincronizar ahora»** (`Icons.sync_rounded`) que el usuario debía presionar para subir o bajar sus datos de la nube.
- **Por cuál se cambió:**
  - Se eliminó el botón manual «Sincronizar ahora».
  - En `lib/core/providers/app_providers.dart`, los proveedores `userProfileProvider`, `readingStatsProvider`, `bookmarkProvider` y `savedPassagesProvider` ahora observan `ref.watch(authStateProvider)`, sincronizando y recargando los datos de forma **100% automática** apenas el usuario inicia sesión, crea su cuenta o cierra sesión.
- **Razón del cambio:** Hacer que la sincronización sea transparente y automática sin que el usuario tenga que presionar ningún botón de sincronización.

### 4.3. Aviso en «Unirme como Custodio de la Palabra» y Registro de Correos Interesados en Firestore
- **Función anterior:** Al presionar el botón **«Unirme como Custodio de la Palabra»**, se abría el diálogo `_showBecomeCustodioDialog` que activaba localmente el modo Custodio como demostración.
- **Por cuál se cambió:**
  - Se reemplazó por `_handleCustodioButtonTap` en `lib/features/profile/presentation/profile_screen.dart` y `FirestoreSyncService.registerCustodioInterest()` en `lib/core/services/firestore_sync_service.dart`.
  - Si el usuario tiene sesión iniciada, al hacer clic:
    1. Guarda automáticamente su **correo electrónico (`email`), `uid`, `nombre` y fecha/hora del clic** en Cloud Firestore (tanto en `custodio_interesados/{uid}` como en `users/{uid}` con `interesado_custodio: true` y en `users/{uid}/data/custodio_waitlist`).
    2. Muestra un diálogo informando: *«Esta función aún no está habilitada, pero te avisaremos en cuanto se pueda. Hemos registrado tu correo para contactarte prioritariamente.»*
  - Si el usuario no ha iniciado sesión, le informa que la función aún no está habilitada y lo invita a iniciar sesión para registrar su correo y avisarle en cuanto esté disponible.
- **Razón del cambio:** La función aún no está habilitada y se necesita almacenar en la base de datos los correos electrónicos de las sesiones que hicieron clic en el botón para poder contactarlos cuando se habilite.

---

## Etapa 5: Simplificación de la Tarjeta de Sincronización a un Único Botón de Inicio / Cierre de Sesión

### 5.1. Reemplazo del Recuadro «Sincronización en la Nube Activa» por un Botón Único de Sesión
- **Función anterior:** En `ProfileScreen` (`lib/features/profile/presentation/profile_screen.dart`), el método `_buildCloudSyncCard` mostraba un contenedor con icono de nube, título *"Sincronización en la Nube Activa"* (o *"Modo Local (Sin sincronizar)"*), subtítulo *"Sincronización automática activa"* y dos iconos/botones de cerrar sesión, además de otro botón adicional *"Cerrar sesión de mi cuenta"* al final de la pantalla.
- **Por cuál se cambió:** Se reemplazó `_buildCloudSyncCard` (y se eliminó el botón duplicado del pie de página) por el método `_buildSessionButton(context, ref)`, que muestra **únicamente un botón limpio debajo del encabezado del perfil**:
  - Cuando no hay sesión activa: botón dorado **«Iniciar Sesión»**.
  - Cuando hay sesión activa: botón **«Cerrar Sesión»**.
- **Razón del cambio:** El recuadro de *"Sincronización en la Nube Activa"* resultaba técnico y poco claro para los usuarios; dejar únicamente un botón de inicio y cierre de sesión simplifica la pantalla y evita confusiones.

---

## Etapa 6: Habilitación de Guardar Pasajes, Notas y Subrayados en el Modo Corrido

### 6.1. Menú Interactivo por Versículo en `ContinuousReaderScreen` (Modo Corrido)
- **Función anterior:** En `ContinuousReaderScreen` (`lib/features/bible/presentation/continuous_reader_screen.dart`), los capítulos del **Modo Corrido** se renderizaban dentro de un único widget `SelectableText.rich` sin eventos de toque (`onTap`) en los versículos. Por ello, mientras el usuario leía de corrido no podía tocar un versículo para guardarlo en su perfil, ni crear una nota personal, ni subrayarlo (funciones que solo estaban en `ChapterReaderScreen`).
- **Por cuál se cambió:**
  - Se reemplazó el `SelectableText.rich` estático por un `Text.rich` interactivo donde cada versículo (tanto su número como su texto mediante `TapGestureRecognizer` y `GestureDetector`) responde al toque abriendo el menú contextual `_showVerseContextMenu(verse, bookName)`.
  - Se integraron en `ContinuousReaderScreen` los métodos `_showVerseContextMenu`, `_requireAuthForStudy`, `_buildColorDot`, `_showSavePassageDialog` y `_showAddNoteDialog`, además de la carga y visualización de subrayados (`_highlights`) por capítulo.
  - Además, se añadió en el menú la opción **«Fijar marcador de Modo Corrido aquí»** para situar el marcador exactamente en el versículo tocado.
- **Razón del cambio:** Permitir que el usuario pueda guardar pasajes favoritos, crear notas personales y subrayar versículos directamente mientras lee en el **Modo Corrido**, con las mismas reglas de sesión y sincronización automática que en el resto de la aplicación.

---

## Resumen de Archivos Modificados en el Proyecto

| Archivo | Resumen de Evolución |
| :--- | :--- |
| `lib/core/services/firestore_sync_service.dart` | Guardado de `email` y `uid` en `users/{uid}`; timeouts de 4s; `getAnnotationsCount()`; `registerCustodioInterest()` para guardar correos interesados en *Custodio de la Palabra*. |
| `lib/core/services/auth_service.dart` | Validación estricta `validateEmailAddress()`, envío automático de verificación por correo, `checkEmailVerified()`, `cancelUnverifiedSession()` y mensajes claros en español. |
| `lib/features/auth/presentation/auth_screen.dart` | Migración no bloqueante, inicio de sesión automático si el correo ya existe, y diálogo con cuenta regresiva de 2 minutos (`02:00`) para confirmar correos reales. |
| `lib/features/profile/data/profile_repository.dart` | Marcador inicial en `Génesis 1:1`; `clearLocalUserData()` para volver a cero al cerrar sesión; requisito de sesión activa para guardar pasajes, notas, subrayados e historial. |
| `lib/core/providers/app_providers.dart` | Proveedores conectados reactivamente a `authStateProvider` (sincronización automática) y límites `VerbumPlanLimits`. |
| `lib/features/profile/presentation/profile_screen.dart` | Reemplazo de la tarjeta de sincronización por un único botón de *Iniciar Sesión / Cerrar Sesión*; aviso y guardado de correo en *Unirme como Custodio de la Palabra*; ocultación de *Ajustes del Scriptorium*. |
| `lib/features/profile/presentation/saved_passages_screen.dart` | Solicitud de inicio de sesión cuando el usuario no está autenticado. |
| `lib/features/bible/presentation/chapter_reader_screen.dart` | Solicitud de inicio de sesión para guardar pasajes, notas o subrayados en lectura por capítulos. |
| `lib/features/bible/presentation/continuous_reader_screen.dart` | Cambio de texto estático a versículos interactivos en *Modo Corrido* para permitir guardar pasajes, añadir notas, subrayar y fijar marcador por versículo. |
| `lib/features/home/presentation/home_screen.dart` | Orden en Inicio: 1.º Guía Bíblica para tu Día, 2.º Modo Corrido (`Génesis 1:1`), 3.º Calendario Litúrgico. |
| `lib/features/home/presentation/widgets/continue_reading_card.dart` | Respaldo inicial en `Génesis 1:1` (Paso 0). |
| `lib/features/thematic_suggestions/presentation/thematic_suggestions_widget.dart` | Botón circular de flecha (`›` / `‹`) en móvil sin dejar la categoría «Amistad» cortada. |
| `firestore.rules` | Reglas de seguridad para `users/{userId}` y `custodio_interesados/{docId}`. |
| `README.md` | Actualización integral de funcionalidades, arquitectura con Firebase (`verbumv1`), modelo *Camino Abierto / Custodio de la Palabra* y comandos de ejecución. |
| `web/favicon.svg`, `web/favicon.png`, `web/icons/*`, `web/index.html` | Cambio del favicon por defecto de Flutter por un librito sagrado dorado con cruz y cinta marcadora. |

---

## Etapa 7: Actualización Integral del `README.md`

### 7.1. Puesta al Día de la Documentación Principal (`README.md`)
- **Función anterior:** El archivo `README.md` describía únicamente el alcance inicial 100% local sin backend (*"Sin backend en el MVP"*), omitiendo la integración con Firebase (`verbumv1`), la Guía Bíblica Diaria, la verificación de correo con temporizador, el modelo *Camino Abierto / Custodio de la Palabra* y las acciones de estudio dentro del Modo Corrido.
- **Por cuál se cambió:** Se actualizó `README.md` incorporando todas las funcionalidades actuales de Verbum v1.1 (orden del Inicio con Guía Bíblica → Modo Corrido en `Génesis 1:1` → Calendario Litúrgico, estudio interactivo por versículo en Modo Corrido, autenticación Firebase con verificación en `02:00`, sincronización automática, reinicio a cero al cerrar sesión, lista de interesados en *Custodio de la Palabra*, árbol completo de archivos y comando de ejecución web en el puerto `7357`).
- **Razón del cambio:** Mantener el `README.md` del repositorio alineado con el estado real y completo de la aplicación.

---

## Etapa 8: Reemplazo del Favicon por Defecto de Flutter por un Librito Sagrado

### 8.1. Nuevo Favicon e Iconos Web de Verbum (`web/favicon.svg`, `web/favicon.png` y `web/index.html`)
- **Función anterior:** La aplicación web mostraba en la pestaña del navegador el icono azul por defecto de Flutter (`web/favicon.png` e `icons/Icon-*.png`) y además incluía una etiqueta `<meta name="viewport">` manual en `web/index.html` que generaba una advertencia en consola al iniciar Flutter Web.
- **Por cuál se cambió:**
  - Se creó el icono vectorial [`web/favicon.svg`](file:///c:/proyectos/Verbumv1/web/favicon.svg) y se regeneraron [`web/favicon.png`](file:///c:/proyectos/Verbumv1/web/favicon.png) y los iconos PWA (`web/icons/Icon-192.png`, `Icon-512.png`, `Icon-maskable-192.png`, `Icon-maskable-512.png`) con el diseño de un **librito sagrado abierto** con cubierta dorada (`#C9A227`), páginas color pergamino, líneas de escritura, una pequeña cruz dorada y cinta marcadora roja.
  - Se actualizó [`web/index.html`](file:///c:/proyectos/Verbumv1/web/index.html) para cargar `favicon.svg?v=2` y `favicon.png?v=2` (evitando caché antigua del navegador) y se retiró la etiqueta `<meta name="viewport">` redundante.
- **Razón del cambio:** Dar identidad visual propia a Verbum en la pestaña del navegador y marcadores web mediante un librito acorde con la temática bíblica en lugar del logotipo genérico de Flutter.

### 8.2. Corrección de Caché del Favicon en Producción (`https://verbum-v1.vercel.app/`)
- **Función anterior:** En `web/index.html` solo se referenciaban rutas externas (`favicon.svg?v=2` y `favicon.png?v=2`), faltaba `web/favicon.ico` (que los navegadores solicitan en la raíz del dominio) y en `vercel.json` no había cabeceras `no-cache` para los iconos ni `manifest.json`, haciendo que el Service Worker de Flutter y el caché de Chrome/Vercel siguieran mostrando el antiguo icono azul de Flutter.
- **Por cuál se cambió:**
  - Se incrustó el SVG del librito sagrado directamente como **`data:image/svg+xml` inline** en la etiqueta `<link rel="icon">` de [`web/index.html`](file:///c:/proyectos/Verbumv1/web/index.html) (lo que evita cualquier sub-petición en caché).
  - Se generó [`web/favicon.ico`](file:///c:/proyectos/Verbumv1/web/favicon.ico) para peticiones directas a `/favicon.ico`.
  - Se actualizaron [`web/manifest.json`](file:///c:/proyectos/Verbumv1/web/manifest.json) (`?v=3`) y [`vercel.json`](file:///c:/proyectos/Verbumv1/vercel.json) añadiendo `Cache-Control: no-cache, no-store, must-revalidate` para `/favicon.(ico|svg|png)` y `/manifest.json`.
- **Razón del cambio:** Forzar que en el dominio desplegado en Vercel (`https://verbum-v1.vercel.app/`) el navegador muestre inmediatamente el librito de Verbum sin depender de que el usuario borre manualmente el caché de favicons o el Service Worker de Chrome.

---

## Etapa 9: Corrección de Bloqueo de Navegación en Móvil tras Crear Sesión y Cerrar Sesión

### 9.1. Protección contra Doble/Triple `Navigator.pop()` en el Diálogo de Verificación y `AuthScreen`
- **Función anterior:** En `_showEmailVerificationCountdownDialog` ([`lib/features/auth/presentation/auth_screen.dart`](file:///c:/proyectos/Verbumv1/lib/features/auth/presentation/auth_screen.dart)), tanto el temporizador `pollTimer` (cada 4s) como el botón *"Ya confirmé mi correo"* llamaban directamente a `Navigator.of(dialogCtx).pop(true)` sin un cerrojo de cierre único (`dialogClosed`). En celulares, al volver desde la app de correo después de confirmar el enlace, ambas comprobaciones podían resolverse casi al mismo tiempo y ejecutar `Navigator.pop()` dos veces (cerrando el diálogo y `AuthScreen`), tras lo cual `_handleEmailAuth` ejecutaba un tercer `Navigator.of(context).pop(true)` que hacía `pop` sobre la ruta raíz (`HomeScreen`), dejando la barra inferior (`BottomNavigationBar`) inoperante.
- **Por cuál se cambió:**
  - Se implementó el cierre único `closeDialog(bool verified)` con banderas `dialogClosed` y `pollInFlight`, más el método seguro `_closeAuthScreen([bool? result])` con bandera `_hasClosedAuthScreen`, verificación `Navigator.of(context).canPop()` y cierre previo del teclado virtual (`FocusManager.instance.primaryFocus?.unfocus()`).
- **Razón del cambio:** Impedir que una confirmación concurrente en móvil haga `pop` de más sobre la pila de navegación y bloquee la pantalla principal.

### 9.2. Proveedor Global de Pestañas (`homeTabIndexProvider`), Botón de Retorno a Inicio y Regreso Automático al Cerrar Sesión
- **Función anterior:**
  - `HomeScreen` manejaba la pestaña activa con una variable privada local (`int _currentIndex = 0`) sin `PopScope`.
  - En `ProfileScreen`, al pulsar *"Mis Pasajes Guardados"* se hacía `Navigator.push` de una pantalla sin barra inferior, y al cerrar sesión (`_confirmSignOut`) el usuario permanecía en la pantalla de Perfil sin regresar a Inicio.
  - Además, las pestañas secundarias (`Perfil`, `Guardados`, `Biblia`, `Calendario`) no contaban con flecha superior para volver a `Inicio`.
- **Por cuál se cambió:**
  - Se creó `homeTabIndexProvider` (`HomeTabIndexNotifier`) en [`lib/core/providers/app_providers.dart`](file:///c:/proyectos/Verbumv1/lib/core/providers/app_providers.dart).
  - En [`lib/features/home/presentation/home_screen.dart`](file:///c:/proyectos/Verbumv1/lib/features/home/presentation/home_screen.dart) se envolvió el `Scaffold` en un `PopScope(canPop: false)` (que impide que la ruta raíz sea extraída por error y hace que el botón Atrás del celular regrese a `Inicio`) y se envolvió el `BottomNavigationBar` en `SafeArea(top: false)`.
  - En [`lib/features/profile/presentation/profile_screen.dart`](file:///c:/proyectos/Verbumv1/lib/features/profile/presentation/profile_screen.dart), al cerrar sesión se llama automáticamente a `ref.read(homeTabIndexProvider.notifier).setTab(0)` para llevar al usuario de inmediato a **Inicio**, y se añadió flecha superior de retorno a **Inicio** en `ProfileScreen`, `SavedPassagesScreen`, `BibleScreen` y `CalendarScreen`.
- **Razón del cambio:** Garantizar que el usuario siempre pueda cambiar de pestaña o volver a **Inicio** desde cualquier lugar en dispositivos móviles y que al cerrar sesión la app regrese automáticamente al Inicio en cero.

### 9.3. Limpieza del Contenedor de Carga y Ajuste de Viewport Móvil en `web/index.html`
- **Función anterior:** En [`web/index.html`](file:///c:/proyectos/Verbumv1/web/index.html), `body` usaba `display: flex; height: 100vh; width: 100vw;` y el `<div id="loading-container">` nunca se eliminaba del DOM al iniciar Flutter. En navegadores móviles, al abrirse y cerrarse el teclado virtual durante el registro, el desplazamiento del viewport y `100vh` desfasaban el área táctil inferior donde se ubica el `BottomNavigationBar`.
- **Por cuál se cambió:** Se configuró `html, body` con `width: 100%; height: 100%; overflow: hidden; overscroll-behavior: none;`, se pasó `#loading-container` a `position: fixed; inset: 0;`, se eliminó automáticamente del DOM en el evento `flutter-first-frame`, y se añadió restauración automática `window.scrollTo(0, 0)` al cerrar el teclado móvil (`focusout`).
- **Razón del cambio:** Asegurar que en navegadores de celulares los botones inferiores (`Inicio, Biblia, Calendario, Guardados, Perfil`) reciban siempre los toques con precisión tras usar el teclado virtual.

---

## Etapa 10: Implementación del Foro Exclusivo para Personas con Sesión Iniciada

### 10.3. Integración del Foro en la Barra Inferior y Eliminación del Bloque "Explorar Verbum"
- **Función anterior:** El acceso al foro se había colocado como un botón dentro de la rejilla de baldosas *"Explorar Verbum"* en la pantalla de inicio ([`HomeScreen`](file:///c:/proyectos/Verbumv1/lib/features/home/presentation/home_screen.dart)). La barra inferior (`BottomNavigationBar`) solo contaba con 5 pestañas (*Inicio, Biblia, Calendario, Guardados, Perfil*).
- **Por cuál se cambió:**
  1. Se eliminó el bloque de baldosas *"Explorar Verbum"* (`QuickActionsGrid`) de la pantalla de inicio, dejando un flujo mucho más limpio: **Guía Bíblica Diaria → Modo Corrido → Calendario Litúrgico Hoy → Cita Devocional**.
  2. Se integró la pestaña **Foro** (`Icons.forum_rounded`) directamente en la barra de navegación inferior (`BottomNavigationBar`), actualizando `HomeTabIndexNotifier` a 6 pestañas:
     - `0`: Inicio
     - `1`: Biblia
     - `2`: Calendario
     - `3`: Guardados
     - `4`: Foro
     - `5`: Perfil
  3. Se adaptó la flecha superior de `ForumScreen` para volver a `Inicio` (`ref.read(homeTabIndexProvider.notifier).setTab(0)`).
- **Razón del cambio:** Simplificar visualmente la pantalla de inicio quitando baldosas redundantes y dando al Foro un acceso directo, visible y accesible en cualquier momento desde la barra inferior de navegación.

---

## Etapa 11: Dinamización del Leccionario y Lecturas Diarias del Calendario Litúrgico

### 11.1. Asignación Dinámica de Lecturas Diarias por Semana, Día y Ciclo Ferial/Dominical
- **Función anterior:** En [`lib/features/liturgical_calendar/data/liturgical_calculator.dart`](file:///c:/proyectos/Verbumv1/lib/features/liturgical_calendar/data/liturgical_calculator.dart), el método `_getOrdinaryReadings` devolvía siempre una lista estática e invariable (`Gál 4:22-24, 26-27, 31-5:1`, `Sal 113:1-7`, `Lc 11:29-32`) para cualquier día del Tiempo Ordinario. Por esta razón, sin importar la fecha seleccionada o los días transcurridos, las citas bíblicas de la tarjeta *Hoy* y del *Calendario Litúrgico* eran siempre las mismas.
- **Por cuál se cambió:**
  1. Se creó el leccionario dinámico [`lib/features/liturgical_calendar/data/liturgical_readings_data.dart`](file:///c:/proyectos/Verbumv1/lib/features/liturgical_calendar/data/liturgical_readings_data.dart) con el método `getOrdinaryDailyReadings`.
  2. Las lecturas ahora cambian de manera real día tras día en función de:
     - **El día de la semana (Lunes a Domingo):** Los domingos presentan 4 lecturas según el ciclo dominical (**A, B o C**).
     - **El ciclo ferial anual:** Año impar (Ciclo I) o año par (Ciclo II) para la 1ª Lectura y Salmo responsorial.
     - **El curso continuo del Evangelio:** San Marcos (semanas 1-9), San Mateo (semanas 10-21) y San Lucas (semanas 22-34).
     - **La semana específica del Tiempo Ordinario** (semanas 1 a 34).
- **Razón del cambio:** Corregir el leccionario estático para que cada día del año muestre sus lecturas litúrgicas correspondientes de la Iglesia Católica y cambien diariamente al avanzar la semana y al navegar por los días del calendario.

---

## Etapa 12: Sistema Universal para Compartir Versículos y Pasajes Bíblicos

### 12.2. Corrección del Modificador `static` en `ShareService`
- **Función anterior:** El método auxiliar `_buildShareAction` en [`lib/core/services/share_service.dart`](file:///c:/proyectos/Verbumv1/lib/core/services/share_service.dart) no tenía la palabra clave `static`, lo que impedía que los métodos estáticos `shareVerse` y `_showShareModal` pudieran invocarlo, generando el error de compilación `Method not found: '_buildShareAction'`.
- **Por cuál se cambió:** Se declaró como `static Widget _buildShareAction(...)`.
- **Razón del cambio:** Permitir la compilación limpia de la aplicación en Flutter Web y Desktop.
- **Función anterior:** Las personas que leían la Biblia, revisaban las lecturas diarias o consultaban sus pasajes guardados solo disponían de la opción simple de copiar texto plano en el portapapeles (`Clipboard.setData`). No existía un diálogo devocional para compartir en redes, WhatsApp o llevar el texto directamente al Foro Verbum.
- **Por cuál se cambió:**
  1. Se implementó [`lib/core/services/share_service.dart`](file:///c:/proyectos/Verbumv1/lib/core/services/share_service.dart) con el método `ShareService.shareVerse(...)`.
  2. Al compartir, se genera un formato solemne de cita:  
     *«[Texto del versículo]» — [Cita Bíblica] (RVR09) · Compartido desde Verbum: Sagrada Escritura y Liturgia*.
  3. Despliega un menú inferior con tres opciones inmediatas:
     - **Copiar:** Copia el pasaje formateado para pegar en cualquier aplicación.
     - **WhatsApp:** Prepara el texto listo para enviar a grupos o contactos de fe.
     - **En el Foro Verbum:** Abre el Foro Fraterno para iniciar una reflexión o conversación comunitaria en torno al versículo seleccionado.
  4. Se integró el botón y opción de compartir en:
     - Lector por Capítulos ([`ChapterReaderScreen`](file:///c:/proyectos/Verbumv1/lib/features/bible/presentation/chapter_reader_screen.dart)).
     - Modo Corrido ([`ContinuousReaderScreen`](file:///c:/proyectos/Verbumv1/lib/features/bible/presentation/continuous_reader_screen.dart)).
     - Resultados de Búsqueda y Lecturas Diarias ([`SearchScreen`](file:///c:/proyectos/Verbumv1/lib/features/bible/presentation/search_screen.dart)).
     - Mis Pasajes Guardados ([`SavedPassagesScreen`](file:///c:/proyectos/Verbumv1/lib/features/profile/presentation/saved_passages_screen.dart)).
- **Razón del cambio:** Facilitar que los lectores puedan evangelizar, enviar la Palabra por mensajería y abrir temas de reflexión comunitaria en el Foro a partir de cualquier versículo seleccionado.
- **Función anterior:** En [`lib/features/forum/data/forum_repository.dart`](file:///c:/proyectos/Verbumv1/lib/features/forum/data/forum_repository.dart) el import a `auth_service.dart` tenía dos niveles hacia arriba (`../../core/services/auth_service.dart`), lo que fallaba al compilar porque la carpeta `data` se encuentra a tres niveles de `lib/`.
- **Por cuál se cambió:** Se corrigió a `import '../../../core/services/auth_service.dart';`.
- **Razón del cambio:** Corregir el error de compilación en `flutter run` para resolver adecuadamente la clase `AuthService`.
- **Función anterior:** La aplicación no contaba con un espacio comunitario o foro para compartir reflexiones, peticiones de oración, testimonios o preguntas bíblicas entre usuarios.
- **Por cuál se cambió:**
  1. Se crearon los modelos `ForumTopic` y `ForumReply` en [`lib/features/forum/models/forum_models.dart`](file:///c:/proyectos/Verbumv1/lib/features/forum/models/forum_models.dart) con campos para autor, avatar, categoría, fecha, respuestas y bendiciones (likes).
  2. Se desarrolló [`lib/features/forum/data/forum_repository.dart`](file:///c:/proyectos/Verbumv1/lib/features/forum/data/forum_repository.dart) con sincronización en tiempo real vía Cloud Firestore (`forum_topics` y subcolección `replies`), soportando filtrado por categorías, creación de temas, respuestas y alternar bendición/me gusta.
  3. Se diseñó [`lib/features/forum/presentation/forum_screen.dart`](file:///c:/proyectos/Verbumv1/lib/features/forum/presentation/forum_screen.dart):
     - **Si el usuario no ha iniciado sesión:** Muestra una vista solemne informativa con botón directo para *Iniciar Sesión / Crear Cuenta*, bloqueando el acceso al contenido.
     - **Si el usuario tiene sesión activa:** Acceso pleno a los temas, creación de nuevas publicaciones y lectura fraterna.
  4. Se implementó la vista detallada [`lib/features/forum/presentation/topic_detail_screen.dart`](file:///c:/proyectos/Verbumv1/lib/features/forum/presentation/topic_detail_screen.dart) con hilo de respuestas en tiempo real y opción de eliminar tema propio.
  5. Se actualizaron las reglas en [`firestore.rules`](file:///c:/proyectos/Verbumv1/firestore.rules) para autorizar lectura, creación y respuestas únicamente a usuarios autenticados (`request.auth != null`).
  6. Se añadieron accesos directos al foro tanto en la rejilla de *Explorar Verbum* en Inicio ([`QuickActionsGrid`](file:///c:/proyectos/Verbumv1/lib/features/home/presentation/widgets/quick_actions_grid.dart)) como en la tarjeta de *Mi Estudio Personal* en [`ProfileScreen`](file:///c:/proyectos/Verbumv1/lib/features/profile/presentation/profile_screen.dart).
- **Razón del cambio:** Habilitar un canal comunitario de edificación y oración restringido de forma segura únicamente a personas que hayan iniciado sesión.

---

## Etapa 13: Eliminación de Requisito de Índice Compuesto en Foro y Aumento de Timeout en Sincronización Web

### 13.1. Ordenamiento en Memoria de Temas del Foro (`ForumRepository`)
- **Función anterior:** En [`lib/features/forum/data/forum_repository.dart`](file:///c:/proyectos/Verbumv1/lib/features/forum/data/forum_repository.dart), el método `getTopicsStream({String? categoria})` encadenaba `.orderBy('fecha_creacion', descending: true)` junto con `.where('categoria', isEqualTo: categoria)`. Al filtrar por una categoría específica (como *Testimonios*, *Oración*, etc.), Cloud Firestore requería un índice compuesto en la nube (`categoria ASC, fecha_creacion DESC`), arrojando el error en pantalla `[cloud_firestore/failed-precondition] The query requires an index`.
- **Por cuál se cambió:** Se desacopló la consulta: si se selecciona una categoría, Firestore realiza la búsqueda directa mediante `.where('categoria', isEqualTo: categoria)` (soportada de forma nativa por el índice simple predeterminado de Firestore), y la lista de documentos se ordena en memoria (`list.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion))`). Cuando la categoría es `'Todos'`, se delega directamente a `.orderBy('fecha_creacion', descending: true)`.
- **Razón del cambio:** Permitir que los usuarios filtren temas por categoría de forma inmediata y en tiempo real sin requerir la creación manual de índices compuestos en la consola de Firebase.

### 13.2. Aumento de Timeout de Sincronización a 10 Segundos y Protección en Pasajes Guardados
- **Función anterior:** En [`lib/core/services/firestore_sync_service.dart`](file:///c:/proyectos/Verbumv1/lib/core/services/firestore_sync_service.dart), la constante de tiempo de espera era `static const Duration _timeout = Duration(seconds: 4);`. Durante el arranque inicial en navegadores web (Chrome), el establecimiento del WebSocket/canal seguro y la autenticación asíncrona tardaban más de 4 segundos, arrojando advertencias en consola `TimeoutException after 0:00:04.000000: Future not completed`. Adicionalmente, `getSavedPassages({String? etiqueta})` combinaba `.orderBy('fecha_guardado')` con `.where('etiqueta')`.
- **Por cuál se cambió:** Se incrementó `_timeout` a `10 segundos` para conceder suficiente margen de red a la inicialización de Firebase Web sin interrumpir la experiencia de usuario, y se ajustó `getSavedPassages` para ordenar en memoria al filtrar por etiquetas.
- **Razón del cambio:** Eliminar advertencias y errores de tiempo de espera (`TimeoutException`) durante el inicio en web y garantizar estabilidad en la lectura y guardado de datos en la nube.
