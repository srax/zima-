import 'package:flutter/material.dart';

import '../../models/token_account.dart';

class TokenListWidget extends StatelessWidget {
  final List<TokenAccount> tokens;

  const TokenListWidget({
    super.key,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tokens.map((token) => _buildTokenCard(token)).toList(),
    );
  }

  Widget _buildTokenCard(TokenAccount token) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: token.logoUrl != null
              ? ClipOval(
                  child: Image.network(
                    token.logoUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.token),
                  ),
                )
              : const Icon(Icons.token),
        ),
        title: Text(
          token.symbol ?? token.name ?? 'Unknown Token',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mint: ${_truncateAddress(token.mint)}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            Text(
              'Account: ${_truncateAddress(token.address)}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              token.balance.toStringAsFixed(token.decimals > 6 ? 6 : token.decimals),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (token.symbol != null)
              Text(
                token.symbol!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        onTap: () => _showTokenDetails(token),
      ),
    );
  }

  String _truncateAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 8)}';
  }

  void _showTokenDetails(TokenAccount token) {
    // This would show a detailed view of the token
    // For now, we'll just print the details
    print('Token details: $token');
  }
}