import 'dart:convert';
import 'dart:io';
import 'package:jsonx/jsonx.dart' as jsonx;
import '../../main.dart' show Benchmarker;

main() async {
  var file = new File('benchmark/deserialization/todo/BENCHMARK.md');

  var benchmarker = new Benchmarker<Todo>(parsers: {
    'JSONX.parse': (String str) {
      return Todo.fromMap(jsonx.parse(str));
    },
    '!JSONX (from AST)': Todo.parseFromAst,
    'JSON.decode': Todo.parseFromDart
  });

  benchmarker.items['hello_world'] =
      '{"text":"Hello, world!","completed":false}';

  benchmarker.items['junk'] =
      '{"text":"junk","completed":true, "a": "b", "c":"d", "e": "f", "g":     "h"}';

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
    return Todo.fromMap(obj);
  }

  static Todo fromMap(Map obj) =>
      new Todo(text: obj['text'], completed: obj['completed'] == true);

  static Todo parseFromAst(String json) {
    var parser = new jsonx.Parser(json.codeUnits);
    if (!parser.openObject()) return null;
    var todo = new Todo();
    var key = parser.parseString();
    bool hasText = false, hasCompleted = false;

    while (key != null) {
      var name = key.text;

      if (name == 'text' && parser.colon()) {
        hasText = true;
        todo.text = parser.parseAsString();
      } else if (name == 'completed' && parser.colon()) {
        hasCompleted = true;
        todo.completed = parser.parseAsBool();
      }

      if (hasText && hasCompleted) break;

      parser
        ..colon()
        ..parseExpression()
        ..comma();
      key = parser.parseString();
    }

    return todo;
  }

  @override
  String toString() => '{"text":"$text","completed":$completed}';
}
