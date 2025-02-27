class RetryOnErrorConstants {
  const RetryOnErrorConstants._();

  static const int maxRetries = 3;
  static const Duration retryInterval = Duration(seconds: 3);
}
