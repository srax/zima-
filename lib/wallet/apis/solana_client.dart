import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';
import 'package:bs58/bs58.dart';

import '../models/wallet_connection.dart';
import '../models/token_account.dart';
import '../models/transaction_result.dart';
import 'solana_config.dart';

/// Core Solana client for wallet operations and blockchain interactions
class SolanaClient {
  late SolanaClient _rpcClient;
  LocalWalletAdapter? _mobileWalletAdapter;
  WalletConnection _currentConnection = const WalletConnection();

  static final SolanaClient _instance = SolanaClient._internal();
  factory SolanaClient() => _instance;
  SolanaClient._internal();

  /// Initialize the Solana client
  Future<void> initialize() async {
    _rpcClient = SolanaClient.new(
      rpcUrl: Uri.parse(SolanaConfig.currentNetworkUrl),
      websocketUrl: Uri.parse(SolanaConfig.currentNetworkUrl.replaceAll('https', 'wss')),
    );

    // Initialize Solana Mobile Stack if available
    try {
      _mobileWalletAdapter = await LocalWalletAdapter.create();
    } catch (e) {
      print('Mobile Wallet Adapter not available: $e');
    }
  }

  /// Current wallet connection status
  WalletConnection get connection => _currentConnection;

  /// Connect to a Solana wallet using Mobile Wallet Adapter
  Future<WalletConnection> connectWallet() async {
    try {
      if (_mobileWalletAdapter == null) {
        throw Exception('Mobile Wallet Adapter not available. Please install a compatible Solana wallet.');
      }

      // Request wallet connection
      final authResult = await _mobileWalletAdapter!.authorize(
        identityUri: Uri.parse('https://deepfake.petaproc.com'),
        iconUri: Uri.parse('https://deepfake.petaproc.com/icon.png'),
        identityName: 'Deepfake AI Agent',
      );

      final publicKey = base58.encode(authResult.publicKey);
      
      _currentConnection = WalletConnection(
        publicKey: publicKey,
        isConnected: true,
        walletName: authResult.walletUriBase.toString(),
        connectedAt: DateTime.now(),
      );

      return _currentConnection;
    } catch (e) {
      throw Exception('Failed to connect wallet: $e');
    }
  }

  /// Disconnect from the current wallet
  Future<void> disconnectWallet() async {
    try {
      if (_mobileWalletAdapter != null) {
        await _mobileWalletAdapter!.deauthorize();
      }
      
      _currentConnection = const WalletConnection();
    } catch (e) {
      print('Error disconnecting wallet: $e');
      // Still reset connection even if deauthorize fails
      _currentConnection = const WalletConnection();
    }
  }

  /// Get SOL balance for connected wallet
  Future<double> getSolBalance() async {
    if (!_currentConnection.isConnected || _currentConnection.publicKey == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final publicKey = Ed25519HDPublicKey.fromBase58(_currentConnection.publicKey!);
      final balance = await _rpcClient.rpcClient.getBalance(publicKey.toBase58());
      return balance.value / 1e9; // Convert lamports to SOL
    } catch (e) {
      throw Exception('Failed to get SOL balance: $e');
    }
  }

  /// Get token accounts for connected wallet
  Future<List<TokenAccount>> getTokenAccounts() async {
    if (!_currentConnection.isConnected || _currentConnection.publicKey == null) {
      throw Exception('Wallet not connected');
    }

    try {
      final publicKey = Ed25519HDPublicKey.fromBase58(_currentConnection.publicKey!);
      
      // Get token accounts by owner
      final response = await _rpcClient.rpcClient.getTokenAccountsByOwner(
        publicKey.toBase58(),
        const TokenAccountsFilter.byProgramId(SolanaConfig.tokenProgramId),
      );

      final List<TokenAccount> tokenAccounts = [];
      
      for (final account in response.value) {
        try {
          final accountData = account.account.data;
          if (accountData is ParsedAccountData) {
            final parsed = accountData.parsed as Map<String, dynamic>;
            final info = parsed['info'] as Map<String, dynamic>;
            
            final mint = info['mint'] as String;
            final tokenAmount = info['tokenAmount'] as Map<String, dynamic>;
            final balance = double.parse(tokenAmount['uiAmountString'] ?? '0');
            final decimals = tokenAmount['decimals'] as int;

            tokenAccounts.add(TokenAccount(
              mint: mint,
              address: account.pubkey,
              balance: balance,
              decimals: decimals,
              symbol: null, // Would need token metadata lookup
              name: null,   // Would need token metadata lookup
              logoUrl: null,
            ));
          }
        } catch (e) {
          print('Error parsing token account: $e');
          continue;
        }
      }

      return tokenAccounts;
    } catch (e) {
      throw Exception('Failed to get token accounts: $e');
    }
  }

  /// Send a signed transaction
  Future<TransactionResult> sendTransaction(Uint8List signedTransaction) async {
    try {
      final signature = await _rpcClient.rpcClient.sendRawTransaction(
        signedTransaction,
        preflightCommitment: Commitment.processed,
      );

      // Wait for confirmation
      await _rpcClient.rpcClient.confirmTransaction(signature);

      return TransactionResult.success(
        signature: signature,
        explorerUrl: SolanaConfig.getExplorerUrl(signature),
      );
    } catch (e) {
      return TransactionResult.failure(error: 'Transaction failed: $e');
    }
  }

  /// Get recent blockhash
  Future<String> getRecentBlockhash() async {
    try {
      final response = await _rpcClient.rpcClient.getLatestBlockhash();
      return response.value.blockhash;
    } catch (e) {
      throw Exception('Failed to get recent blockhash: $e');
    }
  }

  /// Sign a transaction using Mobile Wallet Adapter
  Future<Uint8List> signTransaction(Uint8List transaction) async {
    if (_mobileWalletAdapter == null) {
      throw Exception('Mobile Wallet Adapter not available');
    }

    if (!_currentConnection.isConnected) {
      throw Exception('Wallet not connected');
    }

    try {
      final signResult = await _mobileWalletAdapter!.signTransactions(
        transactions: [transaction],
      );

      if (signResult.signedTransactions.isEmpty) {
        throw Exception('No signed transactions returned');
      }

      return signResult.signedTransactions.first;
    } catch (e) {
      throw Exception('Failed to sign transaction: $e');
    }
  }

  /// Check if wallet is connected
  bool get isConnected => _currentConnection.isConnected;

  /// Get connected wallet's public key
  String? get publicKey => _currentConnection.publicKey;

  /// Dispose resources
  void dispose() {
    // Clean up any resources if needed
  }
}