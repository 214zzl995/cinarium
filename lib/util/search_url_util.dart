import 'package:flutter/cupertino.dart';

class UrlSpan {
  final String text;
  final bool isHyperlink;

  UrlSpan(this.text, this.isHyperlink);

  @override
  String toString() {
    return 'UrlSpan{text: $text, isHyperlink: $isHyperlink}';
  }
}

class SearchUrlUtil {
  static List<UrlSpan> parseSearchUrl(String searchUrl) {
    final RegExp allEegExp = RegExp(r'(\$\{.*?\})|([^$\s]+)');
    final Iterable<Match> matches = allEegExp.allMatches(searchUrl);

    final List<String> result = matches.map((match) {
      return match.group(0)!;
    }).toList();

    final List<UrlSpan> urlSpans = [];
    final RegExp hyperlinkEegExp = RegExp(r'(\$\{.*?\})');

    for (String item in result) {
      final bool isHyperlink = hyperlinkEegExp.hasMatch(item);
      urlSpans.add(UrlSpan(item, isHyperlink));
    }
    return urlSpans;
  }
}
