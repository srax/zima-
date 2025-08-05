import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/wallet_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/token_list_widget.dart';

class WalletOverviewScreen extends StatelessWidget {
  const WalletOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        if (walletProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => walletProvider.refreshAccountData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SOL Balance Card
                BalanceCard(
                  title: 'SOL Balance',
                  balance: walletProvider.solBalance,
                  symbol: 'SOL',
                  icon: Icons.account_balance_wallet,
                ),
                const SizedBox(height: 16),
                
                // Wallet Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wallet Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Address',
                          walletProvider.publicKey ?? 'Unknown',
                          isMonospace: true,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Network',
                          'Solana Devnet', // Could be dynamic based on config
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Connected',
                          walletProvider.connection.connectedAt?.toString() ?? 'Unknown',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Token Accounts
                const Text(
                  'Token Accounts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (walletProvider.tokenAccounts.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tokens found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your token accounts will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  TokenListWidget(tokens: walletProvider.tokenAccounts),
                
                const SizedBox(height: 16),
                
                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to token operations with burn tab selected
                          DefaultTabController.of(context)?.animateTo(1);
                        },
                        icon: const Icon(Icons.local_fire_department),
                        label: const Text('Burn Tokens'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to token operations with lock tab selected
                          DefaultTabController.of(context)?.animateTo(1);
                        },
                        icon: const Icon(Icons.lock),
                        label: const Text('Lock Tokens'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMonospace = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: isMonospace ? 'monospace' : null,
              fontSize: isMonospace ? 12 : 14,
            ),
          ),
        ),
      ],
    );
  }
}