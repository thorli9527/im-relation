import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';

/// Logs request/response pairs for every gRPC client call.
class GrpcLoggingInterceptor extends ClientInterceptor {
  GrpcLoggingInterceptor(this._logger);

  final Logger _logger;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final stopwatch = Stopwatch()..start();
    final metadata = options.metadata;
    final requestText = _stringify(request);
    _logger.i(
      '[gRPC] -> ${method.path} | metadata: $metadata | request: $requestText',
    );

    final future = invoker(method, request, options);
    future.then(
      (response) {
        stopwatch.stop();
        _logger.i(
          '[gRPC] <- ${method.path} | ${stopwatch.elapsedMilliseconds}ms | response: ${_stringify(response)}',
        );
        return response;
      },
      onError: (Object error, StackTrace stackTrace) {
        stopwatch.stop();
        _logger.e(
          '[gRPC] !! ${method.path} | ${stopwatch.elapsedMilliseconds}ms | error: $error | request: $requestText',
          error: error,
          stackTrace: stackTrace,
        );
        return Future<R>.error(error, stackTrace);
      },
    );
    return future;
  }

  String _stringify(Object? value) {
    if (value == null) {
      return 'null';
    }
    try {
      return value.toString();
    } catch (error) {
      return '<<unprintable: $error>>';
    }
  }
}
