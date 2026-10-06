import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Inject token if available
    // String? token = getTokenFromLocalStorage();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }
}
