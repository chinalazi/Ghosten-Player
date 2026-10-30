import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'api_method_channel.dart';
import 'enums.dart';
import 'models.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

abstract class ApiPlatform extends PlatformInterface {
  ApiPlatform() : super(token: _token);

  static final Object _token = Object();

  static ApiPlatform _instance = MethodChannelApi();

  static ApiPlatform get instance => _instance;

  static set instance(ApiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  abstract final ApiClient client;

  abstract Uri baseUrl;

  Future<String?> databasePath() {
    throw UnimplementedError('databasePath() has not been implemented.');
  }

  Future<bool?> initialized() async => true;

  Future<void> syncData(String filePath) {
    return client.post('/data/sync', data: {'path': filePath});
  }

  Future<void> rollbackData() {
    return client.post('/data/rollback');
  }

  Future<void> resetData() {
    return client.post('/data/reset');
  }

  Stream<T> streamWithCallback<T, D>(Future<dynamic> future, T Function(D) callback);

  /// File Start
  Future<DriverFileInfo> fileInfo(String id) async {
    final data = await client.get('/file/info', queryParameters: {'id': id});
    return DriverFileInfo.fromJson(data);
  }

  Future<List<DriverFile>> fileList(int driverId, String parentFileId, {FileType? type, FileCategory? category}) async {
    final data = await client.post(
      '/file/list',
      data: {'driverId': driverId, 'parentFileId': parentFileId, 'type': type?.index, 'category': category?.index},
    );
    return listFromJson(data, DriverFile.fromJson);
  }

  Future<void> fileRename(int driverId, String fileId, String newName) {
    return client.post('/file/rename', data: {'driverId': driverId, 'fileId': fileId, 'name': newName});
  }

  Future<void> fileRemove(int driverId, String fileId) {
    return client.delete('/file/remove', data: {'driverId': driverId, 'fileId': fileId});
  }

  Future<void> fileMkdir(int driverId, String parentFileId, String name) {
    return client.put('/file/mkdir', data: {'driverId': driverId, 'parentFileId': parentFileId, 'name': name});
  }

  Future<PlaybackInfo> playbackInfo(dynamic id) async {
    final data = await client.get('/playback/info', queryParameters: {'id': id});
    return PlaybackInfo.fromJson(data);
  }

  /// File End

  /// Player Start
  Future<List<PlayerHistory>> playerHistory() async {
    final data = await client.get('/player/history');
    return listFromJson(data, PlayerHistory.fromJson);
  }

  /// Player End

  /// Subtitle Start
  Future<List<SubtitleData>> subtitleQueryById(String id) async {
    final data = await client.get('/subtitle/query/id', queryParameters: {'id': id});
    return listFromJson(data, SubtitleData.fromJson);
  }

  Future<void> subtitleInsert(String id, SubtitleData subtitle) {
    return client.put(
      '/subtitle/update/id',
      data: {
        'id': id,
        'label': subtitle.label,
        'url': subtitle.url?.toString(),
        'mimeType': subtitle.mimeType,
        'language': subtitle.language,
        'selected': subtitle.selected,
      },
    );
  }

  Future<void> subtitleDeleteById(dynamic id) {
    return client.delete('/subtitle/delete/id', data: {'id': id});
  }

  /// Subtitle End

  /// Setting Start
  Future<SettingScraper> settingScraperQuery() async {
    final data = await client.get('/setting/scraper/query');
    return SettingScraper.fromJson(data);
  }

  Future<void> settingScraperUpdate(SettingScraper data) {
    return client.post('/setting/scraper/update', data: data.toJson());
  }

  /// Setting End

  /// DownloadTask Start
  Future<void> downloadTaskCreate(dynamic id, Future<void> checkPermission) {
    return client.put('/download/task/create', data: {'id': id});
  }

  Future<void> downloadTaskPauseById(int id) {
    return client.post('/download/task/pause/id', data: {'id': id});
  }

  Future<void> downloadTaskResumeById(int id) {
    return client.post('/download/task/resume/id', data: {'id': id});
  }

  Future<void> downloadTaskDeleteById(int id, {bool deleteFile = false}) {
    return client.delete('/download/task/delete/id', data: {'id': id, 'deleteFile': deleteFile});
  }

  Future<List<DownloadTask>> downloadTaskQueryByAll() async {
    final data = await client.get('/download/task/query/all');
    return listFromJson(data, DownloadTask.fromJson);
  }

  /// DownloadTask End

  /// ScheduleTask Start
  Future<List<ScheduleTask>> scheduleTaskQueryByAll() async {
    final data = await client.get('/schedule/task/query/all');
    return listFromJson(data, ScheduleTask.fromJson);
  }

  Future<void> scheduleTaskPauseById(int id) {
    return client.post('/schedule/task/pause/id', data: {'id': id});
  }

  Future<void> scheduleTaskResumeById(int id) {
    return client.post('/schedule/task/resume/id', data: {'id': id});
  }

  Future<void> scheduleTaskDeleteById(int id) {
    return client.delete('/schedule/task/delete/id', data: {'id': id});
  }

  /// ScheduleTask End

  /// Session Start
  Future<Session<T>> sessionStatus<T>(String id) async {
    final data = await client.get('/session/status', queryParameters: {'id': id});
    return Session.fromJson(data);
  }

  Future<SessionCreate> sessionCreate() async {
    final data = await client.put('/session/create');
    final id = IdResponse.fromJson(data).id;
    return SessionCreate(
      id: id,
      uri: baseUrl.replace(path: '/session/webpage', queryParameters: {'id': id.toString()}),
    );
  }

  /// Session End

  /// DNS Start

  Future<List<DNSOverride>> dnsOverrideQueryAll() async {
    final data = await client.get('/dns/override/query/all');
    return listFromJson(data, DNSOverride.fromJson);
  }

  Future<void> dnsOverrideInsert({required String domain, required String ip}) {
    return client.put('/dns/override/insert', data: {'domain': domain, 'ip': ip});
  }

  Future<void> dnsOverrideUpdateById({required int id, required String domain, required String ip}) {
    return client.post('/dns/override/update/id', data: {'id': id, 'domain': domain, 'ip': ip});
  }

  Future<void> dnsOverrideDeleteById(int id) {
    return client.delete('/dns/override/delete/id', data: {'id': id});
  }

  /// DNS End

  /// Server Start
  Future<List<Server>> serverQueryAll() async {
    final data = await client.get('/server/query/all');
    return listFromJson(data, Server.fromJson);
  }

  Future<void> serverInsert({
    required ServerType type,
    required String host,
    required String username,
    String? userPassword,
    String? userAgent,
  }) {
    return client.put(
      '/server/insert',
      data: {
        'type': type.index,
        'host': host.trim(),
        'username': username.trim(),
        'userPassword': userPassword?.trim(),
        'userAgent': (userAgent?.isNotEmpty ?? false) ? userAgent : null,
      },
    );
  }

  Future<void> serverActiveById(int id) {
    return client.post('/server/active/id', data: {'id': id});
  }

  Future<void> serverDeleteById(int id) {
    return client.delete('/server/delete/id', data: {'id': id});
  }

  /// Server End

  /// Search Start
  Future<SearchFuzzyResult> searchFuzzy(
    SearchFuzzyType type, {
    String? filter,
    List<dynamic>? genres,
    List<dynamic>? studios,
    List<dynamic>? keywords,
    List<dynamic>? mediaCast,
    List<dynamic>? mediaCrew,
    bool? watched,
    bool? favorite,
    required int offset,
    required int limit,
  }) async {
    final data = await client.post(
      '/search/fuzzy',
      data: {
        'type': type.index,
        'filter': filter,
        'genres': genres,
        'studios': studios,
        'keywords': keywords,
        'mediaCast': mediaCast,
        'mediaCrew': mediaCrew,
        'watched': watched,
        'favorite': favorite,
        'offset': offset,
        'limit': limit,
      },
    );
    return SearchFuzzyResult.fromJson(data);
  }

  /// Search End

  /// Playlist Start
  Future<List<Playlist>> playlistQueryAll() async {
    final data = await client.get('/playlist/query/all');
    return listFromJson(data, Playlist.fromJson);
  }

  Future<Playlist> playlistQueryById(dynamic id) async {
    final data = await client.get('/playlist/query/id', queryParameters: {'id': id});
    return Playlist.fromJson(data);
  }

  Future<void> playlistInsert(String url, String? title) {
    return client.put('/playlist/insert', data: {'url': url, 'title': title});
  }

  Future<void> playlistUpdateById(int id, String url, String? title) {
    return client.post('/playlist/update/id', data: {'id': id, 'url': url, 'title': title});
  }

  Future<void> playlistDeleteById(int id) {
    return client.delete('/playlist/delete/id', data: {'id': id});
  }

  Future<void> playlistRefreshById(int id) {
    return client.post('/playlist/refresh/id', data: {'id': id});
  }

  Future<List<Channel>> playlistChannelsQueryById(int id) async {
    final data = await client.get('/playlist/channels/query/id', queryParameters: {'id': id});
    return listFromJson(data, Channel.fromJson);
  }

  Future<List<ChannelEpgItem>> epgQueryByChannelId(int id) async {
    final data = await client.get('/playlist/channel/epg', queryParameters: {'id': id});
    return listFromJson(data, ChannelEpgItem.fromJson);
  }

  /// Playlist End

  /// Driver Start
  Future<List<DriverAccount>> driverQueryAll() async {
    final data = await client.get('/driver/query/all');
    return listFromJson(data, DriverAccount.fromJson);
  }

  Stream<dynamic> driverInsert(DriverType type, {String? url, String? username, String? password, String? token}) {
    return streamWithCallback<dynamic, dynamic>(
      client.put(
        '/driver/insert/cb',
        data: {'type': type.index, 'url': url, 'username': username, 'password': password, 'token': token},
      ),
      (data) => data,
    );
  }

  Future<Map<String, dynamic>> driverSettingQueryById(int id) {
    return client
        .get<Map<String, dynamic>>('/driver/setting/query/id', queryParameters: {'id': id})
        .then((data) => data!);
  }

  Future<void> driverSettingUpdateById(int id, Map<String, dynamic> settings) {
    return client.post('/driver/setting/update/id', data: {'id': id, 'settings': settings});
  }

  Future<void> driverDeleteById(int id) {
    return client.delete('/driver/delete/id', data: {'id': id});
  }

  /// Driver End

  /// Movie Start
  Future<List<MediaRecommendation>> movieRecommendation() async {
    final data = await client.get('/movie/recommendation');
    return listFromJson(data, MediaRecommendation.fromJson);
  }

  Future<PageData<Movie>> movieQueryAll([MediaSearchQuery? query]) async {
    final data = await client.get('/movie/query/all', queryParameters: query?.toMap());
    return PageData.fromJson(data, Movie.fromJson);
  }

  Future<List<Movie>> movieQueryByFilter(QueryType type, dynamic id) async {
    final data = await client.get('/movie/query/filter', queryParameters: {'id': id, 'type': type.index});
    return listFromJson(data, Movie.fromJson);
  }

  Future<Movie> movieQueryById(dynamic id) async {
    final data = await client.get('/movie/query/id', queryParameters: {'id': id});
    return Movie.fromJson(data);
  }

  Future<List<Movie>> movieNextToPlayQueryAll() async {
    final data = await client.get('/movie/nextToPlay/query/all');
    return listFromJson(data, Movie.fromJson);
  }

  Future<void> movieMetadataUpdateById(Map<String, dynamic> data) {
    return client.post('/movie/metadata/update/id', data: data);
  }

  Future<void> movieScraperById(dynamic id, String scraperId, ScraperType scraperType, String? scraperLang) {
    return client.post(
      '/movie/scraper/id',
      data: {'id': id, 'scraperType': scraperType.index, 'scraperId': scraperId, 'scraperLang': scraperLang},
    );
  }

  Future<List<SearchResult>> movieScraperSearch(dynamic id, String title, {String? language, String? year}) async {
    final data = await client.get(
      '/movie/scraper/search',
      queryParameters: {'id': id, 'title': title, 'year': year, 'language': language},
    );
    return listFromJson(data, SearchResult.fromJson);
  }

  Future<void> movieRenameById(dynamic id) {
    return client.post('/movie/rename/id', data: {'id': id});
  }

  Future<void> movieDeleteById(dynamic id) {
    return client.delete('/movie/delete/id', data: {'id': id});
  }

  /// Movie End

  /// TV Start
  Future<List<MediaRecommendation>> tvRecommendation() async {
    final data = await client.get('/tv/recommendation');
    return listFromJson(data, MediaRecommendation.fromJson);
  }

  /// TV Series Start
  Future<PageData<TVSeries>> tvSeriesQueryAll([MediaSearchQuery? query]) async {
    final data = await client.get('/tv/series/query/all', queryParameters: query?.toMap());
    return PageData.fromJson(data, TVSeries.fromJson);
  }

  Future<List<TVSeries>> tvSeriesQueryByFilter(QueryType type, dynamic id) async {
    final data = await client.get('/tv/series/query/filter', queryParameters: {'id': id, 'type': type.index});
    return listFromJson(data, TVSeries.fromJson);
  }

  Future<TVSeries> tvSeriesQueryById(dynamic id) async {
    final data = await client.get('/tv/series/query/id', queryParameters: {'id': id});
    return TVSeries.fromJson(data);
  }

  Future<List<TVEpisode>> tvSeriesNextToPlayQueryAll() async {
    final data = await client.get('/tv/series/nextToPlay/query/all');
    return listFromJson(data, TVEpisode.fromJson);
  }

  Future<void> tvSeriesScraperById(dynamic id, String scraperId, ScraperType scraperType, String? language) {
    return client.post(
      '/tv/series/scraper/id',
      data: {'id': id, 'scraperType': scraperType.index, 'scraperId': scraperId, 'scraperLang': language},
    );
  }

  Future<List<SearchResult>> tvSeriesScraperSearch(dynamic id, String title, {String? language, String? year}) async {
    final data = await client.get(
      '/tv/series/scraper/search',
      queryParameters: {'id': id, 'title': title, 'year': year, 'language': language},
    );
    return listFromJson(data, SearchResult.fromJson);
  }

  Future<void> tvSeriesSyncById(dynamic id) {
    return client.post('/tv/series/sync/id', data: {'id': id});
  }

  Future<void> tvSeriesMetadataUpdateById(Map<String, dynamic> data) {
    return client.post('/tv/series/metadata/update/id', data: data);
  }

  Future<void> tvSeriesRenameById(dynamic id) {
    return client.post('/tv/series/rename/id', data: {'id': id});
  }

  Future<void> tvSeriesDeleteById(dynamic id) {
    return client.delete('/tv/series/delete/id', data: {'id': id});
  }

  /// TV Series End

  /// TV Season Start
  Future<TVSeason> tvSeasonQueryById(dynamic id) async {
    final data = await client.get('/tv/season/query/id', queryParameters: {'id': id});
    return TVSeason.fromJson(data);
  }

  Future<int> tvSeasonNumberUpdate(TVSeason season, int seasonNum) async {
    final data = await client.post('/tv/season/number/update', data: {'id': season.id, 'season': seasonNum});
    return IdResponse.fromJson(data).id;
  }

  Future<void> tvSeasonDeleteById(dynamic id) {
    return client.post('/tv/season/delete/id', data: {'id': id});
  }

  /// TV Season End

  /// TV Episode Start
  Future<TVEpisode> tvEpisodeQueryById(dynamic id) async {
    final data = await client.get('/tv/episode/query/id', queryParameters: {'id': id});
    return TVEpisode.fromJson(data);
  }

  Future<void> tvEpisodeMetadataUpdateById(Map<String, dynamic> data) {
    return client.post('/tv/episode/metadata/update/id', data: data);
  }

  Future<void> tvEpisodeDeleteById(dynamic id) {
    return client.delete('/tv/episode/delete/id', data: {'id': id});
  }

  /// TV Episode End
  /// TV End

  /// Library Start
  Future<List<Library>> libraryQueryAll(LibraryType type) async {
    final data = await client.get('/library/query/all', queryParameters: {'type': type.index});
    return listFromJson(data, Library.fromJson);
  }

  Future<dynamic> libraryInsert({
    required LibraryType type,
    required int driverId,
    required String id,
    required String parentId,
    required String filename,
  }) {
    return client
        .put(
          '/library/insert',
          data: {'type': type.index, 'driverId': driverId, 'id': id, 'parentId': parentId, 'filename': filename},
        )
        .then((data) => IdResponse.fromJson(data).id);
  }

  Future<void> libraryRefreshById(dynamic id, bool incremental) {
    return client.post('/library/refresh/id', data: {'id': id, 'incremental': incremental});
  }

  Future<void> libraryDeleteById(dynamic id) {
    return client.delete('/library/delete/id', data: {'id': id});
  }

  /// Library End

  /// Miscellaneous Start
  Future<List<Genre>> genreQueryAll() async {
    final data = await client.get('/genre/query/all');
    return listFromJson(data, Genre.fromJson);
  }

  Future<List<Studio>> studioQueryAll() async {
    final data = await client.get('/studio/query/all');
    return listFromJson(data, Studio.fromJson);
  }

  Future<List<Keyword>> keywordQueryAll() async {
    final data = await client.get('/keyword/query/all');
    return listFromJson(data, Keyword.fromJson);
  }

  Future<List<MediaCast>> castQueryAll() async {
    final data = await client.get('/cast/query/all');
    return listFromJson(data, MediaCast.fromJson);
  }

  Future<List<MediaCrew>> crewQueryAll() async {
    final data = await client.get('/crew/query/all');
    return listFromJson(data, MediaCrew.fromJson);
  }

  Future<void> markWatched(MediaType type, dynamic id, bool watched) {
    return client.post('/markWatched/update', data: {'id': id, 'marked': watched, 'type': type.index});
  }

  Future<void> markFavorite(MediaType type, dynamic id, bool favorite) {
    return client.post('/markFavorite/update', data: {'id': id, 'marked': favorite, 'type': type.index});
  }

  Future<void> updatePlayedStatus(
    LibraryType type,
    dynamic id, {
    required Duration position,
    required Duration duration,
    String? eventType,
    dynamic others,
  }) {
    return client.post(
      '/playedStatus/update',
      data: {
        'type': type.index,
        'eventType': eventType,
        'id': id,
        'position': position.inMilliseconds,
        'duration': duration.inMilliseconds,
        'others': others,
      },
    );
  }

  Future<void> setSkipTime(SkipTimeType type, MediaType mediaType, dynamic id, Duration time) {
    return client.post(
      '/skipTime/update',
      data: {'type': type.index, 'mediaType': mediaType.index, 'id': id, 'time': time.inMilliseconds},
    );
  }

  Stream<List<NetworkDiagnostics>> networkDiagnostics() {
    return streamWithCallback<List<NetworkDiagnostics>, List<dynamic>>(
      client.post('/network/diagnostics/cb'),
      (data) => data.map((d) => NetworkDiagnostics.fromJson(d)).toList(),
    );
  }

  Future<void> setTmdbApiKey(String key) {
    return client.post('/tmdb/apikey', data: {'apiKey': key});
  }

  /// Miscellaneous End

  /// Cast Start
  Stream<List<dynamic>> dlnaDiscover() {
    return streamWithCallback<List<dynamic>, List<dynamic>>(client.post('/dlna/discover/cb'), (data) => data);
  }

  Future<void> dlnaSetUri(String id, Uri uri, {String? title, required String playType}) {
    return client.post('/dlna/setUrl', data: {'id': id, 'uri': uri.toString(), 'title': title, 'playType': playType});
  }

  Future<void> dlnaPlay(String id) {
    return client.post('/dlna/play', data: {'id': id});
  }

  Future<void> dlnaPause(String id) {
    return client.post('/dlna/pause', data: {'id': id});
  }

  Future<void> dlnaStop(String id) {
    return client.post('/dlna/stop', data: {'id': id});
  }

  Future<void> dlnaSeek(String id, Duration seek) {
    return client.post('/dlna/seek', data: {'id': id, 'seek': seek.inSeconds});
  }

  Future<dynamic> dlnaGetPositionInfo(String id) {
    return client.post('/dlna/getPositionInfo', data: {'id': id});
  }

  Future<dynamic> dlnaGetCurrentTransportActions(String id) {
    return client.post('/dlna/getCurrentTransportActions', data: {'id': id});
  }

  Future<dynamic> dlnaGetMediaInfo(String id) {
    return client.post('/dlna/getMediaInfo', data: {'id': id});
  }

  Future<dynamic> dlnaGetTransportInfo(String id) {
    return client.post('/dlna/getTransportInfo', data: {'id': id});
  }

  Future<void> dlnaNext(String id) {
    return client.post('/dlna/next', data: {'id': id});
  }

  Future<void> dlnaPrevious(String id) {
    return client.post('/dlna/previous', data: {'id': id});
  }

  Future<void> dlnaSetPlayMode(String id, String playMode) {
    return client.post('/dlna/setPlayMode', data: {'id': id, 'mode': playMode});
  }

  Future<dynamic> dlnaGetDeviceCapabilities(String id) {
    return client.post('/dlna/getDeviceCapabilities', data: {'id': id});
  }

  Future<void> dlnaSetMute(String id, bool mute) {
    return client.post('/dlna/setMute', data: {'id': id, 'mute': mute});
  }

  Future<dynamic> dlnaGetMute(String id) {
    return client.post('/dlna/getMute', data: {'id': id});
  }

  Future<void> dlnaSetVolume(String id, double volume) {
    return client.post('/dlna/setVolume', data: {'id': id, 'volume': volume});
  }

  Future<double> dlnaGetVolume(String id) {
    return client.post<double>('/dlna/getVolume', data: {'id': id}).then((data) => data!);
  }

  ///  Cast End
}

abstract class ApiClient {
  const ApiClient();

  Future<T?> get<T>(String path, {Map<String, dynamic>? queryParameters});

  Future<T?> post<T>(String path, {Object? data});

  Future<T?> put<T>(String path, {Object? data});

  Future<T?> delete<T>(String path, {Object? data});
}
