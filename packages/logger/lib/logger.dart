import 'logger_platform_interface.dart';

export 'models.dart';

class Logger {
  static final logQueryPage = LoggerPlatform.instance.logQueryPage;
}
