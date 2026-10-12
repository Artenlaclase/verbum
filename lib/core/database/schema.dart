/// Definición DDL del esquema de base de datos SQLite para Verbum MVP v1.1
class DatabaseSchema {
  DatabaseSchema._();

  static const int version = 1;
  static const String databaseName = 'verbum_local.db';

  // DDL de Tablas Bíblicas (RVR09)
  static const String createTableVersiones = '''
    CREATE TABLE IF NOT EXISTS versiones (
      id INTEGER PRIMARY KEY,
      codigo TEXT UNIQUE,
      nombre TEXT,
      idioma TEXT,
      licencia TEXT
    );
  ''';

  static const String createTableLibros = '''
    CREATE TABLE IF NOT EXISTS libros (
      id INTEGER PRIMARY KEY,
      version_id INTEGER,
      testamento TEXT,
      nombre TEXT,
      abreviatura TEXT,
      orden INTEGER
    );
  ''';

  static const String createTableVersiculos = '''
    CREATE TABLE IF NOT EXISTS versiculos (
      id INTEGER PRIMARY KEY,
      libro_id INTEGER,
      capitulo INTEGER,
      numero INTEGER,
      texto TEXT,
      UNIQUE(libro_id, capitulo, numero)
    );
  ''';

  static const String createIndexVersiculos = '''
    CREATE INDEX IF NOT EXISTS idx_vers_busqueda ON versiculos(libro_id, capitulo, numero);
  ''';

  // DDL de Tablas de Calendario Litúrgico
  static const String createTableTiemposLiturgicos = '''
    CREATE TABLE IF NOT EXISTS tiempos_liturgicos (
      id INTEGER PRIMARY KEY,
      nombre TEXT,
      color TEXT,
      fecha_inicio DATE,
      fecha_fin DATE,
      anio_liturgico INTEGER
    );
  ''';

  static const String createTableCelebraciones = '''
    CREATE TABLE IF NOT EXISTS celebraciones (
      id INTEGER PRIMARY KEY,
      fecha DATE,
      nombre TEXT,
      rango TEXT,
      color TEXT,
      es_movil BOOLEAN
    );
  ''';

  static const String createTableLecturasDiarias = '''
    CREATE TABLE IF NOT EXISTS lecturas_diarias (
      id INTEGER PRIMARY KEY,
      fecha DATE,
      ciclo TEXT,
      anio_par INTEGER,
      tipo TEXT,
      referencia TEXT
    );
  ''';

  // DDL de Tablas del Perfil y Estudio Personal (v1.1)
  static const String createTablePerfil = '''
    CREATE TABLE IF NOT EXISTS perfil (
      id INTEGER PRIMARY KEY,
      nombre TEXT,
      avatar TEXT,
      fecha_creacion DATETIME,
      preferencias TEXT
    );
  ''';

  static const String createTablePasajesGuardados = '''
    CREATE TABLE IF NOT EXISTS pasajes_guardados (
      id INTEGER PRIMARY KEY,
      perfil_id INTEGER,
      titulo TEXT,
      referencia_inicio TEXT,
      referencia_fin TEXT,
      libro_id INTEGER,
      capitulo_inicio INTEGER,
      versiculo_inicio INTEGER,
      capitulo_fin INTEGER,
      versiculo_fin INTEGER,
      texto_snapshot TEXT,
      etiqueta TEXT,
      color TEXT,
      fecha_guardado DATETIME
    );
  ''';

  static const String createIndexPasajesPerfil = '''
    CREATE INDEX IF NOT EXISTS idx_pasajes_perfil ON pasajes_guardados(perfil_id);
  ''';

  static const String createIndexPasajesEtiqueta = '''
    CREATE INDEX IF NOT EXISTS idx_pasajes_etiqueta ON pasajes_guardados(etiqueta);
  ''';

  static const String createTableSubrayados = '''
    CREATE TABLE IF NOT EXISTS subrayados (
      id INTEGER PRIMARY KEY,
      perfil_id INTEGER,
      versiculo_id INTEGER,
      color TEXT,
      fecha_creacion DATETIME
    );
  ''';

  static const String createTableNotas = '''
    CREATE TABLE IF NOT EXISTS notas (
      id INTEGER PRIMARY KEY,
      perfil_id INTEGER,
      versiculo_id INTEGER,
      contenido TEXT,
      fecha_creacion DATETIME,
      fecha_modificacion DATETIME
    );
  ''';

  static const String createTableFavoritos = '''
    CREATE TABLE IF NOT EXISTS favoritos (
      id INTEGER PRIMARY KEY,
      perfil_id INTEGER,
      versiculo_id INTEGER,
      etiqueta TEXT
    );
  ''';

  static const String createTableMarcadorLectura = '''
    CREATE TABLE IF NOT EXISTS marcador_lectura (
      id INTEGER PRIMARY KEY,
      perfil_id INTEGER UNIQUE,
      libro_id INTEGER,
      capitulo INTEGER,
      versiculo INTEGER,
      modo TEXT,
      fecha_actualizacion DATETIME
    );
  ''';

  static const String createTableHistorialLectura = '''
    CREATE TABLE IF NOT EXISTS historial_lectura (
      id INTEGER PRIMARY KEY,
      perfil_id INTEGER,
      libro_id INTEGER,
      capitulo INTEGER,
      versiculo_inicio INTEGER,
      versiculo_fin INTEGER,
      fecha DATETIME
    );
  ''';

  static const String createIndexHistorialPerfil = '''
    CREATE INDEX IF NOT EXISTS idx_historial_perfil ON historial_lectura(perfil_id, fecha DESC);
  ''';

  static List<String> get allCreateTableStatements => [
    createTableVersiones,
    createTableLibros,
    createTableVersiculos,
    createIndexVersiculos,
    createTableTiemposLiturgicos,
    createTableCelebraciones,
    createTableLecturasDiarias,
    createTablePerfil,
    createTablePasajesGuardados,
    createIndexPasajesPerfil,
    createIndexPasajesEtiqueta,
    createTableSubrayados,
    createTableNotas,
    createTableFavoritos,
    createTableMarcadorLectura,
    createTableHistorialLectura,
    createIndexHistorialPerfil,
  ];
}
