import '../models/thematic_suggestion.dart';

class ThematicSuggestionsRepository {
  ThematicSuggestionsRepository._();

  static final ThematicSuggestionsRepository instance =
      ThematicSuggestionsRepository._();

  /// Retorna las 5 sugerencias temáticas correspondientes al día especificado (hoy por defecto)
  List<ThematicReadingSuggestion> getDailySuggestions({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final dayOfYear = targetDate.difference(DateTime(targetDate.year, 1, 1)).inDays;

    return ThematicCategoryType.values.map((type) {
      final list = _catalog[type] ?? [];
      final index = (dayOfYear + type.index * 3) % list.length;
      return list[index];
    }).toList();
  }

  /// Retorna la sugerencia diaria para una categoría específica
  ThematicReadingSuggestion getSuggestionForCategory(
    ThematicCategoryType type, {
    DateTime? date,
  }) {
    final targetDate = date ?? DateTime.now();
    final dayOfYear = targetDate.difference(DateTime(targetDate.year, 1, 1)).inDays;
    final list = _catalog[type] ?? [];
    final index = (dayOfYear + type.index * 3) % list.length;
    return list[index];
  }

  /// Catálogo de pasajes curados organizados por tema de vida
  static final Map<ThematicCategoryType, List<ThematicReadingSuggestion>> _catalog = {
    // 1. AMOR (Amor, caridad, entrega y compasión)
    ThematicCategoryType.amor: [
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amor,
        referencia: '1 Cor 13:4-8',
        lema: 'El amor nunca deja de ser',
        reflexion: 'La caridad es paciente, benigna y no busca lo suyo. Pon hoy el amor por encima de cualquier desacuerdo.',
        contexto: 'Himno al Amor del apóstol San Pablo',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amor,
        referencia: '1 Jn 4:7-12',
        lema: 'Dios es amor',
        reflexion: 'Amémonos unos a otros porque el amor procede de Dios. Quien ama ha nacido de Dios y le conoce.',
        contexto: 'Primera Epístola de San Juan',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amor,
        referencia: 'Col 3:12-14',
        lema: 'El vínculo perfecto',
        reflexion: 'Vestíos de entrañable misericordia, benignidad y humildad. Sobre todo, revestíos del amor perfecto.',
        contexto: 'Exhortación de San Pablo a los Colosenses',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amor,
        referencia: 'Jn 15:9-13',
        lema: 'Permaneced en mi amor',
        reflexion: 'Nadie tiene amor más grande que el que da la vida por sus amigos. Camina hoy en esa entrega generosa.',
        contexto: 'Discurso de Jesús sobre la vid verdadera',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amor,
        referencia: 'Rom 12:9-10',
        lema: 'Amor sin fingimiento',
        reflexion: 'Ama con sinceridad; aborrece lo malo y apégate a lo bueno, prefiriendo honrar a los demás antes que a ti.',
        contexto: 'Normas de vida cristiana en Romanos',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amor,
        referencia: '1 Pe 4:8',
        lema: 'Ferviente caridad',
        reflexion: 'Sobre todas las cosas, tened entre vosotros ferviente amor, porque el amor cubre multitud de pecados.',
        contexto: 'Primera Epístola de San Pedro',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amor,
        referencia: 'Ef 3:17-19',
        lema: 'Arraigados en el amor',
        reflexion: 'Que Cristo habite en tu corazón por la fe, para que arraigado en amor conozcas la plenitud de Dios.',
        contexto: 'Oración apostólica a los Efesios',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amor,
        referencia: '1 Jn 3:18',
        lema: 'Amor en hechos y verdad',
        reflexion: 'No amemos solo de palabra ni de labios para afuera, sino con obras tangibles y con la verdad.',
        contexto: 'Llamado a la caridad práctica',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amor,
        referencia: 'Jn 13:34-35',
        lema: 'El mandamiento nuevo',
        reflexion: 'En esto conocerán todos que sois mis discípulos: si tenéis amor y comprensión mutua.',
        contexto: 'La última cena del Señor',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amor,
        referencia: 'Cant 8:6-7',
        lema: 'Fuerte como la muerte es el amor',
        reflexion: 'Las muchas aguas no podrán apagar el amor ni lo ahogarán los ríos. El amor divino es llama eterna.',
        contexto: 'Poesía sagrada del Cantar de los Cantares',
      ),
    ],

    // 2. DINERO Y TRABAJO (Mayordomía, providencia, esfuerzo y honestidad)
    ThematicCategoryType.dinero: [
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.dinero,
        referencia: 'Mt 6:25-33',
        lema: 'Buscad primero el Reino',
        reflexion: 'No os afanéis por el sustento material; vuestro Padre celestial sabe lo que necesitáis cada día.',
        contexto: 'Sermón del Monte: Confianza en la Providencia',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.dinero,
        referencia: 'Fil 4:19',
        lema: 'Dios suplirá tus necesidades',
        reflexion: 'Mi Dios suplirá todo lo que os falta conforme a sus riquezas en gloria en Cristo Jesús.',
        contexto: 'Agradecimiento de Pablo por el socorro mutuo',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.dinero,
        referencia: 'Prov 3:9-10',
        lema: 'Honra al Creador con tus bienes',
        reflexion: 'Consagra las primicias de tu labor al Señor y tus almacenes rebosarán con fruto bendecido.',
        contexto: 'Sabiduría de los Proverbios de Salomón',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.dinero,
        referencia: '1 Tim 6:6-10',
        lema: 'Piedad con contentamiento',
        reflexion: 'Gran ganancia es la piedad satisfecha con lo suficiente; sé prudente y custodia tu corazón de la codicia.',
        contexto: 'Consejo pastoral a Timoteo',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.dinero,
        referencia: 'Lc 6:38',
        lema: 'Sembradores de generosidad',
        reflexion: 'Dad y se os dará; medida buena, apretada y rebosante se derramará en vuestro regazo.',
        contexto: 'Enseñanza evangélica sobre la generosidad',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.dinero,
        referencia: 'Prov 11:24-25',
        lema: 'El alma generosa prospera',
        reflexion: 'Hay quienes reparten con desprendimiento y les es añadido más; el que riega, él también será regado.',
        contexto: 'Proverbios sobre justicia y finanzas',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.dinero,
        referencia: 'Sal 37:23-26',
        lema: 'Pasos guiados por el Señor',
        reflexion: 'Por el Señor son ordenados los pasos del hombre recto; aun en la vejez no verá desamparada su casa.',
        contexto: 'Salmo davídico de confianza providencial',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.dinero,
        referencia: 'Prov 16:3',
        lema: 'Encomienda tus proyectos',
        reflexion: 'Pon en manos de Dios tus labores y empresas diarias, y tus planes hallarán firmeza y dirección.',
        contexto: 'Sabiduría para el trabajo cotidiano',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.dinero,
        referencia: '2 Cor 9:6-8',
        lema: 'Dios ama al dador alegre',
        reflexion: 'El que siembra generosamente segará con gozo, pues poderoso es Dios para colmarte de toda gracia.',
        contexto: 'La gracia del compartir cristiano',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.dinero,
        referencia: 'Ecl 5:18-20',
        lema: 'El gozo del trabajo honrado',
        reflexion: 'Disfrutar del fruto de las manos y acogerlo como don de Dios llena la vida con gratitud y alegría.',
        contexto: 'Eclesiastés: El valor del trabajo honesto',
      ),
    ],

