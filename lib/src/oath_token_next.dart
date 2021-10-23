import 'package:fresh/fresh.dart';

mixin TokenProtocol {
  bool get shouldBeRefreshed;
}

class OAuth2TokenNext extends OAuth2Token with TokenProtocol {
  final DateTime? createdAt;

  OAuth2TokenNext({
    required String accessToken,
    String? tokenType = 'bearer',
    int? expiresIn,
    String? refreshToken,
    String? scope,
  })  : createdAt = DateTime.now(),
        super(
          accessToken: accessToken,
          tokenType: tokenType,
          expiresIn: expiresIn,
          refreshToken: refreshToken,
          scope: scope,
        );

  @override
  bool get shouldBeRefreshed {
    if (createdAt == null || expiresIn == null) return false;
    return createdAt!.add(Duration(seconds: expiresIn!)).isBefore(DateTime.now());
  }
}
