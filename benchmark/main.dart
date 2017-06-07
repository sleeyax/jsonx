import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:jsonx/jsonx.dart' as jsonx;
import 'deserialization/todo/main.dart' as todo;

main() async {
  await todo.main();

  var file = new File('BENCHMARK.md');
  var benchmarker = new Benchmarker(parsers: {
    'JSONX.parse': jsonx.parse,
    'JSONX.parseDartValue': (String str) {
      var text = str.codeUnits;
      var p = new jsonx.Parser(text);
      return jsonx.parseDartValue(p, text);
    },
    'JSONX.astToDart': (String str) {
      var text = str.codeUnits;
      var p = new jsonx.Parser(text);
      return jsonx.astToDart(p.parseExpression());
    },
    'JSON.decode': JSON.decode,
    '!JSONX(profiled)': profiledJsonx,
    '!JSONX (parse-only)': (String str) =>
        new jsonx.Parser(str.codeUnits).parseExpression()
  });
  await Future.forEach(
      ['hello_world', 'schema', 'servlet', 'twitter_credentials', 'five_kb'],
      benchmarker.addItem);
  var sink = await file.openWrite();
  await benchmarker.run(sink);
  await sink.close();
  print('Main benchmarking: DONE');
}

profiledJsonx(String str) {
  var text = str.codeUnits;
  var p = new jsonx.Parser(text);
  jsonx.Token tok;
  var sw = new Stopwatch()..start();

  do {
    tok = p.nextToken();
  } while (tok != null);
  sw.stop();

  var scanTime = sw.elapsedMicroseconds;
  sw.reset();

  p = new jsonx.Parser(text);
  sw.start();
  var node = p.parseExpression();
  sw.stop();
  var parseTime = sw.elapsedMicroseconds;
  sw.reset();

  p = new jsonx.Parser(text);
  sw.start();
  jsonx.parseDartValue(p, text);
  sw.stop();
  var parseDartValueTime = sw.elapsedMicroseconds;
  sw.reset();

  sw.start();
  jsonx.astToDart(node);
  sw.stop();
  var convertTime = sw.elapsedMicroseconds;

  return 'scan: ${scanTime}us; parse: ${parseTime}us, parseDartValue: ${parseDartValueTime}us, astToDart: ${convertTime}us';
}

typedef T JsonParser<T>(String text);

class Benchmarker<T> {
  final Map<String, JsonParser<T>> parsers = {};
  final Map<String, String> items = {};
  final int trials;

  Benchmarker(
      {Map<String, JsonParser<T>> parsers: const {},
      Map<String, String> items: const {},
      this.trials: 100}) {
    this.parsers.addAll(parsers ?? {});
    this.items.addAll(items ?? {});
  }

  double average(List<num> tallies) {
    int sum;

    if (tallies.isEmpty)
      sum = -1;
    else
      sum = tallies.reduce((a, b) => a + b);

    if (sum == -1) return -1.0;
    return sum * 1.0 / tallies.length;
  }

  Future addItem(String key) async {
    var file = new File('benchmark/test_cases/$key.json');
    var contents = await file.readAsString();
    items[key] = contents;
  }

  Future run(IOSink sink) async {
    Map<String, List<double>> timing = parsers.keys
        .fold<Map<String, List<double>>>({}, (out, k) => out..[k] = []);

    sink..writeln('# JSON Parsing Benchmarks')..writeln('Comparing: ');
    parsers.keys.forEach((key) => sink.writeln('  * $key'));
    sink.writeln();

    for (var testName in items.keys) {
      var jsonString = items[testName];
      print('TEST: $testName');
      sink.writeln('## Running Test: `$testName`');

      for (var parserName in parsers.keys) {
        JsonParser parser = parsers[parserName];
        List<int> tries = [];
        var lastResult;
        Stopwatch sw = new Stopwatch();

        try {
          for (int i = 0; i < trials; i++) {
            sw.start();
            lastResult = parser(jsonString);
            sw.stop();
            tries.add(sw.elapsedMicroseconds);
            sw.reset();
          }

          var avg = average(tries);
          sink.writeln(
              ' **$parserName**: ${avg.toStringAsFixed(2)}us average over $trials trial(s)');
          timing[parserName].add(avg);

          if (parserName.startsWith('!')) print('  $parserName: $lastResult');
        } catch (e) {
          sw.stop();
          print('  $parserName: FAILED');
          sink
            ..writeln(
                '**$parserName**: **FAILED** within ${sw.elapsedMicroseconds}us')
            ..writeln('\n```$e```\n');
        } finally {
          sink.writeln();
        }
      }
    }

    sink..writeln()..writeln('# Conclusion');

    double lowest = null;
    String name = null;

    timing.forEach((k, v) {
      var avg = average(v);

      if (avg != -1.0)
        sink.writeln('  * $k: ${avg.toStringAsFixed(2)}us average');

      if (!k.startsWith('!') && (lowest == null || avg < lowest)) {
        lowest = avg;
        name = k;
      }
    });

    sink.writeln(
        '\nWinner: **$name** (${(lowest /1000).toStringAsFixed(2)}ms average)');
  }
}
