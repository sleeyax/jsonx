class JsonxException implements Exception {
  final int offset;
  final String message;

  JsonxException(this.offset, this.message);

  @override
  String toString() => offset == null
      ? 'JSON syntax error: $message'
      : 'JSON syntax error at offset $offset: $message';
}
