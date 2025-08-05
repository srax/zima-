import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/wallet_provider.dart';
import '../../models/transaction_result.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        return Column(
          children: [
            // Header with actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Transaction History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (walletProvider.transactionHistory.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _showClearConfirmation(context, walletProvider),
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear'),
                    ),
                ],
              ),
            ),

            // Transaction List
            Expanded(
              child: walletProvider.transactionHistory.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => walletProvider.refreshAccountData(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: walletProvider.transactionHistory.length,
                        itemBuilder: (context, index) {
                          final transaction = walletProvider.transactionHistory[index];
                          return _buildTransactionCard(transaction);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionResult transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.success 
              ? Colors.green.shade100 
              : Colors.red.shade100,
          child: Icon(
            transaction.success ? Icons.check : Icons.error,
            color: transaction.success 
                ? Colors.green.shade700 
                : Colors.red.shade700,
          ),
        ),
        title: Row(
          children: [
            Text(
              transaction.success ? 'Success' : 'Failed',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: transaction.success 
                    ? Colors.green.shade700 
                    : Colors.red.shade700,
              ),
            ),
            const Spacer(),
            Text(
              _formatTime(transaction.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (transaction.success && transaction.signature != null) ...[
              const Text('Signature:', style: TextStyle(fontSize: 12)),
              Text(
                _truncateSignature(transaction.signature!),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ] else if (!transaction.success && transaction.error != null) ...[
              Text(
                transaction.error!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: transaction.success && transaction.explorerUrl != null
            ? IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => _openExplorer(transaction.explorerUrl!),
                tooltip: 'View on Explorer',
              )
            : null,
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _truncateSignature(String signature) {
    if (signature.length <= 20) return signature;
    return '${signature.substring(0, 10)}...${signature.substring(signature.length - 10)}';
  }

  void _showTransactionDetails(TransactionResult transaction) {
    // This would show a detailed view of the transaction
    print('Show transaction details: $transaction');
  }

  void _openExplorer(String url) {
    // This would open the explorer URL
    print('Open explorer: $url');
  }

  void _showClearConfirmation(BuildContext context, WalletProvider walletProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all transaction history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              walletProvider.clearTransactionHistory();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}