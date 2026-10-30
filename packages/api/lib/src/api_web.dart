import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:msgpack_dart/msgpack_dart.dart';

import '../api.dart';
import 'api_platform_interface.dart';

class ApiWeb extends ApiPlatform {
  ApiWeb();

  static void registerWith(Registrar registrar) {
    ApiPlatform.instance = ApiWeb();
  }

  @override
  late final Client client = Client(baseUrl);

  @override
  Uri baseUrl = Uri();

  @override
  Stream<T> streamWithCallback<T, D>(Future<dynamic> future, T Function(D) callback) async* {
    final resp = await future;
    if (resp != null) {
      final sessionId = IdResponse.fromJson(resp).id;
      loop:
      while (true) {
        await Future.delayed(const Duration(milliseconds: 100));
        final session = await sessionStatus<List<dynamic>>(sessionId);
        switch (session.status) {
          case SessionStatus.progressing:
            final data = deserialize(Uint8List.fromList(session.data?.cast<int>() ?? []));
            yield callback(data as D);
          case SessionStatus.finished:
            break loop;
          case SessionStatus.failed:
            throw Exception(session.data);
          default:
        }
      }
    } else {
      // ignore: avoid_dynamic_calls
      throw Exception(resp.error);
    }
  }
}

class Client extends ApiClient {
  Client(Uri baseUrl) {
    _client = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          baseUrl: baseUrl.toString(),
          responseType: ResponseType.bytes,
          validateStatus: (status) => status != null && status >= 200 && status < 300 || status == 304,
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.next(
              options
                ..headers.putIfAbsent('Content-Type', () => 'application/json')
                ..headers.putIfAbsent(
                  'Accept-Language',
                  () => Localizations.localeOf(navigatorKey.currentContext!).languageCode,
                )
                ..data =
                    (options.method != 'GET' && options.data != null)
                        ? serialize((options.data as Map<String, dynamic>).values)
                        : null
                ..queryParameters.removeWhere((_, v) => v == null),
            );
          },
          onResponse: (response, handler) {
            handler.next(response..data = (response.data as Uint8List).isNotEmpty ? deserialize(response.data!) : null);
          },
          onError: (error, handler) {
            handler.reject(switch (error.type) {
              DioExceptionType.connectionTimeout ||
              DioExceptionType.sendTimeout ||
              DioExceptionType.receiveTimeout => DioException(
                requestOptions: error.requestOptions,
                response: Response(
                  requestOptions: error.requestOptions,
                  statusCode: 40800,
                  data: '',
                  statusMessage: error.response?.statusMessage,
                ),
              ),
              DioExceptionType.badCertificate ||
              DioExceptionType.badResponse ||
              DioExceptionType.cancel ||
              DioExceptionType.connectionError ||
              DioExceptionType.unknown =>
                error
                  ..response?.data = utf8.decode(error.response?.data)
                  ..response?.statusCode =
                      (int.tryParse(error.response?.headers.value('Error-Code') ?? '') ??
                          (error.response?.statusCode ?? 0) * 100),
            });
          },
        ),
      );
  }

  late final Dio _client;

  @override
  Future<T?> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _client.get<T>(path, queryParameters: queryParameters).then((resp) => resp.data);
  }

  @override
  Future<T?> post<T>(String path, {Object? data}) {
    return _client.post<T>(path, data: data).then((resp) => resp.data);
  }

  @override
  Future<T?> put<T>(String path, {Object? data}) {
    return _client.put<T>(path, data: data).then((resp) => resp.data);
  }

  @override
  Future<T?> delete<T>(String path, {Object? data}) {
    return _client.delete<T>(path, data: data).then((resp) => resp.data);
  }
}
