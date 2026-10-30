// ignore_for_file: avoid_dynamic_calls

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum PlayerType {
  media3,
  mpv;

  static PlayerType fromString(String? str) {
    return PlayerType.values.firstWhere((element) => element.name == str, orElse: () => PlayerType.media3);
  }
}

enum PlayerStatus {
  playing,
  buffering,
  paused,
  ended,
  error,
  idle;

  static PlayerStatus fromString(String str) {
    return PlayerStatus.values.firstWhere((element) => element.name == str);
  }
}

class MediaTrack {
  MediaTrack.fromJson(dynamic json)
    : id = json['id'],
      selected = json['selected'],
      supported = json['supported'],
      label = json['label'],
      mimeType = json['mimeType'],
      rate = json['rate'],
      averageBitrate = json['averageBitrate'],
      name = json['name'],
      type = json['type'];
  String? id;
  bool selected;
  bool supported;
  String? label;
  String? mimeType;
  int? rate;
  int? averageBitrate;
  String? name;
  String type;
}

class MediaTrackGroup {
  MediaTrackGroup({required this.video, required this.sub, required this.audio}) {
    selectedVideo = video.firstWhereOrNull((e) => e.selected)?.id;
    selectedAudio = audio.firstWhereOrNull((e) => e.selected)?.id;
    selectedSub = sub.firstWhereOrNull((e) => e.selected)?.id;
  }

  MediaTrackGroup.empty() : video = [], sub = [], audio = [];

  MediaTrackGroup.fromTracks(List<MediaTrack> tracks)
    : audio = tracks.where((track) => track.type == 'audio').toList(),
      video = tracks.where((track) => track.type == 'video').toList(),
      sub = tracks.where((track) => track.type == 'sub').toList(),
      selectedVideo = tracks.firstWhereOrNull((track) => track.type == 'video' && track.selected)?.id,
      selectedAudio = tracks.firstWhereOrNull((track) => track.type == 'audio' && track.selected)?.id,
      selectedSub = tracks.firstWhereOrNull((track) => track.type == 'sub' && track.selected)?.id;
  final List<MediaTrack> video;
  final List<MediaTrack> audio;
  final List<MediaTrack> sub;

  dynamic selectedVideo;
  dynamic selectedAudio;
  dynamic selectedSub;
}

class MediaChange {
  MediaChange.fromJson(Map<String, dynamic> json)
    : index = json['index'],
      position = Duration(milliseconds: json['position']);
  final int index;
  final Duration position;
}

class MediaInfo {
  MediaInfo.fromJson(dynamic json)
    : videoCodecs = json['videoCodecs'],
      videoMime = json['videoMime'],
      videoFPS = json['videoFPS'],
      videoSize = json['videoSize'],
      videoBitrate = json['videoBitrate'],
      audioCodecs = json['audioCodecs'],
      audioMime = json['audioMime'],
      audioBitrate = json['audioBitrate'];
  final String? videoCodecs;
  final String? videoMime;
  final double? videoFPS;
  final int? videoBitrate;
  final String? videoSize;
  final String? audioCodecs;
  final String? audioMime;
  final int? audioBitrate;
}

enum AspectRatioType {
  auto,
  a16_9,
  a4_3,
  a1_1;

  double? value() {
    return switch (this) {
      AspectRatioType.auto => null,
      AspectRatioType.a16_9 => 1.778,
      AspectRatioType.a4_3 => 1.333,
      AspectRatioType.a1_1 => 1.0,
    };
  }

  String label() {
    return switch (this) {
      AspectRatioType.auto => 'Auto',
      AspectRatioType.a16_9 => '16 / 9',
      AspectRatioType.a4_3 => '4 / 3',
      AspectRatioType.a1_1 => '1 / 1',
    };
  }
}

enum ResizeMode {
  fit,
  fixedWidth,
  fixedHeight,
  fill,
  zoom;

  String label() {
    return switch (this) {
      ResizeMode.fit => 'Fit',
      ResizeMode.fixedWidth => 'Fixed Width',
      ResizeMode.fixedHeight => 'Fixed Height',
      ResizeMode.fill => 'Fill',
      ResizeMode.zoom => 'Zoom',
    };
  }
}

class PlaylistItemDisplay<T> extends Equatable {
  const PlaylistItemDisplay({
    required this.source,
    this.fileId,
    this.title,
    this.description,
    this.poster,
    this.url,
    this.start = Duration.zero,
    this.end = Duration.zero,
  });

