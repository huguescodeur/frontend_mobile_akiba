import 'package:akiba/models/wallet_models/transaction_model.dart';
import 'package:akiba/models/wallet_models/wallet_model.dart';

// class WalletResponseModel {
//   final bool success;
//   final String message;
//   final WalletModel? wallet;
//   final List<TransactionModel>? transactions;

//   WalletResponseModel({
//     required this.success,
//     required this.message,
//     this.wallet,
//     this.transactions,
//   });

//   factory WalletResponseModel.fromJson(Map<String, dynamic> json) {
//     return WalletResponseModel(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       wallet:
//           json['wallet'] != null ? WalletModel.fromJson(json['wallet']) : null,
//       transactions:
//           json['transactions'] != null
//               ? (json['transactions'] as List)
//                   .map((transaction) => TransactionModel.fromJson(transaction))
//                   .toList()
//               : null,
//     );
//   }
// }

class WalletResponseModel {
  final bool success;
  final String message;
  final WalletModel? wallet;
  final List<TransactionModel> transactions;

  WalletResponseModel({
    required this.success,
    required this.message,
    this.wallet,
    required this.transactions,
  });

  factory WalletResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      wallet:
          json['wallet'] != null ? WalletModel.fromJson(json['wallet']) : null,
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map((item) => TransactionModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
