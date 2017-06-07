import 'dart:collection';
import 'package:charcode/charcode.dart';
import 'ast.dart';
import 'exception.dart';
import 'token.dart';

bool _isNum(int ch) => (ch >= $0 && ch <= $9);

bool _isWhitespace(int ch) =>
    ch == $space || ch == $cr || ch == $lf || ch == $tab;

class Parser {
  Token _current;
  int _index = -1;
  int _textLength;
  final Queue<Token> _queue = new Queue<Token>();

  final List<int> text;

  Parser(this.text) {
    _textLength = text.length;
  }

  Token get current => _current;

  JsonxException expected(String type, int len) => new JsonxException(
      _index, 'expected \'$type\', found ${current?.type}', len, text);

  JsonxException expectedExpression() =>
      new JsonxException(_index, 'expected expression', 10, text);

  bool nextIs(TokenType type) {
    var tok = nextToken();
    if (tok == null)
      return false;
    else if (tok.type != type) {
      _queue.add(tok);
      return false;
    }

    _current = tok;
    return true;
  }

  bool openArray() => nextIs(TokenType.LBRACKET);

  bool closeArray() => nextIs(TokenType.RBRACKET);

  bool openObject() => nextIs(TokenType.LBRACE);

  bool closeObject() => nextIs(TokenType.RBRACE);

  bool comma() => nextIs(TokenType.COMMA);

  bool colon() => nextIs(TokenType.COLON);

  Node parseExpression() {
    return parseArray() ??
        parseObject() ??
        parseString() ??
        parseNumber() ??
        parseTrue() ??
        parseFalse() ??
        parseNull();
  }

  Node parseArray() {
    if (openArray()) {
      var expr = parseExpression();

      if (closeArray()) {
        return new Node(NodeType.ARRAY, children: expr != null ? [expr] : []);
      }

      List<Node> c = [];

      while (expr != null) {
        c.add(expr);
        if (closeArray()) return new Node(NodeType.ARRAY, children: c);
        if (!comma()) throw expected(',', 1);
        expr = parseExpression();
      }

      throw expected(']', 1);
    } else
      return null;
  }

  Node parseObject() {
    if (openObject()) {
      var kv = parseKeyValuePair();

      if (closeObject()) {
        return new Node(NodeType.OBJECT, children: kv != null ? [kv] : []);
      }

      List<Node> c = [];

      while (kv != null) {
        c.add(kv);
        if (closeObject()) return new Node(NodeType.OBJECT, children: c);
        if (!comma()) throw expected(',', 1);
        kv = parseKeyValuePair();
      }

      throw expected('}', 1);
    } else
      return null;
  }

  Node parseKeyValuePair() {
    var string = parseString();

    if (string == null)
      return null;
    else if (!colon())
      throw expected(':', 1);
    else {
      var expr = parseExpression();
      if (expr == null) throw expectedExpression();
      return new Node(NodeType.KEY_VALUE_PAIR, children: [string, expr]);
    }
  }

  Node parseString() {
    if (nextIs(TokenType.STRING))
      return new Node(NodeType.STRING, text: current.getText(text));
    else
      return null;
  }

  Node parseNumber() {
    if (nextIs(TokenType.NUMBER))
      return new Node(NodeType.NUMBER, text: current.getText(text));
    else
      return null;
  }

  Node parseTrue() {
    if (nextIs(TokenType.TRUE))
      return new Node(NodeType.TRUE);
    else
      return null;
  }

  Node parseFalse() {
    if (nextIs(TokenType.FALSE))
      return new Node(NodeType.FALSE);
    else
      return null;
  }

  Node parseNull() {
    if (nextIs(TokenType.NULL))
      return new Node(NodeType.NULL);
    else
      return null;
  }

  String parseAsString() => parseString()?.text;

  num parseAsNumber() {
    var n = parseNumber();
    return n != null ? num.parse(n.text) : null;
  }

  bool parseAsBool() {
    if (parseTrue() != null)
      return true;
    else if (parseFalse() != null) return false;
    return null;
  }

