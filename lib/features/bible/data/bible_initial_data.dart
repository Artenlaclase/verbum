import '../models/bible_book.dart';
import '../models/bible_verse.dart';

class BibleInitialData {
  BibleInitialData._();

  static const Map<String, dynamic> versionRVR09 = {
    'id': 1,
    'codigo': 'RVR09',
    'nombre': 'Reina-Valera 1909',
    'idioma': 'es',
    'licencia': 'public-domain',
  };

  /// Lista canónica de los 66 libros de la Biblia con su número total de capítulos
  static final List<BibleBook> books = [
    // ANTIGUO TESTAMENTO (39)
    const BibleBook(id: 1, versionId: 1, testamento: 'AT', nombre: 'Génesis', abreviatura: 'Gén', orden: 1, totalCapitulos: 50),
    const BibleBook(id: 2, versionId: 1, testamento: 'AT', nombre: 'Éxodo', abreviatura: 'Éx', orden: 2, totalCapitulos: 40),
    const BibleBook(id: 3, versionId: 1, testamento: 'AT', nombre: 'Levítico', abreviatura: 'Lev', orden: 3, totalCapitulos: 27),
    const BibleBook(id: 4, versionId: 1, testamento: 'AT', nombre: 'Números', abreviatura: 'Núm', orden: 4, totalCapitulos: 36),
    const BibleBook(id: 5, versionId: 1, testamento: 'AT', nombre: 'Deuteronomio', abreviatura: 'Dt', orden: 5, totalCapitulos: 34),
    const BibleBook(id: 6, versionId: 1, testamento: 'AT', nombre: 'Josué', abreviatura: 'Jos', orden: 6, totalCapitulos: 24),
    const BibleBook(id: 7, versionId: 1, testamento: 'AT', nombre: 'Jueces', abreviatura: 'Jue', orden: 7, totalCapitulos: 21),
    const BibleBook(id: 8, versionId: 1, testamento: 'AT', nombre: 'Rut', abreviatura: 'Rut', orden: 8, totalCapitulos: 4),
    const BibleBook(id: 9, versionId: 1, testamento: 'AT', nombre: '1 Samuel', abreviatura: '1 Sam', orden: 9, totalCapitulos: 31),
    const BibleBook(id: 10, versionId: 1, testamento: 'AT', nombre: '2 Samuel', abreviatura: '2 Sam', orden: 10, totalCapitulos: 24),
    const BibleBook(id: 11, versionId: 1, testamento: 'AT', nombre: '1 Reyes', abreviatura: '1 Re', orden: 11, totalCapitulos: 22),
    const BibleBook(id: 12, versionId: 1, testamento: 'AT', nombre: '2 Reyes', abreviatura: '2 Re', orden: 12, totalCapitulos: 25),
    const BibleBook(id: 13, versionId: 1, testamento: 'AT', nombre: '1 Crónicas', abreviatura: '1 Cró', orden: 13, totalCapitulos: 29),
    const BibleBook(id: 14, versionId: 1, testamento: 'AT', nombre: '2 Crónicas', abreviatura: '2 Cró', orden: 14, totalCapitulos: 36),
    const BibleBook(id: 15, versionId: 1, testamento: 'AT', nombre: 'Esdras', abreviatura: 'Esd', orden: 15, totalCapitulos: 10),
    const BibleBook(id: 16, versionId: 1, testamento: 'AT', nombre: 'Nehemías', abreviatura: 'Neh', orden: 16, totalCapitulos: 13),
    const BibleBook(id: 17, versionId: 1, testamento: 'AT', nombre: 'Ester', abreviatura: 'Est', orden: 17, totalCapitulos: 10),
    const BibleBook(id: 18, versionId: 1, testamento: 'AT', nombre: 'Job', abreviatura: 'Job', orden: 18, totalCapitulos: 42),
    const BibleBook(id: 19, versionId: 1, testamento: 'AT', nombre: 'Salmos', abreviatura: 'Sal', orden: 19, totalCapitulos: 150),
    const BibleBook(id: 20, versionId: 1, testamento: 'AT', nombre: 'Proverbios', abreviatura: 'Prov', orden: 20, totalCapitulos: 31),
    const BibleBook(id: 21, versionId: 1, testamento: 'AT', nombre: 'Eclesiastés', abreviatura: 'Ecl', orden: 21, totalCapitulos: 12),
    const BibleBook(id: 22, versionId: 1, testamento: 'AT', nombre: 'Cantares', abreviatura: 'Cant', orden: 22, totalCapitulos: 8),
    const BibleBook(id: 23, versionId: 1, testamento: 'AT', nombre: 'Isaías', abreviatura: 'Isa', orden: 23, totalCapitulos: 66),
    const BibleBook(id: 24, versionId: 1, testamento: 'AT', nombre: 'Jeremías', abreviatura: 'Jer', orden: 24, totalCapitulos: 52),
    const BibleBook(id: 25, versionId: 1, testamento: 'AT', nombre: 'Lamentaciones', abreviatura: 'Lam', orden: 25, totalCapitulos: 5),
    const BibleBook(id: 26, versionId: 1, testamento: 'AT', nombre: 'Ezequiel', abreviatura: 'Eze', orden: 26, totalCapitulos: 48),
    const BibleBook(id: 27, versionId: 1, testamento: 'AT', nombre: 'Daniel', abreviatura: 'Dan', orden: 27, totalCapitulos: 12),
    const BibleBook(id: 28, versionId: 1, testamento: 'AT', nombre: 'Oseas', abreviatura: 'Os', orden: 28, totalCapitulos: 14),
    const BibleBook(id: 29, versionId: 1, testamento: 'AT', nombre: 'Joel', abreviatura: 'Joel', orden: 29, totalCapitulos: 3),
    const BibleBook(id: 30, versionId: 1, testamento: 'AT', nombre: 'Amós', abreviatura: 'Amós', orden: 30, totalCapitulos: 9),
    const BibleBook(id: 31, versionId: 1, testamento: 'AT', nombre: 'Abdías', abreviatura: 'Abd', orden: 31, totalCapitulos: 1),
    const BibleBook(id: 32, versionId: 1, testamento: 'AT', nombre: 'Jonás', abreviatura: 'Jon', orden: 32, totalCapitulos: 4),
    const BibleBook(id: 33, versionId: 1, testamento: 'AT', nombre: 'Miqueas', abreviatura: 'Miq', orden: 33, totalCapitulos: 7),
    const BibleBook(id: 34, versionId: 1, testamento: 'AT', nombre: 'Nahúm', abreviatura: 'Nah', orden: 34, totalCapitulos: 3),
    const BibleBook(id: 35, versionId: 1, testamento: 'AT', nombre: 'Habacuc', abreviatura: 'Hab', orden: 35, totalCapitulos: 3),
    const BibleBook(id: 36, versionId: 1, testamento: 'AT', nombre: 'Sofonías', abreviatura: 'Sof', orden: 36, totalCapitulos: 3),
    const BibleBook(id: 37, versionId: 1, testamento: 'AT', nombre: 'Hageo', abreviatura: 'Hag', orden: 37, totalCapitulos: 2),
    const BibleBook(id: 38, versionId: 1, testamento: 'AT', nombre: 'Zacarías', abreviatura: 'Zac', orden: 38, totalCapitulos: 14),
    const BibleBook(id: 39, versionId: 1, testamento: 'AT', nombre: 'Malaquías', abreviatura: 'Mal', orden: 39, totalCapitulos: 4),

    // NUEVO TESTAMENTO (27)
    const BibleBook(id: 40, versionId: 1, testamento: 'NT', nombre: 'Mateo', abreviatura: 'Mt', orden: 40, totalCapitulos: 28),
    const BibleBook(id: 41, versionId: 1, testamento: 'NT', nombre: 'Marcos', abreviatura: 'Mc', orden: 41, totalCapitulos: 16),
    const BibleBook(id: 42, versionId: 1, testamento: 'NT', nombre: 'Lucas', abreviatura: 'Lc', orden: 42, totalCapitulos: 24),
    const BibleBook(id: 43, versionId: 1, testamento: 'NT', nombre: 'Juan', abreviatura: 'Jn', orden: 43, totalCapitulos: 21),
    const BibleBook(id: 44, versionId: 1, testamento: 'NT', nombre: 'Hechos', abreviatura: 'Hch', orden: 44, totalCapitulos: 28),
    const BibleBook(id: 45, versionId: 1, testamento: 'NT', nombre: 'Romanos', abreviatura: 'Rom', orden: 45, totalCapitulos: 16),
    const BibleBook(id: 46, versionId: 1, testamento: 'NT', nombre: '1 Corintios', abreviatura: '1 Cor', orden: 46, totalCapitulos: 16),
    const BibleBook(id: 47, versionId: 1, testamento: 'NT', nombre: '2 Corintios', abreviatura: '2 Cor', orden: 47, totalCapitulos: 13),
    const BibleBook(id: 48, versionId: 1, testamento: 'NT', nombre: 'Gálatas', abreviatura: 'Gál', orden: 48, totalCapitulos: 6),
    const BibleBook(id: 49, versionId: 1, testamento: 'NT', nombre: 'Efesios', abreviatura: 'Ef', orden: 49, totalCapitulos: 6),
    const BibleBook(id: 50, versionId: 1, testamento: 'NT', nombre: 'Filipenses', abreviatura: 'Fil', orden: 50, totalCapitulos: 4),
    const BibleBook(id: 51, versionId: 1, testamento: 'NT', nombre: 'Colosenses', abreviatura: 'Col', orden: 51, totalCapitulos: 4),
    const BibleBook(id: 52, versionId: 1, testamento: 'NT', nombre: '1 Tesalonicenses', abreviatura: '1 Tes', orden: 52, totalCapitulos: 5),
    const BibleBook(id: 53, versionId: 1, testamento: 'NT', nombre: '2 Tesalonicenses', abreviatura: '2 Tes', orden: 53, totalCapitulos: 3),
    const BibleBook(id: 54, versionId: 1, testamento: 'NT', nombre: '1 Timoteo', abreviatura: '1 Tim', orden: 54, totalCapitulos: 6),
    const BibleBook(id: 55, versionId: 1, testamento: 'NT', nombre: '2 Timoteo', abreviatura: '2 Tim', orden: 55, totalCapitulos: 4),
    const BibleBook(id: 56, versionId: 1, testamento: 'NT', nombre: 'Tito', abreviatura: 'Tit', orden: 56, totalCapitulos: 3),
    const BibleBook(id: 57, versionId: 1, testamento: 'NT', nombre: 'Filemón', abreviatura: 'Flm', orden: 57, totalCapitulos: 1),
    const BibleBook(id: 58, versionId: 1, testamento: 'NT', nombre: 'Hebreos', abreviatura: 'Heb', orden: 58, totalCapitulos: 13),
    const BibleBook(id: 59, versionId: 1, testamento: 'NT', nombre: 'Santiago', abreviatura: 'Sant', orden: 59, totalCapitulos: 5),
    const BibleBook(id: 60, versionId: 1, testamento: 'NT', nombre: '1 Pedro', abreviatura: '1 Pe', orden: 60, totalCapitulos: 5),
    const BibleBook(id: 61, versionId: 1, testamento: 'NT', nombre: '2 Pedro', abreviatura: '2 Pe', orden: 61, totalCapitulos: 3),
    const BibleBook(id: 62, versionId: 1, testamento: 'NT', nombre: '1 Juan', abreviatura: '1 Jn', orden: 62, totalCapitulos: 5),
    const BibleBook(id: 63, versionId: 1, testamento: 'NT', nombre: '2 Juan', abreviatura: '2 Jn', orden: 63, totalCapitulos: 1),
    const BibleBook(id: 64, versionId: 1, testamento: 'NT', nombre: '3 Juan', abreviatura: '3 Jn', orden: 64, totalCapitulos: 1),
    const BibleBook(id: 65, versionId: 1, testamento: 'NT', nombre: 'Judas', abreviatura: 'Jud', orden: 65, totalCapitulos: 1),
    const BibleBook(id: 66, versionId: 1, testamento: 'NT', nombre: 'Apocalipsis', abreviatura: 'Apoc', orden: 66, totalCapitulos: 22),
  ];

