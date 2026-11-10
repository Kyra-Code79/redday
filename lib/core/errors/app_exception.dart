/// Application specific exceptions with user-friendly error messages.
class AppException implements Exception {
  AppException(this.message, [this.details]);

  final String message;
  final dynamic details;

  @override
  String toString() => details != null ? '$message ($details)' : message;
}

class ValidationException extends AppException {
  ValidationException(super.message, [super.details]);
}

class DatabaseException extends AppException {
  DatabaseException(super.message, [super.details]);
}

class ImportExportException extends AppException {
  ImportExportException(super.message, [super.details]);
}
