// platform_init_interface.dart
abstract class PlatformDbInit {
  static Future<void> initialize() async {
    throw UnsupportedError('Cannot initialize without platform implementation');
  }
}
