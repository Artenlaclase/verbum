class BibleVerseRange {
  final int startChapter;
  final int? startVerse;
  final int endChapter;
  final int? endVerse;

  const BibleVerseRange({
    required this.startChapter,
    this.startVerse,
    required this.endChapter,
    this.endVerse,
  });

  /// Retorna si el rango cubre un solo versículo específico
  bool get isSingleVerse =>
      startChapter == endChapter &&
      startVerse != null &&
      (endVerse == null || endVerse == startVerse);

  /// Retorna si el rango cubre un capítulo completo
  bool get isFullChapter => startVerse == null && endVerse == null;

  @override
  String toString() {
    if (isFullChapter) return 'Cap $startChapter';
    if (startChapter == endChapter) {
      if (endVerse != null && endVerse != startVerse) {
        return '$startChapter:$startVerse-$endVerse';
      }
      return '$startChapter:$startVerse';
    }
    return '$startChapter:$startVerse-$endChapter:$endVerse';
  }
}

class ParsedBibleReference {
  final String bookQuery;
  final List<BibleVerseRange> ranges;

  ParsedBibleReference({
    required this.bookQuery,
    List<BibleVerseRange>? ranges,
    int? chapter,
    int? startVerse,
    int? endVerse,
  }) : ranges = ranges ??
            [
              BibleVerseRange(
                startChapter: chapter ?? 1,
                startVerse: startVerse,
                endChapter: chapter ?? 1,
                endVerse: endVerse,
              )
            ];

  // Retrocompatibilidad con el parser previo
  int get chapter => ranges.isNotEmpty ? ranges.first.startChapter : 1;
  int? get startVerse => ranges.isNotEmpty ? ranges.first.startVerse : null;
  int? get endVerse => ranges.isNotEmpty ? ranges.first.endVerse : null;

  @override
  String toString() {
    if (ranges.isEmpty) return bookQuery;
    final first = ranges.first;
    if (first.startVerse == null) return '$bookQuery ${first.startChapter}';
    if (first.endVerse != null && first.endVerse != first.startVerse) {
      if (first.startChapter != first.endChapter) {
        return '$bookQuery ${first.startChapter}:${first.startVerse}-${first.endChapter}:${first.endVerse}';
      }
      return '$bookQuery ${first.startChapter}:${first.startVerse}-${first.endVerse}';
    }
    return '$bookQuery ${first.startChapter}:${first.startVerse}';
  }
}

class BibleReferenceParser {
  BibleReferenceParser._();

