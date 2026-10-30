// ignore_for_file: avoid_dynamic_calls

import 'package:equatable/equatable.dart';

import 'enums.dart';

class SortConfig {
  const SortConfig({this.filter, required this.type, required this.direction});

  final FilterType? filter;
  final SortType type;
  final SortDirection direction;
}

class MediaSearchQuery {
  const MediaSearchQuery({this.sort, this.limit, this.offset});

  final SortConfig? sort;
  final int? limit;
  final int? offset;

  Map<String, dynamic> toMap() {
    return {
      'type': sort?.type.index ?? 0,
      'direction': sort?.direction.index ?? 0,
      'filter': sort?.filter?.index,
      'limit': limit,
      'offset': offset,
    };
  }
}

abstract class MediaBase extends Equatable {
  MediaBase.fromJson(dynamic json)
    : id = json[0],
      title = json[1],
      poster = json[2],
      logo = json[3],
      backdrop = json[4],
      themeColor = json[5],
      watched = json[6],
      favorite = json[7],
      overview = json[8],
      updateAt = json[9],
      mediaCast = listFromJson(json[10], MediaCast.fromJson),
      mediaCrew = listFromJson(json[11], MediaCrew.fromJson);

  final dynamic id;
  final String? title;
  final String? poster;
  final String? logo;
  final String? backdrop;
  final int? themeColor;
  final bool watched;
  final bool favorite;
  final String? overview;
  final String updateAt;
  final List<MediaCast> mediaCast;
  final List<MediaCrew> mediaCrew;

  DateTime? get displayAirDate;

  @override
  List<Object?> get props => [id, updateAt];
}

abstract class Media extends MediaBase {
  Media.fromJson(super.json) : voteAverage = json[12], voteCount = json[13], super.fromJson();
  final int? voteCount;
  final double? voteAverage;
}

class MediaRecommendation {
  MediaRecommendation.fromJson(dynamic json)
    : id = json[0],
      title = json[1],
      originalTitle = json[2],
      overview = json[3],
      poster = json[4],
      logo = json[5],
      backdrop = json[6],
      voteAverage = json[7],
      voteCount = json[8],
      themeColor = json[9],
      status = MediaStatus.fromString(json[10]),
      airDate = (json[11] as List<dynamic>?)?.cast<int>().toDateTime(),
      genres = listFromJson(json[12], Genre.fromJson),
      scraper = Scraper.fromJson(json[13]);
  final dynamic id;
  final String? title;
  final String? originalTitle;
  final DateTime? airDate;
  final String? poster;
  final String? logo;
  final String? backdrop;
  final String? overview;
  final int? themeColor;
  final double? voteAverage;
  final int? voteCount;
  final MediaStatus status;
  final List<Genre> genres;
  final Scraper scraper;

  String displayTitle() {
    if (title != null && originalTitle != null) {
      return title == originalTitle ? title! : '$title ($originalTitle)';
    } else {
      return title ?? originalTitle ?? '';
    }
  }
}

class Movie extends Media {
  Movie.fromJson(super.json)
    : lastPlayedTime = (json[14] as String?)?.toDateTime(),
      lastPlayedPosition = (json[15] as int?).toDuration(),
      originalTitle = json[16],
      country = json[17],
      status = MediaStatus.fromString(json[18]),
      genres = listFromJson(json[19], Genre.fromJson),
      studios = listFromJson(json[20], Studio.fromJson),
      keywords = listFromJson(json[21], Keyword.fromJson),
      downloaded = json[22] ?? false,
      fileId = json[23],
      duration = (json[24] as int?).toDuration(),
      releaseDate = (json[25] as List<dynamic>?)?.cast<int>().toDateTime(),
      scraper = Scraper.fromJson(json[26]),
      super.fromJson();
  final String? country;
  final MediaStatus status;
  final List<Genre> genres;
  final List<Studio> studios;
  final List<Keyword> keywords;
  final Duration? lastPlayedPosition;
  final bool downloaded;
  final String? fileId;
  final DateTime? releaseDate;
  final Duration? duration;
  final Scraper scraper;
  final DateTime? lastPlayedTime;
  final String? originalTitle;

  String displayTitle() {
    if (title != null && originalTitle != null) {
      return title == originalTitle ? title! : '$title ($originalTitle)';
    } else {
      return title ?? originalTitle ?? '';
    }
  }