  /// Colección representativa de versículos fundamentales RVR09 para funcionamiento inmediato
  static final List<BibleVerse> seedVerses = [
    // JUAN 1 (id 43)
    const BibleVerse(id: 1, libroId: 43, capitulo: 1, numero: 1, texto: 'EN el principio era el Verbo, y el Verbo era con Dios, y el Verbo era Dios.'),
    const BibleVerse(id: 2, libroId: 43, capitulo: 1, numero: 2, texto: 'Este era en el principio con Dios.'),
    const BibleVerse(id: 3, libroId: 43, capitulo: 1, numero: 3, texto: 'Todas las cosas por él fueron hechas; y sin él nada de lo que es hecho, fué hecho.'),
    const BibleVerse(id: 4, libroId: 43, capitulo: 1, numero: 4, texto: 'En él estaba la vida, y la vida era la luz de los hombres.'),
    const BibleVerse(id: 5, libroId: 43, capitulo: 1, numero: 5, texto: 'Y la luz en las tinieblas resplandece; mas las tinieblas no la comprendieron.'),
    const BibleVerse(id: 6, libroId: 43, capitulo: 1, numero: 14, texto: 'Y aquel Verbo fué hecho carne, y habitó entre nosotros (y vimos su gloria, gloria como del unigénito del Padre), lleno de gracia y de verdad.'),
    
    // JUAN 3 (id 43)
    const BibleVerse(id: 10, libroId: 43, capitulo: 3, numero: 1, texto: 'Y HABÍA un hombre de los Fariseos que se llamaba Nicodemo, príncipe de los Judíos.'),
    const BibleVerse(id: 11, libroId: 43, capitulo: 3, numero: 2, texto: 'Este vino á Jesús de noche, y díjole: Rabbí, sabemos que has venido de Dios por maestro; porque nadie puede hacer estas señales que tú haces, si no fuere Dios con él.'),
    const BibleVerse(id: 12, libroId: 43, capitulo: 3, numero: 3, texto: 'Respondió Jesús, y díjole: De cierto, de cierto te digo, que el que no naciere otra vez, no puede ver el reino de Dios.'),
    const BibleVerse(id: 13, libroId: 43, capitulo: 3, numero: 16, texto: 'Porque de tal manera amó Dios al mundo, que ha dado á su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.'),
    const BibleVerse(id: 14, libroId: 43, capitulo: 3, numero: 17, texto: 'Porque no envió Dios á su Hijo al mundo para que condene al mundo, mas para que el mundo sea salvo por él.'),
    const BibleVerse(id: 15, libroId: 43, capitulo: 3, numero: 18, texto: 'El que en él cree, no es condenado; mas el que no cree, ya es condenado, porque no creyó en el nombre del unigénito Hijo de Dios.'),
    const BibleVerse(id: 16, libroId: 43, capitulo: 3, numero: 19, texto: 'Y esta es la condenación: porque la luz vino al mundo, y los hombres amaron más las tinieblas que la luz; porque sus obras eran malas.'),
    const BibleVerse(id: 17, libroId: 43, capitulo: 3, numero: 20, texto: 'Porque todo aquel que hace lo malo, aborrece la luz y no viene á la luz, porque sus obras no sean redargüidas.'),
    const BibleVerse(id: 18, libroId: 43, capitulo: 3, numero: 21, texto: 'Mas el que obra verdad, viene á la luz, para que sus obras sean manifestadas que son hechas en Dios.'),

    // JUAN 5 (id 43) - Ejemplo citado en el informe: "Continuar en Juan 5:23"
    const BibleVerse(id: 30, libroId: 43, capitulo: 5, numero: 21, texto: 'Porque como el Padre levanta los muertos, y les da vida, así también el Hijo da vida á los que quiere.'),
    const BibleVerse(id: 31, libroId: 43, capitulo: 5, numero: 22, texto: 'Porque el Padre á nadie juzga, mas todo el juicio dió al Hijo;'),
    const BibleVerse(id: 32, libroId: 43, capitulo: 5, numero: 23, texto: 'Para que todos honren al Hijo como honran al Padre. El que no honra al Hijo, no honra al Padre que le envió.'),
    const BibleVerse(id: 33, libroId: 43, capitulo: 5, numero: 24, texto: 'De cierto, de cierto os digo: El que oye mi palabra, y cree al que me ha enviado, tiene vida eterna; y no vendrá á condenación, mas pasó de muerte á vida.'),

    // JUAN 14 (id 43)
    const BibleVerse(id: 40, libroId: 43, capitulo: 14, numero: 1, texto: 'NO se turbe vuestro corazón; creéis en Dios, creed también en mí.'),
    const BibleVerse(id: 41, libroId: 43, capitulo: 14, numero: 2, texto: 'En la casa de mi Padre muchas moradas hay: de otra manera yo os lo hubiera dicho: voy, pues, á preparar lugar para vosotros.'),
    const BibleVerse(id: 42, libroId: 43, capitulo: 14, numero: 6, texto: 'Jesús le dice: Yo soy el camino, y la verdad, y la vida: nadie viene al Padre, sino por mí.'),
    const BibleVerse(id: 43, libroId: 43, capitulo: 14, numero: 27, texto: 'La paz os dejo, mi paz os doy: no como el mundo la da, yo os la doy. No se turbe vuestro corazón, ni tenga miedo.'),

    // SALMO 23 (id 19)
    const BibleVerse(id: 50, libroId: 19, capitulo: 23, numero: 1, texto: 'JEHOVA es mi pastor; nada me faltará.'),
    const BibleVerse(id: 51, libroId: 19, capitulo: 23, numero: 2, texto: 'En lugares de delicados pastos me hará yacer: Junto á aguas de reposo me pastoreará.'),
    const BibleVerse(id: 52, libroId: 19, capitulo: 23, numero: 3, texto: 'Confortará mi alma; Guiárame por sendas de justicia por amor de su nombre.'),
    const BibleVerse(id: 53, libroId: 19, capitulo: 23, numero: 4, texto: 'Aunque ande en valle de sombra de muerte, No temeré mal alguno; porque tú estarás conmigo: Tu vara y tu cayado me infundirán aliento.'),
    const BibleVerse(id: 54, libroId: 19, capitulo: 23, numero: 5, texto: 'Aderezarás mesa delante de mí en presencia de mis angustiadores: Ungiste mi cabeza con aceite: mi copa está rebosando.'),
    const BibleVerse(id: 55, libroId: 19, capitulo: 23, numero: 6, texto: 'Ciertamente el bien y la misericordia me seguirán todos los días de mi vida: Y en la casa de Jehová moraré por largos días.'),

    // SALMO 91 (id 19)
    const BibleVerse(id: 60, libroId: 19, capitulo: 91, numero: 1, texto: 'EL que habita al abrigo del Altísimo, Morará bajo la sombra del Omnipotente.'),
    const BibleVerse(id: 61, libroId: 19, capitulo: 91, numero: 2, texto: 'Diré yo de Jehová: Esperanza mía, y castillo mío; Mi Dios, en él confiaré.'),
    const BibleVerse(id: 62, libroId: 19, capitulo: 91, numero: 11, texto: 'Pues que á sus ángeles mandará acerca de ti, Que te guarden en todos tus caminos.'),

    // SALMO 121 (id 19)
    const BibleVerse(id: 70, libroId: 19, capitulo: 121, numero: 1, texto: 'ALZARE mis ojos á los montes, ¿De dónde vendrá mi socorro?'),
    const BibleVerse(id: 71, libroId: 19, capitulo: 121, numero: 2, texto: 'Mi socorro viene de Jehová, Que hizo los cielos y la tierra.'),

    // GÉNESIS 1 (id 1)
    const BibleVerse(id: 80, libroId: 1, capitulo: 1, numero: 1, texto: 'EN el principio crió Dios los cielos y la tierra.'),
    const BibleVerse(id: 81, libroId: 1, capitulo: 1, numero: 2, texto: 'Y la tierra estaba desordenada y vacía, y las tinieblas estaban sobre la haz del abismo, y el Espíritu de Dios se movía sobre la haz de las aguas.'),
    const BibleVerse(id: 82, libroId: 1, capitulo: 1, numero: 3, texto: 'Y dijo Dios: Sea la luz: y fué la luz.'),
    const BibleVerse(id: 83, libroId: 1, capitulo: 1, numero: 4, texto: 'Y vio Dios que la luz era buena; y apartó Dios la luz de las tinieblas.'),
    const BibleVerse(id: 84, libroId: 1, capitulo: 1, numero: 5, texto: 'Y llamó Dios á la luz Día, y á las tinieblas llamó Noche: y fué la tarde y la mañana un día.'),

    // MATEO 5 (id 40) - Las Bienaventuranzas
    const BibleVerse(id: 90, libroId: 40, capitulo: 5, numero: 1, texto: 'Y VIENDO las gentes, subió al monte; y sentándose, se llegaron á él sus discípulos.'),
    const BibleVerse(id: 91, libroId: 40, capitulo: 5, numero: 2, texto: 'Y abriendo su boca, les enseñaba, diciendo:'),
    const BibleVerse(id: 92, libroId: 40, capitulo: 5, numero: 3, texto: 'Bienaventurados los pobres en espíritu: porque de ellos es el reino de los cielos.'),
    const BibleVerse(id: 93, libroId: 40, capitulo: 5, numero: 4, texto: 'Bienaventurados los que lloran: porque ellos recibirán consolación.'),
    const BibleVerse(id: 94, libroId: 40, capitulo: 5, numero: 5, texto: 'Bienaventurados los mansos: porque ellos recibirán la tierra por heredad.'),
    const BibleVerse(id: 95, libroId: 40, capitulo: 5, numero: 6, texto: 'Bienaventurados los que tienen hambre y sed de justicia: porque ellos serán hartos.'),
    const BibleVerse(id: 96, libroId: 40, capitulo: 5, numero: 7, texto: 'Bienaventurados los misericordiosos: porque ellos alcanzarán misericordia.'),
    const BibleVerse(id: 97, libroId: 40, capitulo: 5, numero: 8, texto: 'Bienaventurados los limpios de corazón: porque ellos verán á Dios.'),
    const BibleVerse(id: 98, libroId: 40, capitulo: 5, numero: 9, texto: 'Bienaventurados los pacificadores: porque ellos serán llamados hijos de Dios.'),

    // MATEO 6 (id 40) - El Padre Nuestro
    const BibleVerse(id: 110, libroId: 40, capitulo: 6, numero: 9, texto: 'Vosotros pues, oraréis así: Padre nuestro que estás en los cielos, santificado sea tu nombre.'),
    const BibleVerse(id: 111, libroId: 40, capitulo: 6, numero: 10, texto: 'Venga tu reino. Sea hecha tu voluntad, como en el cielo, así también en la tierra.'),
    const BibleVerse(id: 112, libroId: 40, capitulo: 6, numero: 11, texto: 'Danos hoy nuestro pan cotidiano.'),
    const BibleVerse(id: 113, libroId: 40, capitulo: 6, numero: 12, texto: 'Y perdónanos nuestras deudas, como también nosotros perdonamos á nuestros deudores.'),
    const BibleVerse(id: 114, libroId: 40, capitulo: 6, numero: 13, texto: 'Y no nos metas en tentación, mas líbranos del mal: porque tuyo es el reino, y el poder, y la gloria, por todos los siglos. Amén.'),

    // ROMANOS 8 (id 45)
    const BibleVerse(id: 130, libroId: 45, capitulo: 8, numero: 28, texto: 'Y sabemos que á los que á Dios aman, todas las cosas les ayudan á bien, es á saber, á los que conforme al propósito son llamados.'),
    const BibleVerse(id: 131, libroId: 45, capitulo: 8, numero: 31, texto: '¿Pues qué diremos á esto? Si Dios por nosotros, ¿quién contra nosotros?'),
    const BibleVerse(id: 132, libroId: 45, capitulo: 8, numero: 38, texto: 'Por lo cual estoy cierto que ni la muerte, ni la vida, ni ángeles, ni principados, ni potestades, ni lo presente, ni lo por venir,'),
    const BibleVerse(id: 133, libroId: 45, capitulo: 8, numero: 39, texto: 'Ni lo alto, ni lo bajo, ni ninguna criatura nos podrá apartar del amor de Dios, que es en Cristo Jesús Señor nuestro.'),

    // 1 CORINTIOS 13 (id 46)
    const BibleVerse(id: 140, libroId: 46, capitulo: 13, numero: 4, texto: 'La caridad es sufrida, es benigna; la caridad no tiene envidia, la caridad no hace sinrazón, no se ensorbebece;'),
    const BibleVerse(id: 141, libroId: 46, capitulo: 13, numero: 7, texto: 'Todo lo sufre, todo lo cree, todo lo espera, todo lo soporta.'),
    const BibleVerse(id: 142, libroId: 46, capitulo: 13, numero: 13, texto: 'Y ahora permanecen la fe, la esperanza, y la caridad, estas tres: empero la mayor de ellas es la caridad.'),

    // FILIPENSES 4 (id 50)
    const BibleVerse(id: 150, libroId: 50, capitulo: 4, numero: 6, texto: 'Por nada estéis afanosos; sino sean notorias vuestras peticiones delante de Dios en toda oración y ruego, con hacimiento de gracias.'),
    const BibleVerse(id: 151, libroId: 50, capitulo: 4, numero: 7, texto: 'Y la paz de Dios, que sobrepuja todo entendimiento, guardará vuestros corazones y vuestros entendimientos en Cristo Jesús.'),
    const BibleVerse(id: 152, libroId: 50, capitulo: 4, numero: 13, texto: 'Todo lo puedo en Cristo que me fortalece.'),

    // PROVERBIOS 3 (id 20)
    const BibleVerse(id: 160, libroId: 20, capitulo: 3, numero: 5, texto: 'Fíate de Jehová de todo tu corazón, Y no te apoyes en tu propia prudencia.'),
    const BibleVerse(id: 161, libroId: 20, capitulo: 3, numero: 6, texto: 'Reconócelo en todos tus caminos, Y él enderezará tus veredas.'),
  ];
}