  static ParsedBibleReference? parse(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return null;

    // Detectar libro y resto:
    // Permite nombres como "1 Cor", "1Cor", "Gál", "Salmo", "Cantar de los Cantares", etc.
    final match = RegExp(
      r'^([1-3I|II|III]?\s*[a-zA-ZáéíóúÁÉÍÓÚñÑ][a-zA-ZáéíóúÁÉÍÓÚñÑ\.\s]*?)\s*(\d.*)$',
      caseSensitive: false,
    ).firstMatch(clean);

    if (match == null) return null;

    final bookQuery = match.group(1)!.trim().replaceAll(RegExp(r'\.+$'), '');
    var rem = match.group(2)!.trim();

    // Caso 1: Solo capítulo, e.g. "Salmo 23", "Génesis 1"
    if (RegExp(r'^\d+$').hasMatch(rem)) {
      final ch = int.tryParse(rem);
      if (ch == null) return null;
      return ParsedBibleReference(
        bookQuery: bookQuery,
        ranges: [
          BibleVerseRange(
            startChapter: ch,
            startVerse: null,
            endChapter: ch,
            endVerse: null,
          ),
        ],
      );
    }

    // Si no contiene ':', pero contiene coma para separar capítulo de versículos (ej: "Jn 3, 16" o "Lucas 1, 26-38")
    if (!rem.contains(':') && rem.contains(',')) {
      final firstCommaIdx = rem.indexOf(',');
      final beforeComma = rem.substring(0, firstCommaIdx).trim();
      final afterComma = rem.substring(firstCommaIdx + 1).trim();
      if (RegExp(r'^\d+$').hasMatch(beforeComma)) {
        rem = '$beforeComma:$afterComma';
      }
    }

    final ranges = <BibleVerseRange>[];

    // Dividir por ';' si hay múltiples bloques con capítulos (ej: "4:14-16; 5:7-9")
    final blocks = rem.split(';');
    int currentChapter = 1;

    for (final rawBlock in blocks) {
      final block = rawBlock.trim();
      if (block.isEmpty) continue;

      String versesStr = block;

      // Verificar si el bloque inicia con "capitulo:"
      final colonMatch = RegExp(r'^(\d+)\s*:\s*(.*)$').firstMatch(block);
      if (colonMatch != null) {
        currentChapter = int.tryParse(colonMatch.group(1)!) ?? currentChapter;
        versesStr = colonMatch.group(2)!.trim();
      } else if (RegExp(r'^\d+$').hasMatch(block)) {
        currentChapter = int.tryParse(block) ?? currentChapter;
        ranges.add(BibleVerseRange(
          startChapter: currentChapter,
          startVerse: null,
          endChapter: currentChapter,
          endVerse: null,
        ));
        continue;
      }

      // Reemplazar puntos que separan versículos por comas (ej: "1-6. 16-18")
      versesStr = versesStr.replaceAll(RegExp(r'(?<=\d)\s*\.\s*(?=\d)'), ', ');

      // Dividir por comas los versículos/rangos dentro del capítulo
      final segments = versesStr.split(',');
      for (final rawSeg in segments) {
        final seg = rawSeg.trim();
        if (seg.isEmpty) continue;

        if (seg.contains(RegExp(r'[\-–—]'))) {
          // Es un rango con guión (ej: "22-24", "31-5:1", "5:20-6:2")
          final parts = seg.split(RegExp(r'[\-–—]'));
          if (parts.length >= 2) {
            final left = parts[0].trim();
            final right = parts[1].trim();

            int startCh = currentChapter;
            int? startV;
            int endCh = currentChapter;
            int? endV;

            if (left.contains(':')) {
              final leftParts = left.split(':');
              startCh = int.tryParse(leftParts[0].trim()) ?? currentChapter;
              startV = _parseVerseNum(leftParts[1]);
              currentChapter = startCh;
            } else {
              startV = _parseVerseNum(left);
            }

            if (right.contains(':')) {
              final rightParts = right.split(':');
              endCh = int.tryParse(rightParts[0].trim()) ?? currentChapter;
              endV = _parseVerseNum(rightParts[1]);
              currentChapter = endCh; // Actualizar capítulo para los siguientes segmentos
            } else {
              endCh = currentChapter;
              endV = _parseVerseNum(right);
            }

            if (startV != null) {
              ranges.add(BibleVerseRange(
                startChapter: startCh,
                startVerse: startV,
                endChapter: endCh,
                endVerse: endV,
              ));
            }
          }
        } else {
          // Versículo individual (ej: "16", "5", "34a")
          int ch = currentChapter;
          int? v;

          if (seg.contains(':')) {
            final parts = seg.split(':');
            ch = int.tryParse(parts[0].trim()) ?? currentChapter;
            v = _parseVerseNum(parts[1]);
            currentChapter = ch;
          } else {
            v = _parseVerseNum(seg);
          }

          if (v != null) {
            ranges.add(BibleVerseRange(
              startChapter: ch,
              startVerse: v,
              endChapter: ch,
              endVerse: null,
            ));
          }
        }
      }
    }

    if (ranges.isEmpty) return null;

    return ParsedBibleReference(
      bookQuery: bookQuery,
      ranges: ranges,
    );
  }

  static int? _parseVerseNum(String s) {
    final digits = RegExp(r'\d+').firstMatch(s)?.group(0);
    if (digits == null) return null;
    return int.tryParse(digits);
  }
}
