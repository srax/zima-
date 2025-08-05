import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/token_lock_params.dart';
import '../../providers/wallet_provider.dart';
import '../../apis/solana_config.dart';

class TokenLockForm extends StatefulWidget {
  const TokenLockForm({super.key});

  @override
  State<TokenLockForm> createState() => _TokenLockFormState();
}

class _TokenLockFormState extends State<TokenLockForm> {
  final _formKey = GlobalKey<FormState>();
  final _mintController = TextEditingController();
  final _recipientController = TextEditingController();
  final _cliffTimeController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _cliffAmountController = TextEditingController();
  final _periodAmountController = TextEditingController();
  final _periodsController = TextEditingController();

  bool _isProcessing = false;
  String? _selectedTokenMint;

  @override
  void initState() {
    super.initState();
    // Pre-fill with default values for convenience
    _mintController.text = SolanaConfig.testMintAddress;
    _selectedTokenMint = SolanaConfig.testMintAddress;
    _cliffTimeController.text = '100'; // 100 seconds cliff
    _frequencyController.text = '5'; // 5 seconds between releases
    _cliffAmountController.text = '100000'; // 100k tokens on cliff
    _periodAmountController.text = '50000'; // 50k tokens per period
    _periodsController.text = '5'; // 5 periods
  }

  @override
  void dispose() {
    _mintController.dispose();
    _recipientController.dispose();
    _cliffTimeController.dispose();
    _frequencyController.dispose();
    _cliffAmountController.dispose();
    _periodAmountController.dispose();
    _periodsController.dispose();
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

              // Recipient Address
              _buildRecipientInput(),
              const SizedBox(height: 20),

              // Lock Parameters Section
              _buildLockParametersSection(),
              const SizedBox(height: 20),

              // Summary Card
              _buildSummaryCard(),
              const SizedBox(height: 24),

              // Lock Button
              _buildLockButton(walletProvider),

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

  Widget _buildRecipientInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipient Address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _recipientController,
          decoration: InputDecoration(
            labelText: 'Recipient Wallet',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person),
            hintText: 'Enter recipient wallet address...',
            suffixIcon: TextButton(
              onPressed: () {
                // Set current wallet as recipient
                final publicKey = Provider.of<WalletProvider>(context, listen: false).publicKey;
                if (publicKey != null) {
                  _recipientController.text = publicKey;
                }
              },
              child: const Text('SELF'),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter recipient address';
            }
            if (value.length < 32) {
              return 'Invalid wallet address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLockParametersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lock Parameters',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Cliff Time
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cliffTimeController,
                decoration: const InputDecoration(
                  labelText: 'Cliff Time (seconds)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                  helperText: 'Time before any tokens unlock',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Invalid time';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frequency (seconds)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.repeat),
                  helperText: 'Time between releases',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Must be > 0';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Amounts
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cliffAmountController,
                decoration: const InputDecoration(
                  labelText: 'Cliff Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_open),
                  helperText: 'Tokens unlocked after cliff',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Invalid amount';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _periodAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount Per Period',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trending_up),
                  helperText: 'Tokens per frequency',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Must be > 0';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Number of Periods
        TextFormField(
          controller: _periodsController,
          decoration: const InputDecoration(
            labelText: 'Number of Periods',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.format_list_numbered),
            helperText: 'How many release periods',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter number of periods';
            }
            final num = int.tryParse(value);
            if (num == null || num <= 0) {
              return 'Must be greater than 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final cliffTime = int.tryParse(_cliffTimeController.text) ?? 0;
    final frequency = int.tryParse(_frequencyController.text) ?? 0;
    final cliffAmount = int.tryParse(_cliffAmountController.text) ?? 0;
    final periodAmount = int.tryParse(_periodAmountController.text) ?? 0;
    final periods = int.tryParse(_periodsController.text) ?? 0;
    
    final totalAmount = cliffAmount + (periodAmount * periods);
    final totalDuration = cliffTime + (frequency * periods);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lock Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Total Amount', totalAmount.toString()),
          _buildSummaryRow('Total Duration', '${totalDuration}s (${(totalDuration / 60).toStringAsFixed(1)} min)'),
          _buildSummaryRow('Cliff Duration', '${cliffTime}s'),
          _buildSummaryRow('Release Frequency', '${frequency}s'),
          _buildSummaryRow('Release Periods', periods.toString()),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildLockButton(WalletProvider walletProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (_isProcessing || walletProvider.isLoading)
            ? null
            : () => _performLock(walletProvider),
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.lock),
        label: Text(_isProcessing ? 'Creating Lock...' : 'Lock Tokens'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue[600],
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

  Future<void> _performLock(WalletProvider walletProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final lockParams = TokenLockParams(
        cliffTime: int.parse(_cliffTimeController.text),
        frequency: int.parse(_frequencyController.text),
        cliffUnlockAmount: int.parse(_cliffAmountController.text),
        amountPerPeriod: int.parse(_periodAmountController.text),
        numberOfPeriods: int.parse(_periodsController.text),
        tokenMint: _mintController.text.trim(),
        recipient: _recipientController.text.trim(),
      );

      final result = await walletProvider.lockTokens(lockParams);

      if (result.success) {
        _showSuccessDialog(result);
        _resetForm();
      } else {
        _showErrorDialog(result.error ?? 'Unknown error occurred');
      }
    } catch (e) {
      _showErrorDialog('Failed to lock tokens: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _resetForm() {
    _recipientController.clear();
    _formKey.currentState?.reset();
  }

  void _showSuccessDialog(result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lock Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tokens have been successfully locked!'),
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
        title: const Text('Lock Failed'),
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