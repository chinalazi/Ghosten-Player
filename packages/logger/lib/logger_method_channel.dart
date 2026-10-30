import 'package:flutter/services.dart';

import 'logger_platform_interface.dart';
import 'models.dart';

const _pluginNamespace = 'com.ghosten.player/logger';

/// An implementation of [LoggerPlatform] that uses method channels.
class MethodChannelLogger extends LoggerPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel(_pluginNamespace);

  @override
  Future<LogPage> logQueryPage(int limit, int? cursor, String? filename) async {
    final data = await methodChannel.invokeMethod('logQueryPage', {
      'limit': limit,
      'cursor': cursor,
      'filename': filename,
    });
    return LogPage.fromJson(data);
  }
}
