extension StringX on String {
  String removeWhitespace() {
    return replaceAll(' ', '');
  }

  String removeRefs() {
    return replaceAll(RegExp(r'#.....'), '');
  }

  String removeMetricsAndDiagnosis() {
    final regExp = RegExp(
      r'metrics[^└─]*',
    );
    print(regExp.allMatches(this).map((regex) => regex.start));
    return replaceAll(regExp, '');
  }

  String cleanupTree() {
    return removeMetricsAndDiagnosis().removeWhitespace().removeRefs();
  }

  String remove(RegExp regExp) {
    return replaceAll(regExp, '');
  }

  String removeFromList(List<RegExp> regExps) {
    var newStr = this;
    for (var i = 0; i < regExps.length; i++) {
      newStr = newStr.remove(regExps[i]);
    }
    return newStr;
  }
}
