import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'logger_method_channel.dart';
import 'models.dart';

abstract class LoggerPlatform extends PlatformInterface {
  /// Constructs a LoggerPlatform.
  LoggerPlatform() : super(token: _token);

  static final Object _token = Object();

  static LoggerPlatform _instance = MethodChannelLogger();

  /// The default instance of [LoggerPlatform] to use.
  ///
  /// Defaults to [MethodChannelLogger].
  static LoggerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LoggerPlatform] when
  /// they register themselves.
  static set instance(LoggerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<LogPage> logQueryPage(int limit, int? cursor, String? filename) {
    throw UnimplementedError('logQueryPage() has not been implemented.');
  }
}
