import 'package:jsonx/jsonx.dart' as jsonx;
import 'package:test/test.dart';

main() {
  group('literals', () {
    test('true', () {
      expect(jsonx.parse('true'), isTrue);
    });

    test('false', () {
      expect(jsonx.parse('false'), isFalse);
    });

    test('null', () {
      expect(jsonx.parse('null'), isNull);
    });

    test('string', () {
      expect(jsonx.parse('"hello"'), "hello");
    });

    test('number', () {
      expect(jsonx.parse('6.022e23'), 6.022e23);
    });
  });

  group('array', () {
    test('convert empty array', () {
      expect(jsonx.parse('[]'), []);
    });

    test('convert normal array', () {
      expect(jsonx.parse('[1,2]'), [1, 2]);
    });
  });

  group('object', () {
    test('convert empty object', () {
      expect(jsonx.parse('{}'), {});
    });

    test('convert normal object', () {
      expect(jsonx.parse('{"a": ["b", "c"]}'), {
        "a": ["b", "c"]
      });
    });
  });

  test('cannot convert raw key-value pair', () {
    var kv = new jsonx.Parser('"a":2'.codeUnits).parseKeyValuePair();
    expect(() => jsonx.astToDart(kv), throwsArgumentError);
  });
}