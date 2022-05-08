class HttpException implements Exception {
  final String msg;

  const HttpException(this.msg);

  @override
  String toString() {
    return 'An error occurred on sending http request: $msg';
  }
}
