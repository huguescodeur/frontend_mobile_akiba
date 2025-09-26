import 'package:akiba/models/wallet_models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:akiba/constants/app_colors.dart';

class TransactionDetailView extends StatelessWidget {
  final TransactionModel transaction;
  final String currentUserId;

  const TransactionDetailView({
    super.key,
    required this.transaction,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Détails de la transaction"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête principal avec montant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: transaction.transactionColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      transaction.transactionIcon,
                      color: transaction.transactionColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.getDisplayTitle(currentUserId),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.getFormattedAmountForUser(currentUserId),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: transaction.transactionColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(transaction.createdAt),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informations détaillées
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informations",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow(
                    "Type",
                    _getTransactionTypeLabel(transaction.transactionType),
                  ),

                  if (transaction.senderName != null)
                    _buildInfoRow("Expéditeur", transaction.senderName!),

                  if (transaction.receiverName != null)
                    _buildInfoRow("Destinataire", transaction.receiverName!),

                  if (transaction.operator != null)
                    _buildInfoRow("Opérateur", transaction.operator!),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Bouton de fermeture
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textLight.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Retour",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return 'Dépôt';
      case 'withdraw':
        return 'Retrait';
      case 'transfer':
        return 'Transfert';
      case 'challenge':
        return 'Challenge';
      default:
        return type; // Retourne le type original si non reconnu
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
