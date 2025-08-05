import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/token_burn_params.dart';
import '../../providers/wallet_provider.dart';
import '../../apis/solana_config.dart';

class TokenBurnForm extends StatefulWidget {
  const TokenBurnForm({super.key});

  @override
  State<TokenBurnForm> createState() => _TokenBurnFormState();
}

class _TokenBurnFormState extends State<TokenBurnForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _mintController = TextEditingController();
  final _accountController = TextEditingController();

  bool _isProcessing = false;
  String? _selectedTokenMint;

  @override
  void initState() {
    super.initState();
    // Pre-fill with test mint address for convenience
    _mintController.text = SolanaConfig.testMintAddress;
    _selectedTokenMint = SolanaConfig.testMintAddress;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _mintController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Token Selection
              _buildTokenSelection(walletProvider),
              const SizedBox(height: 20),

              // Amount Input
              _buildAmountInput(walletProvider),
              const SizedBox(height: 20),

              // Token Account Input
              _buildTokenAccountInput(),
              const SizedBox(height: 24),

              // Warning Card
              _buildWarningCard(),
              const SizedBox(height: 24),

              // Burn Button
              _buildBurnButton(walletProvider),

              // Error Display
              if (walletProvider.error != null) ...[
                const SizedBox(height: 16),
                _buildErrorCard(walletProvider.error!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTokenSelection(WalletProvider walletProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Token',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        
        if (walletProvider.tokenAccounts.isNotEmpty)
          DropdownButtonFormField<String>(
            value: _selectedTokenMint,
            decoration: const InputDecoration(
              labelText: 'Token',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.token),
            ),
            items: [
              // Test token
              DropdownMenuItem(
                value: SolanaConfig.testMintAddress,
                child: Text('Test Token (${SolanaConfig.testMintAddress.substring(0, 8)}...)'),
              ),
              // User's tokens
              ...walletProvider.tokenAccounts.map((token) {
                return DropdownMenuItem(
                  value: token.mint,
                  child: Text(
                    '${token.symbol ?? 'Unknown'} (${token.mint.substring(0, 8)}...)',
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTokenMint = value;
                _mintController.text = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a token';
              }
              return null;
            },
          )
        else
          TextFormField(
            controller: _mintController,
            decoration: const InputDecoration(
              labelText: 'Token Mint Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.token),
              hintText: 'Enter token mint address...',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter token mint address';
              }
              if (value.length < 32) {
                return 'Invalid mint address';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _selectedTokenMint = value;
              });
            },
          ),
      ],
    );
  }

  Widget _buildAmountInput(WalletProvider walletProvider) {
    final selectedToken = walletProvider.getTokenAccount(_selectedTokenMint ?? '');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Amount to Burn',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (selectedToken != null) ...[
              const Spacer(),
              Text(
                'Balance: ${selectedToken.balance.toStringAsFixed(4)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: 'Amount',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.local_fire_department),
            suffixText: selectedToken?.symbol,
            suffixIcon: selectedToken != null
                ? TextButton(
                    onPressed: () {
                      _amountController.text = selectedToken.balance.toString();
                    },
                    child: const Text('MAX'),
                  )
                : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter amount to burn';
            }
            
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            
            if (selectedToken != null && amount > selectedToken.balance) {
              return 'Insufficient balance';
            }
            
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTokenAccountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Token Account Address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _accountController,
          decoration: const InputDecoration(
            labelText: 'Your Token Account',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance_wallet),
            hintText: 'Enter your token account address...',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter token account address';
            }
            if (value.length < 32) {
              return 'Invalid account address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warning: Irreversible Action',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Burning tokens permanently destroys them. This action cannot be undone.',
                  style: TextStyle(color: Colors.orange.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBurnButton(WalletProvider walletProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (_isProcessing || walletProvider.isLoading)
            ? null
            : () => _performBurn(walletProvider),
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.local_fire_department),
        label: Text(_isProcessing ? 'Burning...' : 'Burn Tokens'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performBurn(WalletProvider walletProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final burnParams = TokenBurnParams(
        amount: (amount * 1e9).toInt(), // Convert to base units (assuming 9 decimals)
        tokenMint: _mintController.text.trim(),
        userTokenAccount: _accountController.text.trim(),
      );

      final result = await walletProvider.burnTokens(burnParams);

      if (result.success) {
        _showSuccessDialog(result);
        _resetForm();
      } else {
        _showErrorDialog(result.error ?? 'Unknown error occurred');
      }
    } catch (e) {
      _showErrorDialog('Failed to burn tokens: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _resetForm() {
    _amountController.clear();
    _accountController.clear();
    _formKey.currentState?.reset();
  }

  void _showSuccessDialog(result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Burn Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tokens have been successfully burned!'),
            const SizedBox(height: 16),
            if (result.signature != null) ...[
              const Text('Transaction Signature:'),
              SelectableText(
                result.signature!,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (result.explorerUrl != null)
            TextButton(
              onPressed: () {
                // Open explorer URL
                Navigator.of(context).pop();
              },
              child: const Text('View on Explorer'),
            ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Burn Failed'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}