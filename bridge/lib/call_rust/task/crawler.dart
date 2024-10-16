// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.5.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import '../native/system_api.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class CrawlerTemplate {
  final int id;
  final String baseUrl;
  final String searchUrl;
  final String jsonRaw;
  final TemplateVideoDataInterim template;
  final int priority;
  final bool enabled;

  const CrawlerTemplate({
    required this.id,
    required this.baseUrl,
    required this.searchUrl,
    required this.jsonRaw,
    required this.template,
    required this.priority,
    required this.enabled,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      baseUrl.hashCode ^
      searchUrl.hashCode ^
      jsonRaw.hashCode ^
      template.hashCode ^
      priority.hashCode ^
      enabled.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrawlerTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          baseUrl == other.baseUrl &&
          searchUrl == other.searchUrl &&
          jsonRaw == other.jsonRaw &&
          template == other.template &&
          priority == other.priority &&
          enabled == other.enabled;
}
