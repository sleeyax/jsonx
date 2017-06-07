import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:jsonx/jsonx.dart' as jsonx;

main() async {
  var file = new File('BENCHMARK.md');
  var benchmarker = new Benchmarker(parsers: {
    'JSONX': (List<int> buf) {
      var tokens = jsonx.scan(buf);
      var parser = new jsonx.Parser(tokens);
      return jsonx.astToDart(parser.parseExpression());
    },
    'JSON.decode': (List<int> buf) => JSON.decode(UTF8.decode(buf))
  });
  await Future
      .forEach(['hello_world', 'schema', 'servlet'], benchmarker.addItem);
  var sink = await file.openWrite();
  await benchmarker.run(sink);
  await sink.close();
  print('Benchmarking: DONE');
}

typedef dynamic JsonParser(List<int> text);

class Benchmarker {
  final Map<String, JsonParser> parsers = {};
  final Map<String, List<int>> items = {};

  Benchmarker(
      {Map<String, JsonParser> parsers: const {},
      Map<String, List<int>> items: const {}}) {
    this.parsers.addAll(parsers ?? {});
    this.items.addAll(items ?? {});
  }

  Future addItem(String key) async {
    var file = new File('benchmark/test_cases/$key.json');
    var contents = await file.readAsBytes();
    items[key] = contents;
  }

  Future run(IOSink sink) async {
    Map<String, List<int>> timing = parsers.keys
        .fold<Map<String, List<int>>>({}, (out, k) => out..[k] = []);

    sink..writeln('# JSON Parsing Benchmarks')..writeln('Comparing: ');
    parsers.keys.forEach((key) => sink.writeln('  * $key'));
    sink.writeln();

    for (var testName in items.keys) {
      var jsonBytes = items[testName];
      print('TEST: $testName');
      sink.writeln('## Running Test: `$testName`');

      for (var parserName in parsers.keys) {
        JsonParser parser = parsers[parserName];
        var sw = new Stopwatch();

        try {
          sw.start();
          var result = parser(jsonBytes);
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