  String displayRecentTitle() {
    return displayTitle();
  }

  @override
  DateTime? get displayAirDate => releaseDate;
}

class TVSeries extends Media {
  TVSeries.fromJson(super.json)
    : lastPlayedTime = (json[14] as String?)?.toDateTime(),
      originalTitle = json[15],
      country = json[16],
      trailer = json[17],
      status = MediaStatus.fromString(json[18]),
      skipIntro = (json[19] as int?).toDuration(),
      skipEnding = (json[20] as int?).toDuration(),
      genres = listFromJson(json[21], Genre.fromJson),
      studios = listFromJson(json[22], Studio.fromJson),
      keywords = listFromJson(json[23], Keyword.fromJson),
      seasons = listFromJson(json[24], TVSeason.fromJson),
      nextToPlay = json[25] == null ? null : TVEpisode.fromJson(json[25]),
      firstAirDate = (json[26] as List<dynamic>?)?.cast<int>().toDateTime(),
      lastAirDate = (json[27] as List<dynamic>?)?.cast<int>().toDateTime(),
      scraper = Scraper.fromJson(json[28]),
      super.fromJson();
  final DateTime? lastPlayedTime;
  final String? country;
  final String? trailer;
  final MediaStatus status;
  final Duration skipIntro;
  final Duration skipEnding;
  final List<Genre> genres;
  final List<Studio> studios;
  final List<Keyword> keywords;
  final List<TVSeason> seasons;
  final TVEpisode? nextToPlay;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final Scraper scraper;
  final String? originalTitle;

  @override
  DateTime? get displayAirDate => firstAirDate;

  String displayTitle() {
    if (title != null && originalTitle != null) {
      return title == originalTitle ? title! : '$title ($originalTitle)';
    } else {
      return title ?? originalTitle ?? '';
    }
  }

  String displayRecentTitle() {
    return displayTitle();
  }
}

class TVSeason extends MediaBase {
  TVSeason.fromJson(super.json)
    : season = json[12],
      seriesId = json[13],
      seriesTitle = json[14],
      skipIntro = (json[15] as int?).toDuration(),
      skipEnding = (json[16] as int?).toDuration(),
      episodeCount = json[17],
      airDate = (json[18] as List<dynamic>?)?.cast<int>().toDateTime(),
      episodes = listFromJson(json[19], TVEpisode.fromJson),
      scraper = Scraper.fromJson(json[20]),
      super.fromJson();
  final int season;
  final dynamic seriesId;
  final String? seriesTitle;
  final Duration skipIntro;
  final Duration skipEnding;
  final int? episodeCount;
  final DateTime? airDate;
  final List<TVEpisode> episodes;
  final Scraper scraper;

  @override
  DateTime? get displayAirDate => airDate;
}

class TVEpisode extends MediaBase {
  TVEpisode.fromJson(super.json)
    : lastPlayedTime = (json[12] as String?)?.toDateTime(),
      episode = json[13],
      season = json[14],
      seriesId = json[15],
      seasonId = json[16],
      seriesTitle = json[17],
      seasonTitle = json[18],
      skipIntro = (json[19] as int?).toDuration(),
      skipEnding = (json[20] as int?).toDuration(),
      lastPlayedPosition = (json[21] as int?).toDuration(),
      downloaded = json[22] ?? false,
      fileId = json[23],
      duration = (json[24] as int?).toDuration(),
      guestStars = listFromJson(json[25], MediaCast.fromJson),
      airDate = (json[26] as List<dynamic>?)?.cast<int>().toDateTime(),
      scraper = Scraper.fromJson(json[27]),
      super.fromJson();
  final int episode;
  final int season;
  final dynamic seasonId;
  final dynamic seriesId;
  final String? seriesTitle;
  final String? seasonTitle;
  final Duration skipIntro;
  final Duration skipEnding;
  final Duration? lastPlayedPosition;
  final bool downloaded;
  final List<MediaCast> guestStars;
  final String? fileId;
  final Duration? duration;
  final DateTime? lastPlayedTime;
  final DateTime? airDate;
  final Scraper scraper;

  @override
  DateTime? get displayAirDate => airDate;

  String displayTitle() => title ?? '';

  String displayRecentTitle() => '$seriesTitle S$season E$episode - $title';
}

