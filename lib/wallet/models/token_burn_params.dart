/// Parameters for token burning operation
class TokenBurnParams {
  /// Amount of tokens to burn (in base units, not decimal)
  final int amount;
  
  /// Token mint address to burn from
  final String tokenMint;
  
  /// User's token account address
  final String userTokenAccount;

  const TokenBurnParams({
    required this.amount,
    required this.tokenMint,
    required this.userTokenAccount,
  });

  TokenBurnParams copyWith({
    int? amount,
    String? tokenMint,
    String? userTokenAccount,
  }) {
    return TokenBurnParams(
      amount: amount ?? this.amount,
      tokenMint: tokenMint ?? this.tokenMint,
      userTokenAccount: userTokenAccount ?? this.userTokenAccount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'tokenMint': tokenMint,
      'userTokenAccount': userTokenAccount,
    };
  }

  factory TokenBurnParams.fromJson(Map<String, dynamic> json) {
    return TokenBurnParams(
      amount: json['amount'],
      tokenMint: json['tokenMint'],
      userTokenAccount: json['userTokenAccount'],
    );
  }

  @override
  String toString() {
    return 'TokenBurnParams(amount: $amount, mint: $tokenMint)';
  }
}