  final String? title;
  final String? description;
  final String? poster;
  final String? fileId;
  final Uri? url;
  final T source;
  final Duration start;
  final Duration end;

  PlaylistItemDisplay<T> copyWith({
    String? poster,
    String? title,
    String? description,
    String? mimeType,
    Uri? url,
    Duration? start,
    Duration? end,
    T? source,
  }) {
    return PlaylistItemDisplay(
      fileId: fileId,
      poster: poster ?? this.poster,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      start: start ?? this.start,
      end: end ?? this.end,
      source: source ?? this.source,
    );
  }

  PlaylistItem toItem({Uri? url, List<Subtitle> subtitles = const []}) {
    return PlaylistItem(
      poster: poster,
      title: title,
      description: description,
      url: url ?? this.url!,
      start: start,
      end: end,
      subtitles: subtitles,
    );
  }

  @override
  List<Object?> get props => [title, description, poster];
}

class PlaylistItem extends Equatable {
  const PlaylistItem({
    required this.url,
    this.mimeType,
    this.title,
    this.description,
    this.poster,
    this.subtitles,
    this.start = Duration.zero,
    this.end = Duration.zero,
    this.others,
  });

  final String? poster;
  final String? title;
  final String? description;
  final String? mimeType;
  final Uri url;
  final Duration start;
  final Duration end;
  final List<Subtitle>? subtitles;
  final dynamic others;

  PlaylistItem copyWith({
    String? poster,
    String? title,
    String? description,
    String? mimeType,
    Uri? url,
    Duration? start,
    Duration? end,
    Duration? duration,
    List<Subtitle>? subtitles,
    dynamic others,
  }) {
    return PlaylistItem(
      poster: poster ?? this.poster,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      mimeType: mimeType ?? this.mimeType,
      start: start ?? this.start,
      end: end ?? this.end,
      subtitles: subtitles ?? this.subtitles,
      others: others ?? this.others,
    );
  }

  Map<String, dynamic> toSource() {
    return {
      'url': url.toString(),
      'mimeType': parseMimeType(url),
      'title': title,
      'description': description,
      'poster': poster,
      'start': start.inMilliseconds,
      'end': end.inMilliseconds,
      'subtitle': subtitles?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [url, title, poster];
}

String? parseMimeType(Uri uri) {
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    final path = uri.path;
    final ext = path.split('.').last;
    switch (ext.toLowerCase()) {
      case 'm3u8':
        return 'application/x-mpegURL';
      case 'mp4':
      case 'mkv':
        return null;
      case 'php':
        return 'application/x-mpegURL';
      default:
        if (ext.length > 4) {
          return 'application/x-mpegURL';
        } else {
          return null;
        }
    }
  } else {
    return null;
  }
}

enum SubtitleMimeType {
  xml,
  vtt,
  ass,
  srt;

  static SubtitleMimeType? fromString(String? str) {
    if (str?.toLowerCase() == 'subrip') {
      return SubtitleMimeType.srt;
    }
    return SubtitleMimeType.values.firstWhereOrNull((element) => element.name == str);
  }
}

class Subtitle {
  const Subtitle({required this.url, required this.mimeType, this.language, this.label, this.selected = false});

  final Uri url;
  final SubtitleMimeType mimeType;
  final String? language;
  final String? label;
  final bool selected;

  Map<String, dynamic> toJson() {
    return {
      'url': url.toString(),
      'mimeType': mimeType.name,
      'language': language,
      'label': label,
      'selected': selected,
    };
  }
}

class SubtitleSettings extends Equatable {
  const SubtitleSettings({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.windowColor,
    required this.edgeColor,
  });

  SubtitleSettings.fromJson(List<int> json)
    : foregroundColor = Color(json[0]),
      backgroundColor = Color(json[1]),
      windowColor = Color(json[2]),
      edgeColor = Color(json[3]);
  final Color foregroundColor;
  final Color backgroundColor;
  final Color windowColor;
  final Color edgeColor;

  List<int> toJson() {
    // ignore: deprecated_member_use
    return [foregroundColor, backgroundColor, windowColor, edgeColor].map((c) => c.value).toList();
  }

  @override
  List<Object?> get props => [foregroundColor, backgroundColor, windowColor, edgeColor];
}