    // 3. SALUD Y SANIDAD (Sanidad física, mental, alivio y fuerza)
    ThematicCategoryType.salud: [
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.salud,
        referencia: 'Jer 30:17',
        lema: 'Yo traeré sanidad para ti',
        reflexion: 'El Señor promete restaurar tu vigor y sanar tus heridas. Confía en su poder renovador hoy.',
        contexto: 'Promesas proféticas de restauración',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.salud,
        referencia: 'Sal 103:2-5',
        lema: 'El que sana todas tus dolencias',
        reflexion: 'Bendice alma mía al Señor; Él perdona tus culpas, sana tus enfermedades y rejuvenece tus fuerzas.',
        contexto: 'Himno de alabanza por la misericordia divina',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.salud,
        referencia: 'Sant 5:14-16',
        lema: 'La oración ferviente sana',
        reflexion: 'La oración confiada de la comunidad levanta al postrado y la súplica del justo obra con gran poder.',
        contexto: 'Epístola de Santiago: Atención al enfermo',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.salud,
        referencia: 'Prov 4:20-22',
        lema: 'Medicina a todo tu cuerpo',
        reflexion: 'Acoge las palabras sabias y no las apartes de tus ojos, porque son vida y salud integral para tu ser.',
        contexto: 'Instrucción paterna de la Sabiduría',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.salud,
        referencia: 'Isa 53:4-5',
        lema: 'Por sus llagas fuimos sanados',
        reflexion: 'Él cargó con nuestras debilidades y dolores para otorgarnos paz, bienestar y redención.',
        contexto: 'Canto del Siervo doliente en Isaías',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.salud,
        referencia: '3 Jn 1:2',
        lema: 'Prosperidad de alma y cuerpo',
        reflexion: 'Deseo que en todo seas prosperado y que goces de buena salud física, así como florece tu alma.',
        contexto: 'Bendición apostólica de San Juan',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.salud,
        referencia: 'Sal 41:1-3',
        lema: 'Sustento en el lecho de dolor',
        reflexion: 'El Señor acompaña al que padece, lo reconforta en su debilidad y transforma la enfermedad en fortaleza.',
        contexto: 'Salmo de socorro y misericordia',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.salud,
        referencia: 'Ex 15:26',
        lema: 'Yo soy tu Sanador',
        reflexion: 'El Señor se revela como fuente inagotable de vitalidad y guardián de quienes escuchan su voz.',
        contexto: 'Alianza en las aguas de Mara',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.salud,
        referencia: 'Sal 147:3',
        lema: 'Sana los corazones quebrantados',
        reflexion: 'Él venda las heridas invisibles del alma y repara con ternura los corazones dolidos.',
        contexto: 'Himno de alabanza al Creador bondadoso',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.salud,
        referencia: 'Mt 8:16-17',
        lema: 'Compasión que alivia',
        reflexion: 'Jesús acogió con ternura a todos los enfermos y los libró de sus pesadas cargas físicas y espirituales.',
        contexto: 'Milagros de compasión en Cafarnaúm',
      ),
    ],

    // 4. AMISTAD (Lealtad, fraternidad, buen consejo y hermandad)
    ThematicCategoryType.amistad: [
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amistad,
        referencia: 'Prov 17:17',
        lema: 'En todo tiempo ama el amigo',
        reflexion: 'Un verdadero amigo ama con constancia en la bonanza y se vuelve hermano fiel en la adversidad.',
        contexto: 'Proverbio sobre la autenticidad fraternal',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amistad,
        referencia: 'Ecl 4:9-12',
        lema: 'Mejor son dos que uno solo',
        reflexion: 'Si uno cae, el otro le levanta. Una cuerda de tres hilos no se rompe fácilmente; cultiva alianzas nobles.',
        contexto: 'Eclesiastés: El valor del compañerismo',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amistad,
        referencia: 'Prov 27:9-10',
        lema: 'El dulce consejo del amigo',
        reflexion: 'El perfume deleita el rostro, pero el consejo cordial de un amigo sincero ilumina y alegra el corazón.',
        contexto: 'Sentencias de amistad y lealtad',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amistad,
        referencia: 'Jn 15:14-15',
        lema: 'Os he llamado amigos',
        reflexion: 'Jesús nos eleva de siervos a amigos, compartiendo con nosotros el corazón del Padre. Sé amigo leal.',
        contexto: 'Palabras de Cristo en el Cenáculo',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amistad,
        referencia: '1 Sam 18:1-3',
        lema: 'Almas unidas en lealtad',
        reflexion: 'La entrañable hermandad entre David y Jonatán enseña cómo la amistad sincera trasciende intereses personales.',
        contexto: 'El pacto de amistad entre David y Jonatán',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amistad,
        referencia: 'Rom 12:15-16',
        lema: 'Empatía y un solo corazón',
        reflexion: 'Alegraos con los que se alegran y llorad con los que lloran. Vivid en profunda concordia unos con otros.',
        contexto: 'Consejos paulinos para la vida comunitaria',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amistad,
        referencia: 'Prov 18:24',
        lema: 'Amigo más unido que un hermano',
        reflexion: 'El valor de un amigo leal supera cualquier parentesco; cuida a quienes Dios ha puesto a tu lado.',
        contexto: 'Proverbios sobre relaciones humanas',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amistad,
        referencia: 'Heb 10:24-25',
        lema: 'Estímulo mutuo al bien',
        reflexion: 'Estemos atentos unos de otros para incitarnos al amor y a las buenas obras, sin descuidar el encuentro mutuo.',
        contexto: 'Epístola a los Hebreos',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amistad,
        referencia: 'Gál 6:2',
        lema: 'Sobrellevad las cargas',
        reflexion: 'Llevad los unos las cargas de los otros y cumpliréis así la ley de amor que Cristo nos encomendó.',
        contexto: 'Solidaridad cristiana en Gálatas',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.amistad,
        referencia: 'Sal 133:1-3',
        lema: 'Hermanos en perfecta armonía',
        reflexion: '¡Cuán bueno y cuán deleitoso es habitar los hermanos juntos en unidad! Allí derrama el Señor bendición.',
        contexto: 'Cántico gradual de unidad fraternal',
      ),
    ],

    // 5. DÍA CON ARMONÍA Y PAZ (Paz interior, serenidad, sosiego y serenidad cotidiana)
    ThematicCategoryType.armonia: [
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.armonia,
        referencia: 'Fil 4:6-7',
        lema: 'La paz que sobrepasa entendimiento',
        reflexion: 'Por nada estéis afanosos; presentad vuestras peticiones con acción de gracias y la paz de Dios os guardará.',
        contexto: 'La serenidad cristiana en Filipenses',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.armonia,
        referencia: 'Jn 14:27',
        lema: 'Mi paz os doy',
        reflexion: 'La paz os dejo, mi paz os doy; no os la doy como el mundo la da. No se turbe vuestro corazón ni tenga miedo.',
        contexto: 'El don de la paz de Jesucristo',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.armonia,
        referencia: 'Sal 4:8',
        lema: 'En paz me acostaré y dormiré',
        reflexion: 'En completa calma descanso y concilio el sueño, porque solo Tú, Señor, me haces vivir confiado y seguro.',
        contexto: 'Salmo vespertino de reposo en Dios',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.armonia,
        referencia: 'Isa 26:3',
        lema: 'Completa paz para el que confía',
        reflexion: 'Tú guardarás en perfecta serenidad a aquel cuyo pensamiento persevera firme en Ti, porque en Ti ha confiado.',
        contexto: 'Cántico de gozo y confianza en Judá',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.armonia,
        referencia: 'Col 3:15',
        lema: 'Que la paz gobierne tu corazón',
        reflexion: 'Que la paz de Cristo sea el árbitro en tus pensamientos y decisiones de hoy; y sed agradecidos.',
        contexto: 'La vida en Cristo según San Pablo',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.armonia,
        referencia: 'Sal 23:1-3',
        lema: 'Junto a aguas de reposo',
        reflexion: 'El Señor es mi Pastor y nada me falta; en verdes prados me apacienta y reconforta enteramente mi alma.',
        contexto: 'El Salmo de la confianza y el Pastor divino',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.armonia,
        referencia: 'Rom 15:13',
        lema: 'Llenos de gozo y paz',
        reflexion: 'Que el Dios de la esperanza os colme de alegría y sosiego en la fe, para que abundéis en esperanza.',
        contexto: 'Bendición de esperanza y serenidad',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.armonia,
        referencia: 'Mt 11:28-30',
        lema: 'Descanso para vuestra alma',
        reflexion: 'Venid a mí los fatigados y agobiados, y yo os daré descanso. Mi yugo es suave y mi carga liviana.',
        contexto: 'Invitación tierna de Jesús a los cansados',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.armonia,
        referencia: 'Sal 119:165',
        lema: 'Gran paz para los que aman la Ley',
        reflexion: 'Inmensa calma tienen quienes atesoran la verdad en el corazón; nada los hace tambalear.',
        contexto: 'La bienaventuranza de la Palabra divina',
      ),
      const ThematicReadingSuggestion(
        category: ThematicCategoryType.armonia,
        referencia: '2 Tes 3:16',
        lema: 'Paz continua en todo momento',
        reflexion: 'Que el mismo Señor de la paz os conceda serenidad en todo tiempo y circunstancia. El Señor esté con vosotros.',
        contexto: 'Despedida apostólica de bendición y sosiego',
      ),
    ],
  };
}
