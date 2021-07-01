import 'package:fest/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('String Extensions', () {
    test(
        'removeWhitespace, removes trailing and following whitespace if exists',
        () async {
      expect(' Hello '.removeWhitespace(), 'Hello');
    });

    test('removeWhitespace, removes whitespace in between if exists', () async {
      expect('Hello World '.removeWhitespace(), 'HelloWorld');
    });

    test(
        'removeRefs, removes references with # followed with 5 chars in render and layer tree',
        () async {
      expect(' #h43h4 '.removeRefs(), '  ');
    });

    test(
        'removeRefs, doesn\'t remove anything after # and 5 chars in render and layer tree',
        () async {
      expect(' #h43h4567 '.removeRefs(), ' 567 ');
    });

    test('removeMetricsAndDiagnosis, removes metrics and diagnostic data',
        () async {
      expect(
          'metrics: blah blah blah diagnostics: bluh bluh bluh └─'
              .removeMetricsAndDiagnosis(),
          '└─');
    });

    test(
        'cleanupTree, performs removeWhitespace, removeRefs & removeMetricsAndDiagnosis',
        () async {
      expect(
          '  metrics: blah blah blah diagnostics: bluh bluh bluh └─  #555455'
              .cleanupTree(),
          '└─5');
    });

    test('remove, removes string that matches a regex patter in a string',
        () async {
      expect(
          'metrics: blah blah blah diagnostics: bluh bluh bluh └─'
              .remove(RegExp(
            r'metrics[^└─]*',
          )),
          '└─');
    });

    test('removeFromList, remove for multiple regexes', () async {
      expect(
          'metrics: blah blah blah diagnostics: bluh bluh bluh └─ #54555'
              .removeFromList([
            RegExp(
              r'metrics[^└─]*',
            ),
            RegExp(r'#.....')
          ]),
          '└─ ');
    });
  });
}
