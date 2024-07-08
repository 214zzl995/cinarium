import 'package:path_provider/path_provider.dart';

class PathUtil {
  static String get roaming => _roaming!;

  static String? _roaming;

  static Future<void> init() async {
    if (_roaming == null) {
      final directory = await getApplicationSupportDirectory();
      _roaming = directory.path;
    }
  }
}
