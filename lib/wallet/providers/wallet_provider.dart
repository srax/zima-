import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/wallet_connection.dart';
import '../models/token_account.dart';
import '../models/token_lock_params.dart';
import '../models/token_burn_params.dart';
import '../models/transaction_result.dart';
import '../apis/solana_client.dart';
import '../apis/meteora_program_api.dart';

/// Provider for managing Solana wallet state and operations
class WalletProvider extends ChangeNotifier {
  final SolanaClient _solanaClient = SolanaClient();
  late final MeteoraProgamApi _meteoraApi;
  
  // State
  WalletConnection _connection = const WalletConnection();
  List<TokenAccount> _tokenAccounts = [];
  double _solBalance = 0.0;
  bool _isLoading = false;
  String? _error;
  
  // Transaction history
  final List<TransactionResult> _transactionHistory = [];

  WalletProvider() {
    _meteoraApi = MeteoraProgamApi(_solanaClient);
    _initializeProvider();
  }

  // Getters
  WalletConnection get connection => _connection;
  List<TokenAccount> get tokenAccounts => List.unmodifiable(_tokenAccounts);
  double get solBalance => _solBalance;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TransactionResult> get transactionHistory => List.unmodifiable(_transactionHistory);
  
  bool get isConnected => _connection.isConnected;
  String? get publicKey => _connection.publicKey;

  /// Initialize the provider
  Future<void> _initializeProvider() async {
    try {
      _setLoading(true);
      await _solanaClient.initialize();
      await _loadSavedConnection();
    } catch (e) {
      _setError('Failed to initialize wallet: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load saved wallet connection from preferences
  Future<void> _loadSavedConnection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final connectionJson = prefs.getString('wallet_connection');
      
      if (connectionJson != null) {
        final connectionData = WalletConnection.fromJson(
          Map<String, dynamic>.from(
            // Note: In real implementation, you'd use proper JSON parsing
            {'publicKey': connectionJson, 'isConnected': false}
          )
        );
        
        // Don't automatically reconnect, just remember the previous connection
        _connection = connectionData.copyWith(isConnected: false);
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load saved connection: $e');
    }
  }

  /// Save wallet connection to preferences
  Future<void> _saveConnection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_connection.publicKey != null) {
        await prefs.setString('wallet_connection', _connection.publicKey!);
      } else {
        await prefs.remove('wallet_connection');
      }
    } catch (e) {
      print('Failed to save connection: $e');
    }
  }

  /// Connect to Solana wallet using Mobile Wallet Adapter
  Future<bool> connectWallet() async {
    try {
      _setLoading(true);
      _clearError();

      final connection = await _solanaClient.connectWallet();
      _connection = connection;
      
      if (connection.isConnected) {
        await _saveConnection();
        await _refreshAccountData();
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Failed to connect wallet: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Disconnect from wallet
  Future<void> disconnectWallet() async {
    try {
      _setLoading(true);
      await _solanaClient.disconnectWallet();
      _connection = const WalletConnection();
      _tokenAccounts.clear();
      _solBalance = 0.0;
      await _saveConnection();
      notifyListeners();
    } catch (e) {
      _setError('Failed to disconnect wallet: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh account data (balance and tokens)
  Future<void> refreshAccountData() async {
    if (!isConnected) return;
    
    try {
      _setLoading(true);
      await _refreshAccountData();
    } catch (e) {
      _setError('Failed to refresh account data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Internal method to refresh account data
  Future<void> _refreshAccountData() async {
    if (!isConnected) return;

    // Get SOL balance
    try {
      _solBalance = await _solanaClient.getSolBalance();
    } catch (e) {
      print('Failed to get SOL balance: $e');
    }

    // Get token accounts
    try {
      _tokenAccounts = await _solanaClient.getTokenAccounts();
    } catch (e) {
      print('Failed to get token accounts: $e');
    }

    notifyListeners();
  }

  /// Lock tokens using Jupiter Lock protocol
  Future<TransactionResult> lockTokens(TokenLockParams params) async {
    if (!isConnected) {
      final error = TransactionResult.failure(error: 'Wallet not connected');
      _addTransactionToHistory(error);
      return error;
    }

    try {
      _setLoading(true);
      _clearError();

      final result = await _meteoraApi.lockTokens(params);
      _addTransactionToHistory(result);
      
      if (result.success) {
        // Refresh account data after successful transaction
        await _refreshAccountData();
      }
      
      return result;
    } catch (e) {
      final error = TransactionResult.failure(error: 'Lock tokens failed: $e');
      _addTransactionToHistory(error);
      _setError(error.error!);
      return error;
    } finally {
      _setLoading(false);
    }
  }

  /// Burn tokens
  Future<TransactionResult> burnTokens(TokenBurnParams params) async {
    if (!isConnected) {
      final error = TransactionResult.failure(error: 'Wallet not connected');
      _addTransactionToHistory(error);
      return error;
    }

    try {
      _setLoading(true);
      _clearError();

      final result = await _meteoraApi.burnTokens(params);
      _addTransactionToHistory(result);
      
      if (result.success) {
        // Refresh account data after successful transaction
        await _refreshAccountData();
      }
      
      return result;
    } catch (e) {
      final error = TransactionResult.failure(error: 'Burn tokens failed: $e');
      _addTransactionToHistory(error);
      _setError(error.error!);
      return error;
    } finally {
      _setLoading(false);
    }
  }

  /// Get specific token account by mint
  TokenAccount? getTokenAccount(String mintAddress) {
    try {
      return _tokenAccounts.firstWhere((account) => account.mint == mintAddress);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has sufficient balance for operation
  bool hasSufficientBalance(String mintAddress, double requiredAmount) {
    final tokenAccount = getTokenAccount(mintAddress);
    if (tokenAccount == null) return false;
    return tokenAccount.balance >= requiredAmount;
  }

  /// Add transaction to history
  void _addTransactionToHistory(TransactionResult result) {
    _transactionHistory.insert(0, result); // Add to beginning
    
    // Keep only last 50 transactions
    if (_transactionHistory.length > 50) {
      _transactionHistory.removeLast();
    }
    
    notifyListeners();
  }

  /// Clear transaction history
  void clearTransactionHistory() {
    _transactionHistory.clear();
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _solanaClient.dispose();
    super.dispose();
  }
}