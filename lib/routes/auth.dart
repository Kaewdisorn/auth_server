part of '../auth_server.dart';

class Auth {
  @Route.get('/')
  Future<Response> auth(Request request) async {
    String token = await getToken(env);

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final url = 'https://www.worksapis.com/v1.0/users/nane.kds@mogos';
    var res = await http.get(Uri.parse(url), headers: headers);
    // var request = http.Request('GET', Uri.parse(url));
    // request.headers.addAll(headers);

    // HTTP 요청 전송
    // http.StreamedResponse result = await request.send();

    // 응답 처리
    if (res.statusCode >= 200 && res.statusCode < 300) {
      print('Message sent successfully');
      return Response.ok(res.body);
    } else {
      print('Failed to send message: ${res.reasonPhrase}');
      return Response.internalServerError();
    }
  }

  @Route.all('/<ignored|.*>')
  Response _notFound(Request request) => Response.notFound('Page not found');

  Router get router => _$AuthRouter(this);
}
