/// Solana network and program configuration
class SolanaConfig {
  // Network URLs
  static const String devnetUrl = 'https://api.devnet.solana.com';
  static const String mainnetUrl = 'https://api.mainnet-beta.solana.com';
  static const String localnetUrl = 'http://localhost:8899';

  // Program IDs
  static const String meteoraTokenLockBurnProgramId = '5VDexKtW25RjF4eVRPQRopkYQAyqmKU3M4EGK9D34VLB';
  static const String jupiterLockProgramId = 'LocpQgucEQHbqNABEYvBvwoxCPsSbG91A1QaQhQQqjn';
  static const String tokenProgramId = 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';
  static const String associatedTokenProgramId = 'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL';
  static const String systemProgramId = '11111111111111111111111111111112';

  // Seeds for PDA derivation
  static const String poolSeed = 'Pool';
  static const String escrowSeed = 'escrow';
  static const String eventAuthoritySeed = '__event_authority';

  // Default parameters
  static const int defaultCommitment = 0; // 'processed'
  static const int defaultTimeout = 30000; // 30 seconds

  // Test mint address (from provided test)
  static const String testMintAddress = 'BjS1JWtk6gTkocC2oQdcaqwFduRn44fLVJiWsGeVP9f4';

  // Current network environment
  static bool get isDevelopment => const bool.fromEnvironment('dart.vm.product') == false;
  
  static String get currentNetworkUrl {
    return isDevelopment ? devnetUrl : mainnetUrl;
  }

  static String get explorerBaseUrl {
    return isDevelopment 
        ? 'https://solscan.io/tx/{signature}?cluster=devnet'
        : 'https://solscan.io/tx/{signature}';
  }

  static String getExplorerUrl(String signature) {
    return explorerBaseUrl.replaceAll('{signature}', signature);
  }
}