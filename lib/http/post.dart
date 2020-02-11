import 'dart:async';
import 'package:dio/dio.dart';

import 'url.dart' as url;

Future<dynamic> fetchPost(data) async {
  final Dio dio = Dio(BaseOptions(
    baseUrl: url.url,
//    connectTimeout: 5000,
//    receiveTimeout: 100000,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
  ));
  final response = await dio.post('/api/v2/users/', data: data);
  print(response.statusCode == 200);
  print(response.statusCode);
  print(response.data);
  print(response.data['success']);
  if (response.statusCode == 200) {
    return response.data;
  }
}
