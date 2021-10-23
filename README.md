## Fresh Dio Next

A token refresh library for dart. This package extends `fresh_dio` by checking a token before sending a request.

This package should be compatible with you code, that already uses `fresh_dio`. In the most case you have to
change `Fresh.oAuth2(...)` to `FreshNext.oAuth2(...)` and mix your `OAuth2Token` with `TokenProtocol` or use
a `OAuth2TokenNext` class.

By default `fresh_dio` will always send a request, if a response code is 403, then `dio` tries to refresh a token and
resends a same request with new token. This packages tries first to validate the token, if token is invalid, then a new
token will be requested. Only after that `fresh_dio` send a request to server.

This implementation solve the case, when the user sends a request with `MultipartFile` with invalid token. Because
the `MultipartFile` can be read only one time, by second sending the error will be thrown and user
receives `Can't finalize a finalized MultipartFile` message. Sending a request with invalid token costs internet
bandwidth, so it's nice if we can avoid first request with invalid token.

Link with same issue:

- [Dio #482](https://github.com/flutterchina/dio/issues/482)
- [Fresh #52](https://github.com/felangel/fresh/issues/52)