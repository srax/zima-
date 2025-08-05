class WalletConnection {
  final String? publicKey;
  final bool isConnected;
  final String? walletName;
  final DateTime? connectedAt;

  const WalletConnection({
    this.publicKey,
    this.isConnected = false,
    this.walletName,
    this.connectedAt,
  });

  WalletConnection copyWith({
    String? publicKey,
    bool? isConnected,
    String? walletName,
    DateTime? connectedAt,
  }) {
    return WalletConnection(
      publicKey: publicKey ?? this.publicKey,
      isConnected: isConnected ?? this.isConnected,
      walletName: walletName ?? this.walletName,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'isConnected': isConnected,
      'walletName': walletName,
      'connectedAt': connectedAt?.toIso8601String(),
    };
  }

  factory WalletConnection.fromJson(Map<String, dynamic> json) {
    return WalletConnection(
      publicKey: json['publicKey'],
      isConnected: json['isConnected'] ?? false,
      walletName: json['walletName'],
      connectedAt: json['connectedAt'] != null 
          ? DateTime.parse(json['connectedAt']) 
          : null,
    );
  }

  @override
  String toString() {
    return 'WalletConnection(publicKey: $publicKey, isConnected: $isConnected, walletName: $walletName)';
  }
}