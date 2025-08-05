class TokenAccount {
  final String mint;
  final String address;
  final double balance;
  final int decimals;
  final String? symbol;
  final String? name;
  final String? logoUrl;

  const TokenAccount({
    required this.mint,
    required this.address,
    required this.balance,
    required this.decimals,
    this.symbol,
    this.name,
    this.logoUrl,
  });

  TokenAccount copyWith({
    String? mint,
    String? address,
    double? balance,
    int? decimals,
    String? symbol,
    String? name,
    String? logoUrl,
  }) {
    return TokenAccount(
      mint: mint ?? this.mint,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      decimals: decimals ?? this.decimals,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mint': mint,
      'address': address,
      'balance': balance,
      'decimals': decimals,
      'symbol': symbol,
      'name': name,
      'logoUrl': logoUrl,
    };
  }

  factory TokenAccount.fromJson(Map<String, dynamic> json) {
    return TokenAccount(
      mint: json['mint'],
      address: json['address'],
      balance: (json['balance'] as num).toDouble(),
      decimals: json['decimals'],
      symbol: json['symbol'],
      name: json['name'],
      logoUrl: json['logoUrl'],
    );
  }

  String get displayBalance {
    return (balance / (1e9)).toStringAsFixed(2); // Assuming 9 decimals for SOL
  }

  @override
  String toString() {
    return 'TokenAccount(mint: $mint, address: $address, balance: $balance, symbol: $symbol)';
  }
}