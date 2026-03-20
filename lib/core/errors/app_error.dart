class AppError {
  final String code;
  final String userMessage;
  final String technicalMessage;

  AppError({
    required this.code,
    required this.userMessage,
    required this.technicalMessage,
  });

  @override
  String toString() => 'AppError($code): $technicalMessage';
}
