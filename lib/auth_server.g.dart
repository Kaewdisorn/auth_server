// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_server.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$AuthServerRouter(AuthServer service) {
  final router = Router();
  router.add(
    'GET',
    r'/',
    service.scmApiServer,
  );
  router.mount(
    r'/auth',
    service._auth.call,
  );
  router.all(
    r'/<ignored|.*>',
    service._notFound,
  );
  return router;
}

Router _$AuthRouter(Auth service) {
  final router = Router();
  router.add(
    'GET',
    r'/',
    service.auth,
  );
  router.all(
    r'/<ignored|.*>',
    service._notFound,
  );
  return router;
}
