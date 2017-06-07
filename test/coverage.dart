import 'package:test/test.dart';
import 'convert_test.dart' as convert;
import 'parser_test.dart' as parser;
import 'scan_test.dart' as scan;

main() {
  group('convert', convert.main);
  group('parse', parser.main);
  group('scan', scan.main);
}