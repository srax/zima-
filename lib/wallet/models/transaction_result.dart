/// Result of a blockchain transaction
class TransactionResult {
  final bool success;
  final String? signature;
  final String? error;
  final DateTime timestamp;
  final String? explorerUrl;

  const TransactionResult({
    required this.success,
    this.signature,
    this.error,
    required this.timestamp,
    this.explorerUrl,
  });

  TransactionResult.success({
    required String signature,
    String? explorerUrl,
  }) : this(
    success: true,
    signature: signature,
    timestamp: DateTime.now(),
    explorerUrl: explorerUrl,
  );

  TransactionResult.failure({
    required String error,
  }) : this(
    success: false,
    error: error,
    timestamp: DateTime.now(),
  );

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'signature': signature,
      'error': error,
      'timestamp': timestamp.toIso8601String(),
      'explorerUrl': explorerUrl,
    };
  }

  factory TransactionResult.fromJson(Map<String, dynamic> json) {
    return TransactionResult(
      success: json['success'],
      signature: json['signature'],
      error: json['error'],
      timestamp: DateTime.parse(json['timestamp']),
      explorerUrl: json['explorerUrl'],
    );
  }

  @override
  String toString() {
    if (success) {
      return 'TransactionResult.success(signature: $signature)';
    } else {
      return 'TransactionResult.failure(error: $error)';
    }
  }
}