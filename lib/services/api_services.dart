import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

class ApiService {
  final Dio dio;

  ApiService._internal(this.dio) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.path == '/local-businesses') {
          try {
            final raw = await rootBundle.loadString('assets/data/businesses.json');

            await Future.delayed(const Duration(milliseconds: 300));

            final data = jsonDecode(raw);
            final response = Response(
              requestOptions: options,
              data: data,
              statusCode: 200,
            );
            return handler.resolve(response);
          } catch (e) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: e,
                type: DioExceptionType.unknown,
              ),
            );
          }
        }
        return handler.next(options);
      },
    ));
  }

  factory ApiService() {
    final dio = Dio();
    return ApiService._internal(dio);
  }

  Future<List<dynamic>> fetchRawBusinesses() async {
    final response = await dio.get('/local-businesses');
    if (response.statusCode == 200) {
      return (response.data as List<dynamic>);
    } else {
      throw Exception('Failed to fetch');
    }
  }
}
