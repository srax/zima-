import 'dart:typed_data';
import 'dart:convert';

import 'package:solana/solana.dart';
import 'package:bs58/bs58.dart';

import '../models/token_lock_params.dart';
import '../models/token_burn_params.dart';
import '../models/transaction_result.dart';
import 'solana_config.dart';
import 'solana_client.dart';

/// API for interacting with the Meteora Token Lock & Burn program
class MeteoraProgamApi {
  final SolanaClient _solanaClient;

  MeteoraProgamApi(this._solanaClient);

  /// Create and send a token lock transaction
  Future<TransactionResult> lockTokens(TokenLockParams params) async {
    try {
      if (!_solanaClient.isConnected) {
        throw Exception('Wallet not connected');
      }

      // Create the instruction for proxy_lock
      final instruction = await _createProxyLockInstruction(params);
      
      // Build transaction
      final recentBlockhash = await _solanaClient.getRecentBlockhash();
      final transaction = Transaction(
        instructions: [instruction],
        recentBlockhash: recentBlockhash,
        feePayer: Ed25519HDPublicKey.fromBase58(_solanaClient.publicKey!),
      );

      // Sign transaction using Mobile Wallet Adapter
      final serializedTx = transaction.serializeMessage();
      final signedTx = await _solanaClient.signTransaction(serializedTx);

      // Send transaction
      return await _solanaClient.sendTransaction(signedTx);
    } catch (e) {
      return TransactionResult.failure(error: 'Failed to lock tokens: $e');
    }
  }

  /// Create and send a token burn transaction
  Future<TransactionResult> burnTokens(TokenBurnParams params) async {
    try {
      if (!_solanaClient.isConnected) {
        throw Exception('Wallet not connected');
      }

      // Create the instruction for token_burn
      final instruction = await _createTokenBurnInstruction(params);
      
      // Build transaction
      final recentBlockhash = await _solanaClient.getRecentBlockhash();
      final transaction = Transaction(
        instructions: [instruction],
        recentBlockhash: recentBlockhash,
        feePayer: Ed25519HDPublicKey.fromBase58(_solanaClient.publicKey!),
      );

      // Sign transaction using Mobile Wallet Adapter
      final serializedTx = transaction.serializeMessage();
      final signedTx = await _solanaClient.signTransaction(serializedTx);

      // Send transaction
      return await _solanaClient.sendTransaction(signedTx);
    } catch (e) {
      return TransactionResult.failure(error: 'Failed to burn tokens: $e');
    }
  }

  /// Create proxy_lock instruction
  Future<TransactionInstruction> _createProxyLockInstruction(TokenLockParams params) async {
    final programId = Ed25519HDPublicKey.fromBase58(SolanaConfig.meteoraTokenLockBurnProgramId);
    final userPublicKey = Ed25519HDPublicKey.fromBase58(_solanaClient.publicKey!);
    final mintPublicKey = Ed25519HDPublicKey.fromBase58(params.tokenMint);
    final recipientPublicKey = Ed25519HDPublicKey.fromBase58(params.recipient);

    // Derive PDAs
    final poolPda = await _findPoolPda(mintPublicKey);
    final escrowPda = await _findEscrowPda(userPublicKey);
    final eventAuthorityPda = await _findEventAuthorityPda();

    // Get associated token accounts
    final poolTokenAccount = await _getAssociatedTokenAccount(mintPublicKey, poolPda);
    final escrowTokenAccount = await _getAssociatedTokenAccount(mintPublicKey, escrowPda);

    // Create instruction data
    final instructionData = _encodeProxyLockData(params);

    return TransactionInstruction(
      programId: programId,
      accounts: [
        AccountMeta.writeable(pubKey: userPublicKey, isSigner: true),
        AccountMeta.writeable(pubKey: poolPda, isSigner: false),
        AccountMeta.readonly(pubKey: mintPublicKey, isSigner: false),
        AccountMeta.writeable(pubKey: escrowPda, isSigner: false),
        AccountMeta.writeable(pubKey: escrowTokenAccount, isSigner: false),
        AccountMeta.writeable(pubKey: poolPda, isSigner: false), // sender
        AccountMeta.writeable(pubKey: poolTokenAccount, isSigner: false), // sender_token
        AccountMeta.readonly(pubKey: eventAuthorityPda, isSigner: false),
        AccountMeta.writeable(pubKey: recipientPublicKey, isSigner: false),
        AccountMeta.readonly(pubKey: Ed25519HDPublicKey.fromBase58(SolanaConfig.tokenProgramId), isSigner: false),
        AccountMeta.readonly(pubKey: Ed25519HDPublicKey.fromBase58(SolanaConfig.systemProgramId), isSigner: false),
        AccountMeta.readonly(pubKey: Ed25519HDPublicKey.fromBase58(SolanaConfig.associatedTokenProgramId), isSigner: false),
        AccountMeta.readonly(pubKey: Ed25519HDPublicKey.fromBase58(SolanaConfig.jupiterLockProgramId), isSigner: false),
      ],
      data: instructionData,
    );
  }

