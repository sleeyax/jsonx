import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:jsonx/jsonx.dart' as jsonx;
import 'deserialization/todo/main.dart' as todo;

main() async {
  await todo.main();

  var file = new File('BENCHMARK.md');
  var benchmarker = new Benchmarker(parsers: {
    'JSONX': jsonx.parse,
    'JSONX (profiled)': profiledJsonx,
    'JSON.decode': JSON.decode
  });
  await Future.forEach(
      ['hello_world', 'schema', 'servlet', 'twitter_credentials'],
      benchmarker.addItem);
  var sink = await file.openWrite();
  await benchmarker.run(sink);
  await sink.close();
  print('Main benchmarking: DONE');
}

typedef T JsonParser<T>(String text);

profiledJsonx(String str) {
  var sw = new Stopwatch();
  sw.start();
  var tokens = jsonx.scan(str.codeUnits);
  sw..stop();
  var scanTime = sw.elapsedMicroseconds;
  sw
    ..reset()
    ..start();
  var ast = new jsonx.Parser(tokens).parseExpression();
  sw.stop();
  var parseTime = sw.elapsedMicroseconds;
  sw
    ..reset()
    ..start();
  jsonx.astToDart(ast);
  sw.stop();
  var convertTime = sw.elapsedMicroseconds;
  return {'scan': scanTime, 'parse': parseTime, 'convert': convertTime};
}

class Benchmarker<T> {
  final Map<String, JsonParser<T>> parsers = {};
  final Map<String, String> items = {};

  Benchmarker(
      {Map<String, JsonParser<T>> parsers: const {},
      Map<String, String> items: const {}}) {
    this.parsers.addAll(parsers ?? {});
    this.items.addAll(items ?? {});
  }

  Future addItem(String key) async {
    var file = new File('benchmark/test_cases/$key.json');
    var contents = await file.readAsString();
    items[key] = contents;
  }

  Future run(IOSink sink) async {
    Map<String, List<int>> timing = parsers.keys
        .fold<Map<String, List<int>>>({}, (out, k) => out..[k] = []);

    sink..writeln('# JSON Parsing Benchmarks')..writeln('Comparing: ');
    parsers.keys.forEach((key) => sink.writeln('  * $key'));
    sink.writeln();

    for (var testName in items.keys) {
      var jsonString = items[testName];
      print('TEST: $testName');
      sink.writeln('## Running Test: `$testName`');

      for (var parserName in parsers.keys) {
        JsonParser parser = parsers[parserName];
        var sw = new Stopwatch();

        try {
          sw.start();
          var result = parser(jsonString);
          sw.stop();
          print('  $parserName: $result');
          sink.writeln(' **$parserName**: ${sw.elapsedMicroseconds}us');
          timing[parserName].add(sw.elapsedMicroseconds);
        } catch (e) {
          sw.stop();
          print('  $parserName: FAILED');
          sink
            ..writeln(
                '**$parserName**: **FAILED** within ${sw.elapsedMicroseconds}us')
            ..writeln('\n```$e```');
        } finally {
          sink.writeln();
        }
      }
    }

    sink..writeln()..writeln('# Conclusion');

    double lowest = null;
    String name = null;

    timing.forEach((k, v) {
      int sum;

      if (v.isEmpty)
        sum = -1;
      else
        sum = v.reduce((a, b) => a + b);

      if (sum == -1) {
        sink.writeln('  * $k: *never succeeded*');
        return;
      }

      var avg = sum * 1.0 / v.length;
      sink.writeln('  * $k: ${avg.toStringAsFixed(2)}us average');

      if (lowest == null || avg < lowest) {
        lowest = avg;
        name = k;
      }
    });

    sink.writeln(
        '\nWinner: **$name** (${(lowest /1000).toStringAsFixed(2)}ms average)');
  }
}
