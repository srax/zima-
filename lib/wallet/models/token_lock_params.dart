/// Parameters for token locking via Jupiter Lock protocol
class TokenLockParams {
  /// Duration before tokens can start being unlocked (in seconds)
  final int cliffTime;
  
  /// How often tokens are released after cliff period (in seconds)
  final int frequency;
  
  /// Amount to unlock immediately after cliff period
  final int cliffUnlockAmount;
  
  /// Amount to unlock per period after cliff
  final int amountPerPeriod;
  
  /// Total number of unlock periods
  final int numberOfPeriods;
  
  /// Token mint address to lock
  final String tokenMint;
  
  /// Recipient wallet address for locked tokens
  final String recipient;

  const TokenLockParams({
    required this.cliffTime,
    required this.frequency,
    required this.cliffUnlockAmount,
    required this.amountPerPeriod,
    required this.numberOfPeriods,
    required this.tokenMint,
    required this.recipient,
  });

  TokenLockParams copyWith({
    int? cliffTime,
    int? frequency,
    int? cliffUnlockAmount,
    int? amountPerPeriod,
    int? numberOfPeriods,
    String? tokenMint,
    String? recipient,
  }) {
    return TokenLockParams(
      cliffTime: cliffTime ?? this.cliffTime,
      frequency: frequency ?? this.frequency,
      cliffUnlockAmount: cliffUnlockAmount ?? this.cliffUnlockAmount,
      amountPerPeriod: amountPerPeriod ?? this.amountPerPeriod,
      numberOfPeriods: numberOfPeriods ?? this.numberOfPeriods,
      tokenMint: tokenMint ?? this.tokenMint,
      recipient: recipient ?? this.recipient,
    );
  }

  /// Total amount to be locked (cliff + all periods)
  int get totalLockAmount => cliffUnlockAmount + (amountPerPeriod * numberOfPeriods);

  /// Total lock duration in seconds
  int get totalDuration => cliffTime + (frequency * numberOfPeriods);

  Map<String, dynamic> toJson() {
    return {
      'cliffTime': cliffTime,
      'frequency': frequency,
      'cliffUnlockAmount': cliffUnlockAmount,
      'amountPerPeriod': amountPerPeriod,
      'numberOfPeriods': numberOfPeriods,
      'tokenMint': tokenMint,
      'recipient': recipient,
    };
  }

  factory TokenLockParams.fromJson(Map<String, dynamic> json) {
    return TokenLockParams(
      cliffTime: json['cliffTime'],
      frequency: json['frequency'],
      cliffUnlockAmount: json['cliffUnlockAmount'],
      amountPerPeriod: json['amountPerPeriod'],
      numberOfPeriods: json['numberOfPeriods'],
      tokenMint: json['tokenMint'],
      recipient: json['recipient'],
    );
  }

  @override
  String toString() {
    return 'TokenLockParams(totalAmount: $totalLockAmount, cliff: ${cliffTime}s, frequency: ${frequency}s, periods: $numberOfPeriods)';
  }
}