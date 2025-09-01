import 'package:akiba/viewmodels/wallet_view_model/wallet_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akiba/models/wallet_models/transaction_model.dart';
import 'wallet_state.dart';

// Provider principal
final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((
  ref,
) {
  return WalletNotifier();
});

// Providers dérivés
final walletBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletProvider).balance;
});

final formattedBalanceProvider = Provider<String>((ref) {
  return ref.watch(walletProvider).formattedBalance;
});

final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(walletProvider).recentTransactions;
});

final walletConnectionStatusProvider = Provider<bool>((ref) {
  return ref.watch(walletProvider).isConnected;
});

final transactionCountProvider = Provider<int>((ref) {
  return ref.watch(walletProvider).transactionCount;
});

// Provider pour les transactions filtrées
final incomingTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(walletProvider).incomingTransactions;
});

final outgoingTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(walletProvider).outgoingTransactions;
});
