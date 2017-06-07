import 'package:charcode/charcode.dart';
import 'exception.dart';

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
  final int start, end;
  Token(this.type, [this.start, this.end]);

  // TODO: Resolve string text :)
  // Note: If string end < start, it's an empty string
  String getText(List<int> text) {
    if (start == null || end == null) return null;
    if (type != TokenType.STRING)
      return new String.fromCharCodes(
          text.skip(start).take(end - start + 1).toList());
    else {
      List<int> buf = [];

      for (int j = start; j <= end; j++) {
        int c = text[j];
        // Disallow newline
        if (c == $lf) {
          var message = 'unexpected newline in string literal';
          var exc = new JsonxException(j, message, end - start, text);
          throw exc;
        }

        // Terminate on double quote
        if (c == $double_quote) {
          break;
        }

        // Escape sequences

        if (c == $backslash && j < text.length - 1) {
          int peek = text[j + 1];

          switch (peek) {
            case $backslash:
              buf.add($backslash);
              break;
            case $b:
              buf.add(0x08);
              break;
            case $f:
              buf.add(0x0C);
              break;
            case $n:
              buf.add($lf);
              break;
            case $r:
              buf.add($cr);
              break;
            case $t:
              buf.add($tab);
              break;
            default:
              buf.add(peek);
          }

          j++;
        } else {
          buf.add(c);
        }
      }

      return new String.fromCharCodes(buf);
    }
  }

  @override
  String toString() => type.toString();
}