class Scraper {
  Scraper.fromJson(dynamic json) : type = json[0] != null ? ScraperType.values.elementAt(json[0]) : null, id = json[1];
  final ScraperType? type;
  final String? id;
}

class MediaCast {
  MediaCast.fromJson(dynamic json)
    : id = json[0],
      name = json[1],
      knownForDepartment = json[2],
      originalName = json[3],
      adult = json[4],
      gender = json[5],
      role = json[6],
      profile = json[7],
      episodeCount = json[8],
      popularity = json[9],
      scraper = Scraper.fromJson(json[10]);
  final dynamic id;
  final String name;
  final String? originalName;
  final String? knownForDepartment;
  final bool? adult;
  final int? gender;
  final String? role;
  final String? profile;
  final double? popularity;
  final int? episodeCount;
  final Scraper scraper;
}

class MediaCrew {
  MediaCrew.fromJson(dynamic json)
    : id = json[0],
      name = json[1],
      originalName = json[2],
      adult = json[3],
      gender = json[4],
      job = json[5],
      knownForDepartment = json[6],
      department = json[7],
      profile = json[8],
      episodeCount = json[9],
      popularity = json[10],
      scraper = Scraper.fromJson(json[11]);
  final dynamic id;
  final String name;
  final String? originalName;
  final String? knownForDepartment;
  final String? department;
  final bool? adult;
  final int? gender;
  final String? job;
  final String? profile;
  final double? popularity;
  final int? episodeCount;
  final Scraper scraper;
}

class Genre extends Equatable {
  Genre.fromJson(dynamic json) : id = json[0], name = json[1], scraper = Scraper.fromJson(json[2]), super();
  final String name;
  final dynamic id;
  final Scraper scraper;

  @override
  List<Object?> get props => [id];
}

class Keyword extends Equatable {
  Keyword.fromJson(dynamic json) : id = json[0], name = json[1], scraper = Scraper.fromJson(json[2]), super();
  final String name;
  final dynamic id;
  final Scraper scraper;

  @override
  List<Object?> get props => [id];
}

class Studio extends Equatable {
  Studio.fromJson(dynamic json)
    : id = json[0],
      name = json[1],
      country = json[2],
      logo = json[3],
      scraper = Scraper.fromJson(json[4]),
      super();
  final dynamic id;
  final String name;
  final String? country;
  final String? logo;
  final Scraper scraper;

  @override
  List<Object?> get props => [id];
}

class SubtitleData {
  const SubtitleData({this.id, this.url, this.mimeType, this.label, this.language, this.selected = false});

  SubtitleData.fromJson(dynamic json)
    : id = json[0],
      url = json[1],
      label = json[2],
      mimeType = json[3],
      language = json[4],
      selected = json[5];
  final dynamic id;
  final String? url;
  final String? label;
  final String? language;
  final String? mimeType;
  final bool selected;

  static const SubtitleData empty = SubtitleData();
}

class Library {
  Library.fromJson(dynamic json)
    : id = json[0],
      driverName = json[1],
      driverType = DriverType.values.elementAt(json[2]),
      driverAvatar = json[3],
      poster = json[4],
      driverId = json[5],
      filename = json[7],
      type = LibraryType.values.elementAt(json[8]);
  final dynamic id;
  final int driverId;
  final String filename;
  final String driverName;
  final DriverType driverType;
  final LibraryType type;
  final String? driverAvatar;
  final String? poster;
}

class DNSOverride {
  const DNSOverride({required this.id, required this.domain, required this.ip});

  DNSOverride.fromJson(dynamic json) : id = json[0], domain = json[1], ip = json[2];
  final int id;
  final String domain;
  final String ip;
}

class Server {
  Server.fromJson(dynamic json)
    : id = json[0],
      type = ServerType.values.elementAt(json[1]),
      invalid = json[2],
      host = json[3],
      active = json[4],
      username = json[5];
  final int id;
  final String host;
  final bool active;
  final bool invalid;
  final ServerType type;
  final String? username;
}

class Playlist {
  Playlist.fromJson(dynamic json) : id = json[0], url = json[1], title = json[2];
  final int id;
  final String url;
  final String? title;
}

