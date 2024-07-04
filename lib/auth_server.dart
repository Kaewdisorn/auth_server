import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'common/jwt.dart';

//Routes
part 'routes/auth.dart';
part 'auth_server.g.dart';

// ignore: prefer_typing_uninitialized_variables
var env;

class AuthServer {
  @Route.get('/')
  Future<Response> authServer(Request request) async {
    return Response.ok("AUTH SERVER");
  }

  @Route.mount('/auth')
  Router get _auth => Auth().router;

  @Route.all('/<ignored|.*>')
  Response _notFound(Request request) => Response.notFound('Page not found');

  Handler get handler => _$AuthServerRouter(this).call;
}

void startAuthServer() async {
  final service = AuthServer();
  final host = InternetAddress.anyIPv4;
  env = DotEnv(includePlatformEnvironment: true)..load();

  Middleware handleCors() {
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
      'Access-Control-Allow-Headers': 'Origin, Content-Type',
    };

    return createMiddleware(
      requestHandler: (Request request) {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: corsHeaders);
        }
        return null;
      },
      responseHandler: (Response response) {
        return response.change(headers: corsHeaders);
      },
    );
  }

  final handler = const Pipeline()
      .addMiddleware(handleCors())
      // .addMiddleware(requestManager())
      .addMiddleware(logRequests())
      .addHandler(service.handler);

  // HTTP 서버 시작
  try {
    final httpServer = await serve(handler, host, 80);
    print('Serving HTTP at http://${httpServer.address.host}:${httpServer.port}');
  } catch (e) {
    print('HTTP Server error: $e');
  }
}
