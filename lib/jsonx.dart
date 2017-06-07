import 'src/ast.dart';
import 'src/in_situ_parser.dart';
import 'src/token.dart';
export 'src/ast.dart';
export 'src/exception.dart';
export 'src/in_situ_parser.dart';
export 'src/token.dart';

/// Parses a JSON AST from input [text].
Node parseAst(String text) => new Parser(text.codeUnits).parseExpression();

/// Similar to `JSON.decode`, creates a Dart value from input JSON text.
parse(String text) {
  var cu = text.codeUnits;
  var p = new Parser(cu);
  return parseDartValue(p, cu);
}

parseDartValue(Parser p, List<int> text) {
  if (p.openArray()) {
    if (p.closeArray()) return [];
    List out = [];
    var expr = parseDartValue(p, text);

    while (expr != null) {
      out.add(expr);
      if (p.comma())
        expr = parseDartValue(p, text);
      else
        expr = null;
    }

    if (!p.closeArray()) throw p.expected(']', 1);
    return out;
  }

  if (p.openObject()) {
    if (p.closeObject()) return <String, dynamic>{};

    Map<String, dynamic> m = {};
    var k = p.parseString();

    while (k != null) {
      if (!p.colon()) throw p.expected(':', 1);
      m[k.text] = parseDartValue(p, text);
      if (p.comma())
        k = p.parseString();
      else
        k = null;
    }

    if (p.closeObject())
      return m;
    else
      throw p.expected('}', 1);
  }

  if (p.nextIs(TokenType.NUMBER))
    return num.parse(p.current.getText(text));
  else if (p.nextIs(TokenType.STRING))
    return p.current.getText(text);
  else if (p.nextIs(TokenType.TRUE))
    return true;
  else if (p.nextIs(TokenType.FALSE))
    return false;
  else if (p.nextIs(TokenType.NULL))
    return null;
  else {
    var tok = p.nextToken();
    throw new ArgumentError('Cannot convert ${tok?.type} to Dart value.');
  }
}

/// Creates a Dart value from an input [node].
astToDart(Node node) {
  switch (node.type) {
    case NodeType.ARRAY:
      return node.children.map(astToDart).toList();
    case NodeType.STRING:
      return node.text;
    case NodeType.NUMBER:
      return num.parse(node.text);
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
        var key = c.children[0].text;
        var value = astToDart(c.children[1]);
        result[key] = value;
      }

      return result;
    default:
      throw new ArgumentError('Cannot convert ${node.type} to Dart value.');
  }
}