class Channel {
  Channel.fromJson(dynamic json)
    : id = json[0],
      links = (json[1] as List<dynamic>).map((l) => Uri.tryParse(l)).nonNulls.toList(),
      title = json[2],
      image = json[3],
      category = json[4];
  final int id;
  final List<Uri> links;
  final String? title;
  final String? image;
  final String? category;
}

class ChannelEpgItem {
  ChannelEpgItem.fromJson(dynamic json)
    : start = epgTimeToDateTime(json[0]),
      stop = epgTimeToDateTime(json[1]),
      title = json[2];
  DateTime? start;
  DateTime? stop;
  String title;
}

class SearchResult {
  SearchResult.fromJson(dynamic json)
    : id = json[0],
      title = json[1],
      originalTitle = json[3],
      type = ScraperType.values.elementAt(json[2]),
      overview = json[4],
      poster = json[5],
      airDate = (json[6] as List?)?.cast<int>().toDateTime(),
      language = json[7];
  final String id;
  final String title;
  final ScraperType type;
  final String? originalTitle;
  final String? overview;
  final String? poster;
  final DateTime? airDate;
  final String? language;
}

class SearchFuzzyResult {
  SearchFuzzyResult.fromJson(dynamic json)
    : movies = PageData.fromJson(json[0], Movie.fromJson),
      series = PageData.fromJson(json[1], TVSeries.fromJson),
      episodes = PageData.fromJson(json[2], TVEpisode.fromJson),
      mediaCast = PageData.fromJson(json[3], MediaCast.fromJson),
      mediaCrew = PageData.fromJson(json[4], MediaCrew.fromJson);
  final PageData<Movie> movies;
  final PageData<TVSeries> series;
  final PageData<TVEpisode> episodes;
  final PageData<MediaCast> mediaCast;
  final PageData<MediaCrew> mediaCrew;
}

class Session<T> {
  Session.fromJson(dynamic json) : status = SessionStatus.values.elementAt(json[0]), data = json[1];
  final SessionStatus status;
  final T? data;
}

class SessionCreate {
  const SessionCreate({required this.id, required this.uri});

  final String id;
  final Uri uri;
}

class DriverAccount {
  DriverAccount.fromJson(dynamic json)
    : id = json[0],
      type = DriverType.values.elementAt(json[1]),
      name = json[2],
      avatar = json[3];
  int id;
  DriverType type;
  String name;
  String? avatar;
}

class DriverFileInfo {
  DriverFileInfo.fromJson(dynamic json)
    : filename = json[0],
      size = json[1],
      driverType = DriverType.values.elementAt(json[2]),
      createdAt = (json[3] as String).toDateTime()!;
  final String filename;
  final int size;
  final DriverType driverType;
  final DateTime createdAt;
}

class DriverFile {
  DriverFile.fromJson(dynamic json)
    : name = json[0],
      category = json[1] == null ? null : FileCategory.fromInt(json[1]),
      id = json[2],
      parentId = json[3],
      fileId = json[4],
      type = FileType.values.elementAt(json[5]),
      createdAt = (json[6] as String?)?.toDateTime(),
      updatedAt = (json[7] as String?)?.toDateTime(),
      size = json[8],
      url = json[9] != null ? Uri.tryParse(json[9]) : null;
  final String name;
  final String id;
  final String parentId;
  final FileType type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final FileCategory? category;
  final int? size;
  final Uri? url;
  final String? fileId;
}

class PlayerHistory {
  PlayerHistory.fromJson(dynamic json)
    : id = json[0],
      mediaType = MediaType.values.elementAt(json[1]),
      title = json[2],
      poster = json[3],
      duration = (json[4] as int?).toDuration(),
      lastPlayedPosition = (json[5] as int?).toDuration(),
      lastPlayedTime = ((json[6] as String?)?.toDateTime())!;
  final dynamic id;
  final MediaType mediaType;
  final String title;
  final String? poster;
  final Duration duration;
  final DateTime lastPlayedTime;
  final Duration lastPlayedPosition;
}

class PlaybackInfo {
  PlaybackInfo.fromJson(dynamic json)
    : url = json[0],
      container = json[1],
      subtitles = listFromJson(json[2], SubtitleData.fromJson),
      others = json[3];
  final String url;
  final String? container;
  final List<SubtitleData> subtitles;
  final dynamic others;
}