  Token nextToken() {
    if (_queue.isNotEmpty) return _queue.removeFirst();
    if (_index >= _textLength - 1) return null;
    int i = ++_index;
    int ch = text[i];

    switch (ch) {
      case $lbrace:
        return new Token(TokenType.LBRACE);
      case $rbrace:
        return new Token(TokenType.RBRACE);
      case $lbracket:
        return new Token(TokenType.LBRACKET);
      case $rbracket:
        return new Token(TokenType.RBRACKET);
      case $colon:
        return new Token(TokenType.COLON);
      case $comma:
        return new Token(TokenType.COMMA);
    }

    // Attempt to parse literal
    int remaining = _textLength - i;

    if (remaining >= 4) {
      int c1 = text[i + 1], c2 = text[i + 2], c3 = text[i + 3];

      if (remaining >= 5) {
        int c4 = text[i + 4];
        // Parse 'false'
        if (ch == $f && c1 == $a && c2 == $l && c3 == $s && c4 == $e) {
          _index += 4;
          return new Token(TokenType.FALSE);
        }
      }

      // Parse 'true' or 'null'
      if (ch == $t && c1 == $r && c2 == $u && c3 == $e) {
        _index += 3;
        return new Token(TokenType.TRUE);
      } else if (ch == $n && c1 == $u && c2 == $l && c3 == $l) {
        _index += 3;
        return new Token(TokenType.NULL);
      }
    }

    // Try to parse number
    if (_isNum(ch) ||
        ((ch == $minus) && i < _textLength - 1 && _isNum(text[i + 1]))) {
      int start = i, end = i;

      while (i < _textLength - 1 && _isNum(text[i + 1])) end = ++i;

      // Optional decimal
      if (i < _textLength - 2 && text[i + 1] == $dot && _isNum(text[i + 2])) {
        end = i + 2; // Add dot, account for digit after
        i++; // Skip dot

        while (i < _textLength - 1 && _isNum(text[i + 1])) end = ++i;
      }

      // Optional E/e
      if (i < _textLength - 2 &&
          (text[i + 1] == $E || text[i + 1] == $e) &&
          _isNum(text[i + 2])) {
        end = i + 2; // Add E/e, account for digit after
        i++; // Skip E/e

        while (i < _textLength - 1 && _isNum(text[i + 1])) end = ++i;
      }

      // Support negative power of 10
      else if (i < _textLength - 3 &&
          (text[i + 1] == $E || text[i + 1] == $e) &&
          text[i + 2] == $minus &&
          _isNum(text[i + 3])) {
        end = i + 3; // Add E/e, account for digit after
        i += 2; // Skip E/e

        while (i < _textLength - 1 && _isNum(text[i + 1])) end = ++i;
      }

      _index += end - start;
      return new Token(TokenType.NUMBER, start, end);
    }

    // Or string???
    else if (ch == $double_quote && i < _textLength - 1) {
      if (text[i + 1] == $double_quote) {
        _index++;
        return new Token(TokenType.STRING, i, i + 1);
      }

      int start = i + 1, end = i;
      bool terminated = false;

      for (int j = start; j < _textLength; j++) {
        int c = text[j];

        // Disallow newline
        if (c == $lf)
          throw new JsonxException(
              start, 'unexpected newline in string literal', j - i, text);

        // Terminate on double quote
        if (c == $double_quote) {
          terminated = true;
          break;
        }

        // Escaped quote
        if (c == $backslash && j < _textLength - 1) {
          j++;
        }

        // Ignore escape sequences when scanning. Just add the next char.
        end++;
      }

      if (!terminated)
        throw new JsonxException(
            i, 'unterminated string literal', end - start, text);

      // Note: generated token omits opening/closing quotes
      _index += end - start + 2;
      return new Token(TokenType.STRING, start, end);
    } else if (_isWhitespace(ch)) {
      // Skip whitespace
      while (i < _textLength - 1 && _isWhitespace(text[i + 1])) i++;
      return nextToken();
    } else
      throw new JsonxException(
          i, "unexpected character '${new String.fromCharCode(ch)}'", 1, text);
  }
}
