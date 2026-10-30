enum MediaType { movie, series, season, episode }

enum DriverType { local, webdav, alipan, quark, emby, jellyfin }

enum QueryType { genre, studio, keyword, actor }

enum FileType { file, folder }

enum FileCategory {
  video,
  audio,
  image,
  doc,
  other;

  static FileCategory fromInt(int index) {
    return index == 255 ? FileCategory.other : FileCategory.values.elementAt(index);
  }
}

enum MediaStatus {
  returningSeries,
  ended,
  released,
  unknown;

  static MediaStatus fromString(String? name) {
    return switch (name) {
      'Returning Series' => MediaStatus.returningSeries,
      'Ended' => MediaStatus.ended,
      'Released' => MediaStatus.released,
      'Unknown' => MediaStatus.unknown,
      _ => MediaStatus.unknown,
    };
  }
}

enum LibraryType { tv, movie }

enum SkipTimeType { intro, ending }

enum SessionStatus { created, progressing, data, finished, failed }

// ignore: unused_field
enum SortType { _default, title, airDate, createAt, lastPlayedTime }

enum SortDirection { asc, desc }

enum FilterType { favorite, exceptFavorite, watched, unwatched }

enum ScraperType { tmdb, nfo }

enum NetworkDiagnosticsStatus { success, fail }

enum ServerType { local, remote, emby, jellyfin }

enum DownloadTaskStatus { idle, downloading, complete, failed }

enum ScheduleTaskType { syncLibrary, scrapeLibrary }

enum ScheduleTaskStatus { idle, running, paused, completed, error }

enum ScraperBehavior { skip, chooseFirst, exact }

enum SearchFuzzyType { all, movie, series, episode, cast, crew }
