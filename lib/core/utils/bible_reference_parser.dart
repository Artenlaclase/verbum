class ParsedBibleReference {
  final String bookQuery;
  final int chapter;
  final int? startVerse;
  final int? endVerse;

  const ParsedBibleReference({
    required this.bookQuery,
    required this.chapter,
    this.startVerse,
    this.endVerse,
  });

  @override
  String toString() {
    if (startVerse == null) return '$bookQuery $chapter';
    if (endVerse != null && endVerse != startVerse) {
      return '$bookQuery $chapter:$startVerse-$endVerse';
    }
    return '$bookQuery $chapter:$startVerse';
  }
}

class BibleReferenceParser {
  BibleReferenceParser._();

  /// Expresión regular que detecta formatos como:
  /// - "Jn 3:16"
  /// - "Juan 3:16-21"
  /// - "1 Cor 13:4-8"
  /// - "Sal 23"
  /// - "Génesis 1:1"
  static final RegExp _refRegex = RegExp(
    r'^([1-3]?\s*[a-zA-ZáéíóúÁÉÍÓÚñÑ]+)\s+(\d+)(?:[:,\.](\d+)(?:\s*-\s*(\d+))?)?$',
    caseSensitive: false,
  );

  static ParsedBibleReference? parse(String input) {
    final clean = input.trim();
    final match = _refRegex.firstMatch(clean);
    if (match == null) return null;

    final bookQuery = match.group(1)!.trim();
    final chapter = int.tryParse(match.group(2) ?? '');
    if (chapter == null) return null;

    final startVerse = match.group(3) != null ? int.tryParse(match.group(3)!) : null;
    final endVerse = match.group(4) != null ? int.tryParse(match.group(4)!) : null;

    return ParsedBibleReference(
      bookQuery: bookQuery,
      chapter: chapter,
      startVerse: startVerse,
      endVerse: endVerse,
    );
  }
}
