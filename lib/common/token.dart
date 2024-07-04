import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;

final Map<String, dynamic> cache = {};

Future<String> getToken(final env) async {
  DateTime now = DateTime.now();
  DateTime? refreshTokenIssuedTime = cache['refreshTokenIssuedTime'];
  DateTime? accessTokenIssuedTime = cache['accessTokenIssuedTime'];

  // refreshToken이 90일 이내에 발급되었는지 확인
  bool isRefreshTokenValid = refreshTokenIssuedTime != null && now.difference(refreshTokenIssuedTime).inDays < 90;

  // accessToken이 24시간 이내에 발급되었는지 확인
  bool isAccessTokenValid = accessTokenIssuedTime != null && now.difference(accessTokenIssuedTime).inHours < 24;

  if (isRefreshTokenValid && isAccessTokenValid) {
    // 둘 다 유효한 경우, 기존 accessToken 반환
    print("REUSE TOKEN!!");
    return cache['accessToken'];
  }

  // 새로운 토큰을 발급받아야 하는 경우
  print("NEW TOKEN!!");
  final String clientID = env["clientID"];
  final String serviceAccount = env["serviceAccount"];
  final String clientSecret = env["clientSecret"];
  final jwt = _makeRS256(clientID, serviceAccount);

  Map<String, String> makeBody = {
    'jwt': jwt,
    'clientID': clientID,
    'clientSecret': clientSecret,
  };

  var rfToken = await _getRFToken(makeBody);
  if (rfToken['code'] == '200') {
    String refreshToken = rfToken['data']['refresh_token']; // 90일
    String accessToken = rfToken['data']['access_token']; // 24시간

    // 토큰 정보와 발급 시간을 Map에 저장
    cache['refreshToken'] = refreshToken;
    cache['accessToken'] = accessToken;
    cache['refreshTokenIssuedTime'] = now;
    cache['accessTokenIssuedTime'] = now;

    return accessToken;
  } else {
    throw Exception('invalid RefreshToken request');
  }
}

String _makeRS256(final String clientID, final String serviceAccount) {
  String token;
  var unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  /* Sign */ {
    // Create a json web token
    final jwt = JWT({
      "iss": clientID,
      "sub": serviceAccount,
      "iat": unixTimestamp,
      "exp": unixTimestamp + 3600,
    }, header: {
      "alg": "RS256",
      "typ": "JWT"
    });

    final serviceAccountKeyFilePath = 'lib/secrets/works/naverworks.key';
    final serviceAccountKeyFileLocalPath = 'lib/secrets/bot/private_20231006153144.key';

    final pem = _openVolume(serviceAccountKeyFilePath, serviceAccountKeyFileLocalPath);
    if (pem != null) {
      final key = RSAPrivateKey(pem);
      token = jwt.sign(key, algorithm: JWTAlgorithm.RS256);
      return token;
    }
    return '';
  }
}

Future<Map> _getRFToken(body) async {
  var headers = {'content-Type': 'application/x-www-form-urlencoded; charset=UTF-8', 'Cookie': 'LC=en_US; WORKS_RE_LOC=jp1; WORKS_TE_LOC=jp1; language=en_US'};
  var request = http.Request('POST', Uri.parse('https://auth.worksmobile.com/oauth2/v2.0/token'));

  request.bodyFields = {
    'assertion': body['jwt'],
    'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
    'client_id': body['clientID'],
    'client_secret': body['clientSecret'],
    'scope': 'user.read',
  };

  request.headers.addAll(headers);

  http.StreamedResponse result = await request.send();
  http.Response response = await http.Response.fromStream(result);

  var responseBody = utf8.decode(response.bodyBytes);

  Map<String, dynamic> resData = {'code': '500', 'data': ''};

  if (response.statusCode == 200) {
    // print(await response.stream.bytesToString());
    resData['code'] = '200';
    resData['data'] = jsonDecode(responseBody);
  } else {
    // print(response.reasonPhrase);
    resData['code'] = response.statusCode.toString();
    resData['data'] = '';
  }

  return resData;
}

String? _openVolume(String nameIn, String nameOther) {
  // Sign it
  try {
    final pem = File(nameIn).readAsStringSync();
    print('open volumes:: $nameIn');
    return pem;
  } catch (e) {
    try {
      final pem = File(nameOther).readAsStringSync();
      print('open local file:: $nameIn');
      return pem;
    } catch (e) {
      print('openVolume Error :: ${e.toString()}');
    }
  }

  return null;
}
