enum TokenType {
  LBRACE,
  RBRACE,
  LBRACKET,
  RBRACKET,
  COLON,
  COMMA,
  NUMBER,
  STRING,
  TRUE,
  FALSE,
  NULL
}

class Token {
  final TokenType type;
  final Iterable<int> text;
  Token(this.type, [this.text]);

  @override
  String toString() => '"${new String.fromCharCodes(text ?? [])}" => $type';
}
