import 'dart:convert';
import 'dart:io';
import 'package:jsonx/jsonx.dart' as jsonx;
import '../../main.dart' show Benchmarker;

main() async {
  var file = new File('benchmark/deserialization/todo/BENCHMARK.md');

  var benchmarker = new Benchmarker<Todo>(
      parsers: {'JSONX': Todo.parseFromAst, 'JSON.decode': Todo.parseFromDart});

  benchmarker.items['hello_world'] =
      '{"text":"Hello, world!","completed":false}';

  benchmarker.items['junk'] = '{"text":"junk","completed":true}';

  var sink = await file.openWrite();
  await benchmarker.run(sink);
  await sink.close();
  print('Todo benchmarking: DONE');
}

class Todo {
  String text;
  bool completed;

  Todo({this.text, this.completed});

  static Todo parseFromDart(String json) {
    var obj = JSON.decode(json) as Map;
    return new Todo(text: obj['text'], completed: obj['completed'] == true);
  }

  static Todo parseFromAst(String json) {
    var tokens = jsonx.scan(json.codeUnits);
    var parser = new jsonx.Parser(tokens);
    if (!parser.openObject()) return null;
    var todo = new Todo();
    var key = parser.parseString();

    while (key != null) {
      var name = new String.fromCharCodes(key.text);

      if (name == 'text' && parser.colon()) {
        var str = parser.parseString();
        if (str != null) todo.text = new String.fromCharCodes(str.text);
      } else if (name == 'completed' && parser.colon()) {
        var b = parser.parseTrue() ?? parser.parseFalse();
        if (b != null) todo.completed = b.type == jsonx.NodeType.TRUE;
      }

      parser
        ..colon()
        ..parseExpression()
        ..comma();
      key = parser.parseString();
    }

    return todo;
  }

  static Todo parseFromAstOld(String json) {
    var tokens = jsonx.scan(json.codeUnits);
    var parser = new jsonx.Parser(tokens);
    var obj = parser.parseObject();
    var todo = new Todo();

    for (var kv in obj.children) {
      var text = kv.children[0].text;

      switch (text) {
        case 'text':
          todo.text = new String.fromCharCodes(kv.children[1].text);
          break;
        case 'completed':
          todo.completed = kv.children[1].type == jsonx.NodeType.TRUE;
          break;
      }
    }

    return todo;
  }

  @override
  String toString() => '{"text":"$text","completed":$completed}';
}
