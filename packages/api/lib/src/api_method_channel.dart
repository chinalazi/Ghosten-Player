import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msgpack_dart/msgpack_dart.dart';

import 'api_platform_interface.dart';
import 'models.dart';

const _pluginNamespace = 'com.ghosten.player/api';

class MethodChannelApi extends ApiPlatform {
  final _methodChannel = const MethodChannel(_pluginNamespace);

  @override
  late final ApiClient client = Client(_methodChannel);

  @override
  Uri baseUrl = Uri(scheme: 'http', host: '127.0.0.1');

  @override
  Future<String?> databasePath() => _methodChannel.invokeMethod<String>('databasePath');

  @override
  Future<bool?> initialized() async {
    final port = await _methodChannel.invokeMethod<int>('initialized');
    if (port != null) {
      baseUrl = baseUrl.replace(port: port);
      return true;
    }
    return false;
  }

  /// Session Start

  @override
  Future<SessionCreate> sessionCreate() async {
    final data = await super.sessionCreate();
    final ip = await _methodChannel.invokeMethod<String>('getLocalIpAddress');
    return SessionCreate(id: data.id, uri: data.uri.replace(host: ip));
  }

  /// Session End

  /// Miscellaneous Start

  @override
  Stream<T> streamWithCallback<T, D>(Future<dynamic> future, T Function(D) callback) async* {
    final data = await future;
    final eventChannel = EventChannel('$_pluginNamespace/update/$data');
    yield* eventChannel.receiveBroadcastStream().map((event) => callback(deserialize(event) as D));
  }

  /// Miscellaneous End
}

class Client extends ApiClient {
  const Client(this._methodChannel);

  final MethodChannel _methodChannel;

  @override
  Future<T?> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _send<T>('GET', path, queryParameters);
  }

  @override
  Future<T?> post<T>(String path, {Object? data}) {
    return _send<T>('POST', path, data as Map<String, dynamic>?);
  }

  @override
  Future<T?> put<T>(String path, {Object? data}) {
    return _send<T>('PUT', path, data as Map<String, dynamic>?);
  }

  @override
  Future<T?> delete<T>(String path, {Object? data}) {
    return _send<T>('DELETE', path, data as Map<String, dynamic>?);
  }

  Future<T?> _send<T>(String method, String path, [Map<String, dynamic>? data]) {
    return _methodChannel
        .invokeMethod<Uint8List>(path, {
          'data': serialize(data?.values),
          'params': serialize([
            if (navigatorKey.currentState?.context != null)
              Localizations.localeOf(navigatorKey.currentState!.context).languageCode
            else
              null,
          ]),
        })
        .timeout(const Duration(seconds: 30))
        .then((value) {
          if (value?.isNotEmpty ?? false) {
            return deserialize(value!) as T;
          } else {
            return null;
          }
        })
        .catchError(
          (error) {
            throw PlatformException(code: '40800', message: (error as TimeoutException).message);
          },
          test: (error) {
            return error is TimeoutException;
          },
        );
  }
}
