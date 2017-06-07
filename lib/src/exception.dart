class JsonxException implements Exception {
  static const int _PAD = 10;
  final int offset, errorLength;
  final String message;
  final List<int> sourceText;

  JsonxException(this.offset, this.message, this.errorLength, this.sourceText);

  @override
  String toString() {
    if (offset == null || sourceText?.isNotEmpty != true) {
      return 'JSON syntax error: $message';
    }

    if (offset < 0 || offset >= sourceText.length)
      return 'JSON syntax error: $message';

    int end = offset + errorLength;

    if (end < 0 || end >= sourceText.length)
      return 'JSON syntax error at offset $offset: $message';

    var buf = new String.fromCharCodes(
        sourceText.skip(offset - _PAD).take(errorLength + _PAD).toList());

    buf = buf
        .replaceAll('\\', '\\\\')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\b', '\\b')
        .replaceAll('\f', '\\f')
        .replaceAll('\t', '\\t');

    return 'JSON syntax error at offset $offset: $message - "$buf"';
  }
}
