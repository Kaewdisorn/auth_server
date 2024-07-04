part of '../auth_server.dart';

class Auth {
  @Route.get('/')
  Future<Response> auth(Request request) async {
    getJWT(env);
    return Response.ok("AUTH ROUTE");
  }

  @Route.all('/<ignored|.*>')
  Response _notFound(Request request) => Response.notFound('Page not found');

  Router get router => _$AuthRouter(this);
}
