// ignore_for_file: avoid_dynamic_calls

class Log {
  const Log(this.raw, this.level, this.time, this.message, this.tag);

  static RegExp regExp = RegExp(r'^([\d-]+?)\s+([\d:.]+?)\s+(\d+?)\s+(\d+?)\s+(\w?)\s+([\w.-_\s]+?)\:\s+(.*?)$');

  static Log fromString(String s) {
    final ma = regExp.firstMatch(s);
    if (ma != null) {
      final level = switch (ma.group(5)?.toUpperCase()) {
        'V' => LogLevel.trace,
        'D' => LogLevel.debug,
        'I' => LogLevel.info,
        'W' => LogLevel.warn,
        'E' => LogLevel.error,
        'F' => LogLevel.error,
        _ => LogLevel.error,
      };
      final date = DateTime.tryParse('2026-${ma.group(1)} ${ma.group(2)}');
      return Log(s, level, date, ma.group(7) ?? '', ma.group(6));
    } else {
      return Log(s, LogLevel.trace, null, s, null);
    }
  }

  final LogLevel level;
  final DateTime? time;
  final String message;
  final String? tag;
  final String raw;
}

class LogPage {
  LogPage.fromJson(dynamic json)
    : data = (json['data'] as List).cast<String>().map(Log.fromString).toList(),
      cursor = json['cursor'],
      filename = json['filename'],
      isEnd = json['isEnd'];
  final List<Log> data;
  final int cursor;
  final bool isEnd;
  final String filename;
}

enum LogLevel {
  error,
  warn,
  info,
  debug,
  trace;

  static LogLevel fromInt(int? level) {
    return switch (level) {
      1 => LogLevel.error,
      2 => LogLevel.warn,
      3 => LogLevel.info,
      4 => LogLevel.debug,
      5 => LogLevel.trace,
      _ => throw Exception('Wrong Log Level of "$level"'),
    };
  }
}
