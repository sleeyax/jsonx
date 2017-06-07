import 'src/ast.dart';
import 'src/parser.dart';
import 'src/scan.dart';
export 'src/ast.dart';
export 'src/exception.dart';
export 'src/parser.dart';
export 'src/scan.dart';
export 'src/token.dart';

/// Parses a JSON AST from input [text].
Node parseAst(String text) => new Parser(scan(text.codeUnits)).parseExpression();

/// Similar to `JSON.decode`, creates a Dart value from input JSON text.
parse(String text) => astToDart(parseAst(text));

/// Creates a Dart value from an input [node].
astToDart(Node node) {
  switch (node.type) {
    case NodeType.ARRAY:
      return node.children.map(astToDart).toList();
    case NodeType.STRING:
      return new String.fromCharCodes(node.text);
    case NodeType.NUMBER:
      return num.parse(new String.fromCharCodes(node.text));
    case NodeType.TRUE:
      return true;
    case NodeType.FALSE:
      return false;
    case NodeType.NULL:
      return null;
    case NodeType.OBJECT:
      var result = <String, dynamic>{};

      for (var c in node.children) {
        // Assume they are all key-value pairs.
        var key = new String.fromCharCodes(c.children[0].text);
        var value = astToDart(c.children[1]);
        result[key] = value;
      }

      return result;
    default:
      throw new ArgumentError('Cannot convert ${node.type} to Dart value.');
  }
}