  /// Create token_burn instruction
  Future<TransactionInstruction> _createTokenBurnInstruction(TokenBurnParams params) async {
    final programId = Ed25519HDPublicKey.fromBase58(SolanaConfig.meteoraTokenLockBurnProgramId);
    final userPublicKey = Ed25519HDPublicKey.fromBase58(_solanaClient.publicKey!);
    final mintPublicKey = Ed25519HDPublicKey.fromBase58(params.tokenMint);
    final userTokenAccount = Ed25519HDPublicKey.fromBase58(params.userTokenAccount);

    // Create instruction data
    final instructionData = _encodeTokenBurnData(params);

    return TransactionInstruction(
      programId: programId,
      accounts: [
        AccountMeta.writeable(pubKey: userPublicKey, isSigner: true),
        AccountMeta.writeable(pubKey: userTokenAccount, isSigner: false),
        AccountMeta.writeable(pubKey: mintPublicKey, isSigner: false),
        AccountMeta.readonly(pubKey: Ed25519HDPublicKey.fromBase58(SolanaConfig.tokenProgramId), isSigner: false),
      ],
      data: instructionData,
    );
  }

  /// Find Pool PDA
  Future<Ed25519HDPublicKey> _findPoolPda(Ed25519HDPublicKey mint) async {
    final seeds = [
      mint.bytes,
      utf8.encode(SolanaConfig.poolSeed),
    ];
    
    final result = await Ed25519HDPublicKey.findProgramAddress(
      seeds: seeds,
      programId: Ed25519HDPublicKey.fromBase58(SolanaConfig.meteoraTokenLockBurnProgramId),
    );
    
    return result.address;
  }

  /// Find Escrow PDA (Jupiter Lock)
  Future<Ed25519HDPublicKey> _findEscrowPda(Ed25519HDPublicKey base) async {
    final seeds = [
      utf8.encode(SolanaConfig.escrowSeed),
      base.bytes,
    ];
    
    final result = await Ed25519HDPublicKey.findProgramAddress(
      seeds: seeds,
      programId: Ed25519HDPublicKey.fromBase58(SolanaConfig.jupiterLockProgramId),
    );
    
    return result.address;
  }

  /// Find Event Authority PDA (Jupiter Lock)
  Future<Ed25519HDPublicKey> _findEventAuthorityPda() async {
    final seeds = [
      utf8.encode(SolanaConfig.eventAuthoritySeed),
    ];
    
    final result = await Ed25519HDPublicKey.findProgramAddress(
      seeds: seeds,
      programId: Ed25519HDPublicKey.fromBase58(SolanaConfig.jupiterLockProgramId),
    );
    
    return result.address;
  }

  /// Get Associated Token Account address
  Future<Ed25519HDPublicKey> _getAssociatedTokenAccount(
    Ed25519HDPublicKey mint,
    Ed25519HDPublicKey owner,
  ) async {
    final seeds = [
      owner.bytes,
      Ed25519HDPublicKey.fromBase58(SolanaConfig.tokenProgramId).bytes,
      mint.bytes,
    ];
    
    final result = await Ed25519HDPublicKey.findProgramAddress(
      seeds: seeds,
      programId: Ed25519HDPublicKey.fromBase58(SolanaConfig.associatedTokenProgramId),
    );
    
    return result.address;
  }

  /// Encode proxy_lock instruction data
  Uint8List _encodeProxyLockData(TokenLockParams params) {
    // Instruction discriminator + parameters
    // Note: This is a simplified encoding. In a real implementation,
    // you would use proper Borsh serialization matching the Anchor program
    final writer = ByteDataWriter();
    
    // Instruction discriminator (first 8 bytes) - would need to calculate proper sighash
    writer.writeUint64(0); // placeholder
    
    // Parameters
    writer.writeUint64(params.cliffTime);
    writer.writeUint64(params.frequency);
    writer.writeUint64(params.cliffUnlockAmount);
    writer.writeUint64(params.amountPerPeriod);
    writer.writeUint64(params.numberOfPeriods);
    
    return writer.toBytes();
  }

  /// Encode token_burn instruction data
  Uint8List _encodeTokenBurnData(TokenBurnParams params) {
    // Instruction discriminator + amount
    final writer = ByteDataWriter();
    
    // Instruction discriminator (first 8 bytes) - would need to calculate proper sighash
    writer.writeUint64(1); // placeholder for burn instruction
    
    // Amount parameter
    writer.writeUint64(params.amount);
    
    return writer.toBytes();
  }
}

/// Helper class for writing binary data
class ByteDataWriter {
  final List<int> _buffer = [];

  void writeUint64(int value) {
    final bytes = ByteData(8);
    bytes.setUint64(0, value, Endian.little);
    _buffer.addAll(bytes.buffer.asUint8List());
  }

  Uint8List toBytes() => Uint8List.fromList(_buffer);
}