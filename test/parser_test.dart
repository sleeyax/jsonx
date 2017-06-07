import 'package:charcode/charcode.dart';
import 'package:jsonx/jsonx.dart' as jsonx;
import 'package:test/test.dart';

main() {
  group('literals', () {
    test('true', () {
      var ast = jsonx.parseAst('true');
      expect(ast.type, jsonx.NodeType.TRUE);
    });

    test('false', () {
      var ast = jsonx.parseAst('false');
      expect(ast.type, jsonx.NodeType.FALSE);
      print(ast);
    });

    test('null', () {
      var ast = jsonx.parseAst('null');
      expect(ast.type, jsonx.NodeType.NULL);
    });

    test('string', () {
      var ast = jsonx.parseAst('"hello"');
      print(ast);
      expect(ast.type, jsonx.NodeType.STRING);
      expect(ast.text, 'hello'.codeUnits);
    });

    test('number', () {
      var ast = jsonx.parseAst('24.5');
      expect(ast.type, jsonx.NodeType.NUMBER);
      expect(ast.text, '24.5'.codeUnits);
    });
  });

  group('object', () {
    test('empty object', () {
      var ast = jsonx.parseAst('{}');
      expect(ast.type, jsonx.NodeType.OBJECT);
      expect(ast.children, isEmpty);
    });

    test('one item', () {
      var ast = jsonx.parseAst('{"a":"b"}');
      print(ast);
      expect(ast.type, jsonx.NodeType.OBJECT);
      expect(ast.children, hasLength(1));
      var first = ast.children.first;
      expect(first.type, jsonx.NodeType.KEY_VALUE_PAIR);
      expect(first.children, hasLength(2));
      var a = first.children[0], b = first.children[1];
      expect(a.type, jsonx.NodeType.STRING);
      expect(a.text, [$a]);
      expect(b.type, jsonx.NodeType.STRING);
      expect(b.text, [$b]);
    });

    test('multiple items', () {
      var ast = jsonx.parseAst('{"a":"b", "c": {}}');
      expect(ast.type, jsonx.NodeType.OBJECT);
      expect(ast.children, hasLength(2));
    });
  });

  group('array', () {
    test('empty array', () {
      var ast = jsonx.parseAst('[]');
      expect(ast.type, jsonx.NodeType.ARRAY);
      expect(ast.children, isEmpty);
    });

    test('one item', () {
      var ast = jsonx.parseAst('["a"]');
      expect(ast.type, jsonx.NodeType.ARRAY);
      expect(ast.children, hasLength(1));
      var first = ast.children.first;
      expect(first.type, jsonx.NodeType.STRING);
      expect(first.text, [$a]);
    });

    test('array:multiple items', () {
      var ast = jsonx.parseAst('["a", ["b"]]');
      expect(ast.type, jsonx.NodeType.ARRAY);
      expect(ast.children, hasLength(2));
    });
  });

  group('exceptions', () {
    test('unterminated array', () {
      expect(() => jsonx.parseAst('[1,'),
          throwsA(const isInstanceOf<jsonx.JsonxException>()));
    });

    test('unterminated object', () {
      expect(() => jsonx.parseAst('{"a":"b",'),
          throwsA(const isInstanceOf<jsonx.JsonxException>()));
    });

    test('no colon in key-value pair', () {
      expect(() => jsonx.parseAst('{"a"'),
          throwsA(const isInstanceOf<jsonx.JsonxException>()));
    });

    test('unterminated key-value pair', () {
      expect(() => jsonx.parseAst('{"a":'),
          throwsA(const isInstanceOf<jsonx.JsonxException>()));
    });
  });
}
