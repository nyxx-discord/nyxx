part of nyxx_lavalink;

class HttpException implements Exception {
  int code;

  // ignore: public_member_api_docs
  HttpException(this.code): super();
}