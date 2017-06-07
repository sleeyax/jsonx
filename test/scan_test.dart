import 'package:charcode/charcode.dart';
import 'package:jsonx/jsonx.dart';
import 'package:test/test.dart';

main() {
  group('literals', () {
    test('true', () {
      var tokens = scan('true'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, isNull);
      expect(tokens.first.type, TokenType.TRUE);
    });

    test('false', () {
      var tokens = scan('false'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, isNull);
      expect(tokens.first.type, TokenType.FALSE);
    });

    test('null', () {
      var tokens = scan('null'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, isNull);
      expect(tokens.first.type, TokenType.NULL);
    });
  });

  group('symbols', () {
    test('left brace', () {
      var tokens = scan('{'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, isNull);
      expect(tokens.first.type, TokenType.LBRACE);
    });

    test('right brace', () {
      var tokens = scan('}'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, isNull);
      expect(tokens.first.type, TokenType.RBRACE);
    });

    test('left bracket', () {
      var tokens = scan('['.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, isNull);
      expect(tokens.first.type, TokenType.LBRACKET);
    });

    test('right bracket', () {
      var tokens = scan(']'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, isNull);
      expect(tokens.first.type, TokenType.RBRACKET);
    });

    test('colon', () {
      var tokens = scan(':'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, isNull);
      expect(tokens.first.type, TokenType.COLON);
    });

    test('comma', () {
      var tokens = scan(','.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, isNull);
      expect(tokens.first.type, TokenType.COMMA);
    });
  });

  group('numbers', () {
    test('positive integer', () {
      var tokens = scan('24'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, [$2, $4]);
      expect(tokens.first.type, TokenType.NUMBER);
    });

    test('negative integer', () {
      var tokens = scan('-24'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, [$minus, $2, $4]);
      expect(tokens.first.type, TokenType.NUMBER);
    });

    test('positive decimal', () {
      var tokens = scan('24.42'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, [$2, $4, $dot, $4, $2]);
      expect(tokens.first.type, TokenType.NUMBER);
    });

    test('negative decimal', () {
      var tokens = scan('-24.42'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, [$minus, $2, $4, $dot, $4, $2]);
      expect(tokens.first.type, TokenType.NUMBER);
    });

    test('positive int with e', () {
      var tokens = scan('24e5'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, [$2, $4, $e, $5]);
      expect(tokens.first.type, TokenType.NUMBER);
    });

    test('negative int with e', () {
      var tokens = scan('-24E5'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, [$minus, $2, $4, $E, $5]);
      expect(tokens.first.type, TokenType.NUMBER);
    });

    test('positive double with e', () {
      var tokens = scan('2.2e5'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, [$2, $dot, $2, $e, $5]);
      expect(tokens.first.type, TokenType.NUMBER);
    });

    test('negative double with e', () {
      var tokens = scan('-24.2E5'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, [$minus, $2, $4, $dot, $2, $E, $5]);
      expect(tokens.first.type, TokenType.NUMBER);
    });
  });

  group('strings', () {
    test('plain string', () {
      var tokens = scan('"hello"'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, [$h, $e, $l, $l, $o]);
      expect(tokens.first.type, TokenType.STRING);
    });

    test('empty string', () {
      var tokens = scan('""'.codeUnits);
      print(tokens);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, isEmpty);
      expect(tokens.first.type, TokenType.STRING);
    });

    group('escape sequences', () {
      test('backslash', () {
        var tokens = scan('"\\\\"'.codeUnits);
        print(tokens);
        expect(tokens, hasLength(1));
        expect(tokens.first.text, [$backslash]);
        expect(tokens.first.type, TokenType.STRING);
      });

      test('backspace', () {
        var tokens = scan('"\\b"'.codeUnits);
        print(tokens);
        expect(tokens, hasLength(1));
        expect(tokens.first.text, [0x08]);
        expect(tokens.first.type, TokenType.STRING);
      });

      test('line feed', () {
        var tokens = scan('"\\f"'.codeUnits);
        print(tokens);
        expect(tokens, hasLength(1));
        expect(tokens.first.text, [0x0C]);
        expect(tokens.first.type, TokenType.STRING);
      });

      test('newline', () {
        var tokens = scan('"\\n"'.codeUnits);
        print(tokens);
        expect(tokens, hasLength(1));
        expect(tokens.first.text, [$lf]);
        expect(tokens.first.type, TokenType.STRING);
      });

      test('carriage return', () {
        var tokens = scan('"\\r"'.codeUnits);
        print(tokens);
        expect(tokens, hasLength(1));
        expect(tokens.first.text, [$cr]);
        expect(tokens.first.type, TokenType.STRING);
      });

      test('tab', () {
        var tokens = scan('"\\t"'.codeUnits);
        print(tokens);
        expect(tokens, hasLength(1));
        expect(tokens.first.text, [$tab]);
        expect(tokens.first.type, TokenType.STRING);
      });

      test('redundant escape', () {
        var tokens = scan('"\\p"'.codeUnits);
        print(tokens);
        expect(tokens, hasLength(1));
        expect(tokens.first.text, [$p]);
        expect(tokens.first.type, TokenType.STRING);
      });
    });
  });

  group('exceptions', () {
    test('newline in string', () {
      expect(() => scan('"hello\n"'.codeUnits),
          throwsA(const isInstanceOf<JsonxException>()));
    });

    test('unterminated string', () {
      expect(() => scan('"hello'.codeUnits),
          throwsA(const isInstanceOf<JsonxException>()));
    });

    test('unexpected character', () {
      expect(() => scan('!'.codeUnits),
          throwsA(const isInstanceOf<JsonxException>()));
    });

    test('toString', () {
      var exc = new JsonxException(2, 'two');
      expect(exc.toString(), allOf(contains('2'), contains('two')));
    });

    test('toString without offset', () {
      var exc = new JsonxException(null, 'two');
      expect(exc.toString(), allOf(contains('two'), isNot(contains('offset'))));
    });
  });

  test('scanner skips whitespace', () {
    var tokens = scan('               \t\r\ntrue'.codeUnits);
    print(tokens);
    expect(tokens, hasLength(1));
    expect(tokens.first.text, isNull);
    expect(tokens.first.type, TokenType.TRUE);
  });

  test('scanner advances after tokens', () {
    var tokens = scan('[1,"2",-3e25]'.codeUnits);
    print(tokens);
    expect(tokens, hasLength(7));
    expect(tokens.map((t) => t.type).toList(), [
      TokenType.LBRACKET,
      TokenType.NUMBER,
      TokenType.COMMA,
      TokenType.STRING,
      TokenType.COMMA,
      TokenType.NUMBER,
      TokenType.RBRACKET
    ]);
  });
}
