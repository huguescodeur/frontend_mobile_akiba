import 'package:akiba/models/wallet_models/transaction_model.dart';
import 'package:akiba/models/wallet_models/wallet_model.dart';

// class WalletState {
//   final WalletModel? wallet;
//   final List<TransactionModel> transactions;
//   final bool isLoading;
//   final bool isConnected;
//   final String? error;
//   final bool isRefreshing;

//   WalletState({
//     this.wallet,
//     this.transactions = const [],
//     this.isLoading = false,
//     this.isConnected = false,
//     this.error,
//     this.isRefreshing = false,
//   });

//   WalletState copyWith({
//     WalletModel? wallet,
//     List<TransactionModel>? transactions,
//     bool? isLoading,
//     bool? isConnected,
//     String? error,
//     bool? isRefreshing,
//     bool clearError = false,
//   }) {
//     return WalletState(
//       wallet: wallet ?? this.wallet,
//       transactions: transactions ?? this.transactions,
//       isLoading: isLoading ?? this.isLoading,
//       isConnected: isConnected ?? this.isConnected,
//       error: clearError ? null : (error ?? this.error),
//       isRefreshing: isRefreshing ?? this.isRefreshing,
//     );
//   }

class WalletState {
  final WalletModel? wallet;
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool isRefreshing;
  final bool isConnected;
  final String? error;
  final bool requiresPinAuth; // ⭐ NOUVEAU

  const WalletState({
    this.wallet,
    this.transactions = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.isConnected = false,
    this.error,
    this.requiresPinAuth = false, // ⭐ NOUVEAU
  });

  WalletState copyWith({
    WalletModel? wallet,
    List<TransactionModel>? transactions,
    bool? isLoading,
    bool? isRefreshing,
    bool? isConnected,
    String? error,
    bool? requiresPinAuth, // ⭐ NOUVEAU
    bool clearError = false,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isConnected: isConnected ?? this.isConnected,
      error: clearError ? null : (error ?? this.error),
      requiresPinAuth: requiresPinAuth ?? this.requiresPinAuth, // ⭐ NOUVEAU
    );
  }

  double get balance => wallet?.balance ?? 0.0;
  String get formattedBalance => wallet?.formattedBalance ?? '0';
  bool get hasWallet => wallet != null;
  int get transactionCount => transactions.length;

  List<TransactionModel> get recentTransactions =>
      transactions.take(10).toList();
  List<TransactionModel> get allTransactions => transactions.toList();

  List<TransactionModel> get incomingTransactions =>
      transactions.where((t) => t.isIncoming).toList();

  List<TransactionModel> get outgoingTransactions =>
      transactions.where((t) => t.isOutgoing).toList();
}