class DownloadTask {
  DownloadTask.fromJson(dynamic json)
    : id = json[0],
      title = json[1],
      size = json[2],
      elapsed = Duration(seconds: json[3]),
      speed = json[4],
      progress = json[5],
      poster = json[6],
      status = DownloadTaskStatus.values.elementAt(json[7]),
      mediaType = MediaType.values.elementAt(json[8]),
      mediaId = json[9],
      createdAt = (json[10] as String).toDateTime()!;
  final int id;
  final dynamic mediaId;
  final String? poster;
  final int size;
  final double? progress;
  final int? speed;
  final Duration elapsed;
  final String title;
  final MediaType mediaType;
  final DateTime createdAt;
  final DownloadTaskStatus status;
}

class ScheduleTask {
  ScheduleTask.fromJson(dynamic json)
    : id = json[0],
      rid = json[1],
      pid = json[2],
      type = ScheduleTaskType.values.elementAt(json[3]),
      status = ScheduleTaskStatus.values.elementAt(json[4]),
      data = json[5];
  final int id;
  final int rid;
  final int? pid;
  final ScheduleTaskType type;
  final ScheduleTaskStatus status;
  final dynamic data;
}

class SettingScraper {
  const SettingScraper({
    required this.nfoEnabled,
    required this.tmdbEnabled,
    required this.behavior,
    required this.tmdbMaxCast,
    required this.tmdbMaxCrew,
  });

  SettingScraper.fromJson(dynamic json)
    : nfoEnabled = json[0],
      tmdbEnabled = json[1],
      behavior = ScraperBehavior.values.elementAt(json[2]),
      tmdbMaxCast = json[3],
      tmdbMaxCrew = json[4];
  final bool nfoEnabled;
  final bool tmdbEnabled;
  final ScraperBehavior behavior;
  final int tmdbMaxCast;
  final int tmdbMaxCrew;

  Map<String, dynamic> toJson() {
    return {
      'nfoEnabled': nfoEnabled,
      'tmdbEnabled': tmdbEnabled,
      'behavior': behavior.index,
      'tmdbMaxCast': tmdbMaxCast,
      'tmdbMaxCrew': tmdbMaxCrew,
    };
  }

  SettingScraper copyWith({
    bool? nfoEnabled,
    bool? tmdbEnabled,
    ScraperBehavior? behavior,
    int? tmdbMaxCast,
    int? tmdbMaxCrew,
  }) {
    return SettingScraper(
      nfoEnabled: nfoEnabled ?? this.nfoEnabled,
      tmdbEnabled: tmdbEnabled ?? this.tmdbEnabled,
      behavior: behavior ?? this.behavior,
      tmdbMaxCast: tmdbMaxCast ?? this.tmdbMaxCast,
      tmdbMaxCrew: tmdbMaxCrew ?? this.tmdbMaxCrew,
    );
  }
}

class NetworkDiagnostics extends Equatable {
  NetworkDiagnostics.fromJson(dynamic json)
    : status = NetworkDiagnosticsStatus.values.elementAt(json[0]),
      domain = json[1],
      ip = json[2],
      error = json[3],
      tip = json[4];
  final NetworkDiagnosticsStatus status;
  final String domain;
  final String? ip;
  final String? error;
  final String? tip;

  @override
  List<Object?> get props => [status, domain];
}

class PageData<D> {
  PageData.fromJson(dynamic json, D Function(dynamic) itemFromJson)
    : offset = json[0],
      limit = json[1],
      count = json[2],
      data = (json[3] as List).map(itemFromJson).toList();
  final int offset;
  final int limit;
  final int count;
  final List<D> data;
}

class IdResponse {
  IdResponse.fromJson(dynamic json) : id = json[0];
  final dynamic id;
}

extension on int? {
  Duration toDuration() {
    return Duration(milliseconds: this ?? 0);
  }
}

extension on String {
  DateTime? toDateTime() {
    return DateTime.tryParse(this)?.toLocal();
  }
}

extension on List<int> {
  DateTime? toDateTime() {
    return DateTime(this[0], 1, this[1]);
  }
}

DateTime? epgTimeToDateTime(String? s) {
  if (s == null) {
    return null;
  } else {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(s.substring(0, 2)), int.parse(s.substring(3, 5)));
  }
}

List<T> listFromJson<T>(List<dynamic>? data, T Function(dynamic) converter) {
  return List.generate(data?.length ?? 0, (index) => converter(data![index]));
}
