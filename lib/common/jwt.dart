import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

getJWT(final env) {
  final jwt = _makeRS256(env);
  print(jwt);
}

String _makeRS256(final env) {
  String token;
  var unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  /* Sign */ {
    // Create a json web token
    final jwt = JWT({
      "iss": env["clientID"],
      "sub": env["clientSecret"],
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
