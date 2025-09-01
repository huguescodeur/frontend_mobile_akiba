import 'package:intl/intl.dart';

class WalletModel {
  final String uuid;
  final String userId;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletModel({
    required this.uuid,
    required this.userId,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      uuid: json['uuid'] ?? '',
      userId: json['user_id'] ?? '',
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'user_id': userId,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WalletModel copyWith({
    String? uuid,
    String? userId,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedBalance {
    final formatter = NumberFormat("#,##0", "fr_FR");
    return formatter.format(balance);
  }

  // String get formattedBalance => '${balance.toStringAsFixed(2)} ';
}
