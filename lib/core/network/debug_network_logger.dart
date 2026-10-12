import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/dio_logs.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

final debugTalker = TalkerFlutter.init(
  settings: TalkerSettings(enabled: kDebugMode, maxHistoryItems: 300),
);

/// Keep only sanitized snapshots in Talker, never the live Dio payloads.
class DebugNetworkLogger extends Interceptor {
  DebugNetworkLogger(this.talker);

  final Talker talker;
  static const _settings = TalkerDioLoggerSettings(
    printRequestHeaders: true,
    printResponseHeaders: true,
    printResponseTime: true,
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[TalkerDioLogger.kDioLogsTimeStampKey] =
        DateTime.now().millisecondsSinceEpoch;
    final snapshot = _requestSnapshot(options);
    talker.logCustom(
      DioRequestLog(
        snapshot.uri.toString(),
        requestOptions: snapshot,
        settings: _settings,
      ),
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final snapshot = _responseSnapshot(response);
    talker.logCustom(
      DioResponseLog(
        snapshot.requestOptions.uri.toString(),
        response: snapshot,
        settings: _settings,
      ),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = _requestSnapshot(err.requestOptions);
    talker.logCustom(
      DioErrorLog(
        request.uri.toString(),
        dioException: DioException(
          requestOptions: request,
          response: err.response == null
              ? null
              : _responseSnapshot(err.response!),
          type: err.type,
          // Arbitrary exception messages may contain unsanitized URLs/payloads.
          message: err.type.name,
        ),
        settings: _settings,
      ),
    );
    handler.next(err);
  }

  RequestOptions _requestSnapshot(RequestOptions options) => options.copyWith(
    path: Uri.parse(options.path).replace(query: '').toString(),
    queryParameters: Map<String, dynamic>.from(
      _redact(options.uri.queryParametersAll) as Map,
    ),
    data: _bodySnapshot(options.data),
    headers: Map<String, dynamic>.from(_redact(options.headers) as Map),
    extra: {
      TalkerDioLogger.kDioLogsTimeStampKey:
          options.extra[TalkerDioLogger.kDioLogsTimeStampKey],
    },
  );

  Response<dynamic> _responseSnapshot(Response<dynamic> response) => Response(
    requestOptions: _requestSnapshot(response.requestOptions),
    data: _bodySnapshot(response.data),
    statusCode: response.statusCode,
    statusMessage: response.statusMessage,
    headers: Headers.fromMap(
      Map<String, List<String>>.from(_redact(response.headers.map) as Map),
    ),
  );

  dynamic _redact(dynamic value) {
    if (value is Map) {
      return value.map((key, item) {
        final name = key.toString().toLowerCase().replaceAll(
          RegExp(r'[^a-z]'),
          '',
        );
        final sensitive =
            name.contains('password') ||
            name.contains('token') ||
            name.contains('secret') ||
            name.contains('cookie') ||
            name == 'authorization' ||
            name == 'apikey';
        return MapEntry(
          key.toString(),
          sensitive
              ? (item is List<String> ? <String>['[REDACTED]'] : '[REDACTED]')
              : _redact(item),
        );
      });
    }
    if (value is List<String>) return List<String>.from(value);
    if (value is List) return value.map(_redact).toList();
    if (value is String) return value;
    if (value is FormData) {
      return _redact(Map.fromEntries(value.fields));
    }
    if (value == null || value is num || value is bool) return value;
    return '[${value.runtimeType} body omitted]';
  }

  dynamic _bodySnapshot(dynamic value) {
    if (value is String) {
      try {
        return _redact(jsonDecode(value));
      } on FormatException {
        // Opaque text cannot be safely inspected for structured secrets.
        return '[Text body omitted]';
      }
    }
    return _redact(value);
  }
}
