import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallet_provider.dart';
import 'screens/wallet_overview_screen.dart';
import 'screens/token_operations_screen.dart';
import 'screens/transaction_history_screen.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Solana Wallet'),
            actions: [
              if (walletProvider.isConnected)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: walletProvider.isLoading 
                      ? null 
                      : () => walletProvider.refreshAccountData(),
                ),
              IconButton(
                icon: Icon(walletProvider.isConnected 
                    ? Icons.account_balance_wallet 
                    : Icons.account_balance_wallet_outlined),
                onPressed: () => _showWalletActions(context, walletProvider),
              ),
            ],
            bottom: walletProvider.isConnected
                ? TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                      Tab(text: 'Operations', icon: Icon(Icons.swap_horiz)),
                      Tab(text: 'History', icon: Icon(Icons.history)),
                    ],
                  )
                : null,
          ),
          body: walletProvider.isConnected
              ? TabBarView(
                  controller: _tabController,
                  children: const [
                    WalletOverviewScreen(),
                    TokenOperationsScreen(),
                    TransactionHistoryScreen(),
                  ],
                )
              : _buildWalletConnectScreen(context, walletProvider),
        );
      },
    );
  }

  Widget _buildWalletConnectScreen(BuildContext context, WalletProvider walletProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Connect Your Solana Wallet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connect your Solana wallet to start using token lock and burn features.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: walletProvider.isLoading
                  ? null
                  : () => walletProvider.connectWallet(),
              icon: walletProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.account_balance_wallet),
              label: Text(walletProvider.isLoading ? 'Connecting...' : 'Connect Wallet'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (walletProvider.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        walletProvider.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => walletProvider.clearError(),
                      color: Colors.red.shade700,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showWalletActions(BuildContext context, WalletProvider walletProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (walletProvider.isConnected) ...[
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Wallet Address'),
                subtitle: Text(
                  walletProvider.publicKey ?? 'Unknown',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    // Copy to clipboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address copied to clipboard')),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Data'),
                onTap: () {
                  walletProvider.refreshAccountData();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Disconnect Wallet', style: TextStyle(color: Colors.red)),
                onTap: () {
                  walletProvider.disconnectWallet();
                  Navigator.pop(context);
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Connect Wallet'),
                onTap: () {
                  walletProvider.connectWallet();
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}