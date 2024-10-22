import 'dart:io';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import "package:ua_client_hints/ua_client_hints.dart";

int kConnectTimeout = 15000;

class NetworkClient {
  late Dio _dio;

  Future<void> init(PackageInfo packageInfo) async {
    final String ua = await userAgent();
    _dio = Dio(
      BaseOptions(
        connectTimeout: kConnectTimeout,
        headers: {
          HttpHeaders.userAgentHeader: ua,
          'X-Client-Version': packageInfo.version,
          'X-Client-Package': packageInfo.packageName,
        },
      ),
    );
  }

  NetworkClient._privateConstructor();

  static NetworkClient instance = NetworkClient._privateConstructor();

  Dio getDio() => _dio;
}
