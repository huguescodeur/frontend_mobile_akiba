import 'dart:developer';

import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TransactionModel {
  final String uuid;
  final String? senderId;
  final String? receiverId;
  final String? senderName;
  final String? receiverName;
  final String? operator;
  final double amount;
  final String transactionType;
  final DateTime createdAt;

  TransactionModel({
    required this.uuid,
    this.senderId,
    this.receiverId,
    this.senderName,
    this.receiverName,
    this.operator,
    required this.amount,
    required this.transactionType,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      uuid: json['uuid'] ?? '',
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      senderName: json['sender_name'],
      receiverName: json['receiver_name'],
      operator: json['operator'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,

      transactionType: json['transaction_type'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'sender_name': senderName,
      'receiver_name': receiverName,
      'operator': operator,
      'amount': amount,
      'transaction_type': transactionType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // String get formattedAmount => '${amount.toStringAsFixed(2)} FCFA';
  String get formattedAmount => '${amount.toStringAsFixed(0)} CFA';

  String getDisplayTitle(String currentUserId) {
    switch (transactionType) {
      case 'deposit':
        return operator != null ? 'Dépôt $operator' : 'Dépôt';
      case 'withdraw':
        return operator != null ? 'Retrait $operator' : 'Retrait';
      case 'transfer':
        // Si l'utilisateur actuel est l'expéditeur
        if (senderId == currentUserId) {
          return receiverName != null
              ? 'Transfert vers $receiverName'
              : 'Transfert envoyé';
        }
        // Si l'utilisateur actuel est le destinataire
        else if (receiverId == currentUserId) {
          return senderName != null ? 'Reçu de $senderName' : 'Transfert reçu';
        }
        // Cas d'erreur (ne devrait pas arriver)
        else {
          return 'Transfert';
        }
      case 'challenge':
        return operator != null
            ? 'Bonus challenge $operator'
            : 'Bonus challenge';
      default:
        return transactionType;
    }
  }

  String get displayTitle {
    switch (transactionType) {
      case 'deposit':
        return operator != null ? 'Dépôt $operator' : 'Dépôt';
      case 'withdraw':
        return operator != null ? 'Retrait $operator' : 'Retrait';
      case 'transfer':
        return receiverName != null
            ? 'Transfert vers $receiverName'
            : 'Transfert';
      case 'challenge':
        return operator != null
            ? 'Bonus challenge $operator'
            : 'Bonus challenge';
      default:
        return transactionType;
    }
  }

  // Méthode pour déterminer si c'est une transaction entrante pour l'utilisateur
  bool isIncomingForUser(String currentUserId) {
    switch (transactionType) {
      case 'deposit':
      case 'challenge':
        return true;
      case 'withdraw':
        return false;
      case 'transfer':
        return receiverId == currentUserId;
      default:
        return false;
    }
  }

  // Méthode pour déterminer si c'est une transaction sortante pour l'utilisateur
  bool isOutgoingForUser(String currentUserId) {
    switch (transactionType) {
      case 'deposit':
      case 'challenge':
        return false;
      case 'withdraw':
        return true;
      case 'transfer':
        return senderId == currentUserId;
      default:
        return false;
    }
  }

  bool get isIncoming =>
      transactionType == 'deposit' ||
      (transactionType == 'transfer' && receiverId != null);
  bool get isOutgoing =>
      transactionType == 'withdraw' ||
      (transactionType == 'transfer' && senderId != null);

  IconData get transactionIcon {
    switch (transactionType) {
      case 'deposit':
        return Iconsax.add_circle;
      case 'withdraw':
        return Iconsax.minus_cirlce;
      case 'transfer':
        return Iconsax.send_2;
      case 'challenge':
        return Iconsax.cup;
      default:
        return Iconsax.card;
    }
  }

  // Getter pour la couleur selon le type
  Color get transactionColor {
    switch (transactionType) {
      case 'deposit':
        return AppColors.success;
      case 'withdraw':
        return AppColors.error;
      case 'transfer':
        return AppColors.primaryLight;
      case 'challenge':
        return AppColors.accentLight;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  String getFormattedAmountForUser(String currentUserId) {
    log("Current User Id For User: $currentUserId");
    String sign = '';
    switch (transactionType) {
      case 'deposit':
      case 'challenge':
        sign = '+';
        break;
      case 'withdraw':
        sign = '-';
        break;
      case 'transfer':
        if (senderId == currentUserId) {
          sign = '-'; // L'utilisateur envoie
        } else if (receiverId == currentUserId) {
          sign = '+'; // L'utilisateur reçoit
        } else {
          sign = '--'; // Cas d'erreur, ne devrait pas arriver
        }
        break;
      default:
        sign = '@@';
    }
    return '$sign ${amount.toStringAsFixed(0)} CFA';
  }
}
