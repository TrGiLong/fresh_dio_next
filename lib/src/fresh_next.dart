import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';

import 'oath_token_next.dart';

typedef ShouldRefreshBeforeRequest<T extends TokenProtocol> = bool Function(T? token);

class FreshNext<T extends TokenProtocol> extends Fresh<T> {
  FreshNext({
    required TokenHeaderBuilder<T> tokenHeader,
    required TokenStorage<T> tokenStorage,
    required RefreshToken<T> refreshToken,
    ShouldRefresh? shouldRefresh,
    ShouldRefreshBeforeRequest<T>? shouldRefreshBeforeRequest,
    Dio? httpClient,
  })  : _shouldRefreshBeforeRequest = shouldRefreshBeforeRequest ?? _defaultShouldRefreshBeforeRequest,
        _refreshToken = refreshToken,
        _tokenHeader = tokenHeader,
        _httpClient = httpClient ?? Dio(),
        // Pass httpClient if you want to have same instance.
        super(
          tokenHeader: tokenHeader,
          tokenStorage: tokenStorage,
          refreshToken: refreshToken,
          shouldRefresh: shouldRefresh,
          httpClient: httpClient,
        );

  final ShouldRefreshBeforeRequest<T> _shouldRefreshBeforeRequest;
  final RefreshToken<T> _refreshToken;
  final TokenHeaderBuilder<T> _tokenHeader;
  final Dio _httpClient;

  static FreshNext<OAuth2TokenNext> oAuth2({
    required TokenStorage<OAuth2TokenNext> tokenStorage,
    required RefreshToken<OAuth2TokenNext> refreshToken,
    ShouldRefresh? shouldRefresh,
    TokenHeaderBuilder<OAuth2TokenNext>? tokenHeader,
  }) {
    return FreshNext<OAuth2TokenNext>(
        refreshToken: refreshToken,
        tokenStorage: tokenStorage,
        shouldRefresh: shouldRefresh,
        tokenHeader: tokenHeader ??
            (token) {
              return {
                'authorization': '${token.tokenType} ${token.accessToken}',
              };
            });
  }

  @override
  Future<dynamic> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var currentToken = await token;

    // Check token before sending a request.
    if (_shouldRefreshBeforeRequest(currentToken)) {
      try {
        final refreshedToken = await _refreshToken(currentToken, _httpClient);
        await setToken(refreshedToken);
      } on RevokeTokenException catch (error) {
        await clearToken();
        throw DioError(
          requestOptions: options,
          error: error,
        );
      }
    }

    super.onRequest(options, handler);
  }

  static bool _defaultShouldRefreshBeforeRequest(TokenProtocol? token) {
    if (token == null) return false;
    return token.shouldBeRefreshed;
  }
}
