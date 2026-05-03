class AppResult<T> {
  final T? _data;
  final String? _message;
  final bool isSuccess;

  AppResult._success(T data)
      : _data = data,
        _message = null,
        isSuccess = true;

  AppResult._failure(String message)
      : _data = null,
        _message = message,
        isSuccess = false;

  factory AppResult.success(T data) => AppResult._success(data);
  factory AppResult.failure(String message) => AppResult._failure(message);

  bool get isFailure => !isSuccess;
  T get data => _data as T;
  String get errorMessage => _message!;
}
