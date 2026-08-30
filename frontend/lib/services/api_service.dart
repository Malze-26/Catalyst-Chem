import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:5000/api'
        : 'http://localhost:5000/api';
  }

  late final Dio dio;

  ApiService({String? customBaseUrl}) {
    dio = Dio(BaseOptions(
      baseUrl: customBaseUrl ?? baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  // Auth endpoints
  Future<Response> register(String name, String email, String password, String targetBoard) {
    return dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'target_board': targetBoard,
    });
  }

  Future<Response> login(String email, String password) {
    return dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  // Topic endpoints
  Future<Response> getTopics({String? board, String? level}) {
    return dio.get('/topics', queryParameters: {
      if (board != null) 'board': board,
      if (level != null) 'level': level,
    });
  }

  // Quiz endpoints
  Future<Response> getQuizQuestions(String topicId) {
    return dio.get('/quizzes/$topicId');
  }

  Future<Response> submitQuizScore(String topicId, double score) {
    return dio.post('/quizzes/submit', data: {
      'topic_id': topicId,
      'score': score,
    });
  }

  // Past Papers
  Future<Response> getPastPapers({String? board, int? year}) {
    return dio.get('/past-papers', queryParameters: {
      if (board != null) 'board': board,
      if (year != null) 'year': year,
    });
  }

  // Progress
  Future<Response> getProgress() {
    return dio.get('/progress');
  }
}
