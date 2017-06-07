import 'package:charcode/charcode.dart';
import 'exception.dart';
import 'token.dart';

bool _isNum(int ch) => (ch >= $0 && ch <= $9);

bool _isWhitespace(int ch) =>
    ch == $space || ch == $cr || ch == $lf || ch == $tab;

List<Token> scan(List<int> text) {
  var tokens = <Token>[];

  for (int i = 0; i < text.length; i++) {
    var ch = text[i];
    bool single = true;

    switch (ch) {
      case $lbrace:
        tokens.add(new Token(TokenType.LBRACE));
        break;
      case $rbrace:
        tokens.add(new Token(TokenType.RBRACE));
        break;
      case $lbracket:
        tokens.add(new Token(TokenType.LBRACKET));
        break;
      case $rbracket:
        tokens.add(new Token(TokenType.RBRACKET));
        break;
      case $colon:
        tokens.add(new Token(TokenType.COLON));
        break;
      case $comma:
        tokens.add(new Token(TokenType.COMMA));
        break;
      default:
        single = false;
    }

    if (!single) {
      int remaining = text.length - i;

      if (remaining >= 4) {
        int c1 = text[i + 1], c2 = text[i + 2], c3 = text[i + 3];

        if (remaining >= 5) {
          int c4 = text[i + 4];
          // Parse 'false'
          if (ch == $f && c1 == $a && c2 == $l && c3 == $s && c4 == $e) {
            tokens.add(new Token(TokenType.FALSE));
            i += 4;
            continue;
          }
        }

        // Parse 'true' or 'null'
        if (ch == $t && c1 == $r && c2 == $u && c3 == $e) {
          tokens.add(new Token(TokenType.TRUE));
          i += 3;
          continue;
        } else if (ch == $n && c1 == $u && c2 == $l && c3 == $l) {
          tokens.add(new Token(TokenType.NULL));
          i += 3;
          continue;
        }
      }

      // Try to parse number
      if (_isNum(ch) ||
          ((ch == $minus) && i < text.length - 1 && _isNum(text[i + 1]))) {
        List<int> buf = [ch];

        while (i < text.length - 1 && _isNum(text[i + 1])) {
          buf.add(text[++i]);
        }

        // Optional decimal
        if (i < text.length - 2 && text[i + 1] == $dot && _isNum(text[i + 2])) {
          buf.add($dot);
          i++;

          while (i < text.length - 1 && _isNum(text[i + 1])) {
            buf.add(text[++i]);
          }
        }

        // Optional E/e
        if (i < text.length - 2 &&
            (text[i + 1] == $E || text[i + 1] == $e) &&
            _isNum(text[i + 2])) {
          buf.add(text[++i]);

          while (i < text.length - 1 && _isNum(text[i + 1])) {
            buf.add(text[++i]);
          }
        }

        tokens.add(new Token(TokenType.NUMBER, buf));
      }

      // Or string???
      else if (ch == $double_quote) {
        List<int> buf = [];
        bool terminated = false;
        int offset = 0;

        for (int j = i + 1; j < text.length; j++) {
          int c = text[j];

          // Disallow newline
          if (c == $lf)
            throw new JsonxException(j, 'unexpected newline in string literal');

          // Terminate on double quote
          if (c == $double_quote) {
            terminated = true;
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
            offset += 2;
          } else {
            buf.add(c);
            offset++;
          }
        }

        if (!terminated)
          throw new JsonxException(i, 'unterminated string literal');
        i += offset + 1;
        // Note: generated token omits opening/closing quotes
        tokens.add(new Token(TokenType.STRING, buf));
      } else if (_isWhitespace(ch)) {
        // Skip whitespace
        while (i < text.length - 1 && _isWhitespace(text[i + 1])) i++;
        continue;
      } else
        throw new JsonxException(
            i, "unexpected character '${new String.fromCharCode(ch)}'");
    }
  }

  return tokens;
}
