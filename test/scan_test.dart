import 'package:jsonx/jsonx.dart';
import 'package:matcher/matcher.dart';
import 'package:test/test.dart';

main() {
  test('symbols+literals', () {
    expect('{', equalsScanned(TokenType.LBRACE));
    expect('}', equalsScanned(TokenType.RBRACE));
    expect('[', equalsScanned(TokenType.LBRACKET));
    expect(']', equalsScanned(TokenType.RBRACKET));
    expect(':', equalsScanned(TokenType.COLON));
    expect(',', equalsScanned(TokenType.COMMA));
    expect('true', equalsScanned(TokenType.TRUE));
    expect('false', equalsScanned(TokenType.FALSE));
    expect('null', equalsScanned(TokenType.NULL));
  });

  test('numbers', () {
    expect('2', equalsScanned(TokenType.NUMBER, '2'));
    expect('-2', equalsScanned(TokenType.NUMBER, '-2'));
    expect('24', equalsScanned(TokenType.NUMBER, '24'));
    expect('-24', equalsScanned(TokenType.NUMBER, '-24'));
    expect('24.42', equalsScanned(TokenType.NUMBER, '24.42'));
    expect('-24.42', equalsScanned(TokenType.NUMBER, '-24.42'));
    expect('2e5', equalsScanned(TokenType.NUMBER, '2e5'));
    expect('-2e5', equalsScanned(TokenType.NUMBER, '-2e5'));
    expect('24e5', equalsScanned(TokenType.NUMBER, '24e5'));
    expect('-24e5', equalsScanned(TokenType.NUMBER, '-24e5'));
    expect('2.4e5', equalsScanned(TokenType.NUMBER, '2.4e5'));
    expect('-2.4e5', equalsScanned(TokenType.NUMBER, '-2.4e5'));
    expect('2.4e-5', equalsScanned(TokenType.NUMBER, '2.4e-5'));
    expect('-2.4e-5', equalsScanned(TokenType.NUMBER, '-2.4e-5'));
  });

  test('strings', () {
    expect('""', equalsScanned(TokenType.STRING, ''));
    expect('"a"', equalsScanned(TokenType.STRING, 'a'));
    expect('"hello"', equalsScanned(TokenType.STRING, 'hello'));
    expect('"\\\\"', equalsScanned(TokenType.STRING, '\\'));
    expect('"\\b"', equalsScanned(TokenType.STRING, '\b'));
    expect('"\\f"', equalsScanned(TokenType.STRING, '\f'));
    expect('"\\n"', equalsScanned(TokenType.STRING, '\n'));
    expect('"\\r"', equalsScanned(TokenType.STRING, '\r'));
    expect('"\\t"', equalsScanned(TokenType.STRING, '\t'));
    expect('"\\""', equalsScanned(TokenType.STRING, '"'));
    expect('"\\p"', equalsScanned(TokenType.STRING, 'p'));
  });

  group('exceptions', () {
    test('newline in string', () {
      expect(() => scan('"hello\n"'),
          throwsA(const isInstanceOf<JsonxException>()));
    });

    test('unterminated string', () {
      expect(
          () => scan('"hello'), throwsA(const isInstanceOf<JsonxException>()));
    });

    test('unexpected character', () {
      expect(() => scan('!'), throwsA(const isInstanceOf<JsonxException>()));
      expect(() => scan('-'), throwsA(const isInstanceOf<JsonxException>()));
    });

    test('toString', () {
      var exc = new JsonxException(2, 'two', 3, 'two ducks on the beach'.codeUnits);
      expect(exc.toString(), allOf(contains('2'), contains('two')));
    });

    test('toString without offset', () {
      var exc = new JsonxException(null, 'two', 3, 'two ducks on the beach'.codeUnits);
      expect(exc.toString(), allOf(contains('two'), isNot(contains('offset'))));
    });
  });

  test('skips whitespace', () {
    expect('                   \n\r\ttrue', equalsScanned(TokenType.TRUE));
  });

  test('advances after tokens', () {
    var text = '24,"25",1'.codeUnits;
    var p = new Parser(text);
    var num = p.nextToken(),
        comma = p.nextToken(),
        str = p.nextToken(),
        comma2 = p.nextToken(),
        num2 = p.nextToken();
    expect(num.type, TokenType.NUMBER);
    expect(num.getText(text), '24');
    expect(comma.type, TokenType.COMMA);
    expect(comma.getText(text), isNull);
    expect(str.type, TokenType.STRING);
    expect(str.getText(text), '25');
    expect(comma2.type, TokenType.COMMA);
    expect(comma2.getText(text), isNull);
    expect(num2.type, TokenType.NUMBER);
    expect(num2.getText(text), '1');
    expect(p.nextToken(), isNull);
  });

  group('idiosyncrasies', () {
    test('empty strings as object keys???', () {
      var text = '{"empty":""}'.codeUnits;
      var p = new Parser(text);

      expect(p.nextToken().type, TokenType.LBRACE);

      var empty = p.nextToken();
      expect(empty.type, TokenType.STRING);
      expect(empty.getText(text), 'empty');

      expect(p.nextToken().type, TokenType.COLON);

      expect(p.nextIs(TokenType.STRING), isTrue);
      var emptyString = p.current;
      expect(emptyString.type, TokenType.STRING);
      expect(emptyString.getText(text), '');

      p = new Parser(text);
      var obj = p.parseObject();
      print(obj);
    });
  });
}

Token scan(String text) => new Parser(text.codeUnits).nextToken();

Matcher equalsScanned(TokenType type, [String text]) =>
    new _EqualsScanned(type, text);

class _EqualsScanned extends Matcher {
  final TokenType targetType;
  final String text;

  _EqualsScanned(this.targetType, [this.text]);

  @override
  Description describe(Description description) => text == null
      ? description.add('resolves to $targetType when scanned')
      : description
          .add('resolves to $targetType with text "$text" when scanned');

  @override
  bool matches(String item, Map matchState) {
    var p = new Parser(item.codeUnits);
    var tok = p.nextToken();
    if (tok?.type != targetType)
      return false;
    else if (text == null) return true;
    var actualText = tok.getText(item.codeUnits);
    return equals(text).matches(actualText, matchState);
  }
}
