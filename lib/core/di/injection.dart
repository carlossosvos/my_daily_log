import 'package:my_daily_log/core/di/service_locator.dart' as di;

class Injection {
  static Future<void> init() async {
    await di.init();
  }
}
