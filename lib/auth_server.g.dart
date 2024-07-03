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
  router.all(
    r'/<ignored|.*>',
    service._notFound,
  );
  return router;
}
