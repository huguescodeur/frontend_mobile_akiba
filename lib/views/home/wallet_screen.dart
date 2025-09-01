import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akiba/viewmodels/wallet_view_model/wallet_provider.dart';

class WalletTestScreen extends ConsumerStatefulWidget {
  const WalletTestScreen({super.key});

  static const String idView = "wallettestview";

  @override
  ConsumerState<WalletTestScreen> createState() => _WalletTestScreenState();
}

class _WalletTestScreenState extends ConsumerState<WalletTestScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).loadWalletData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final balance = ref.watch(walletBalanceProvider);
    final formattedBalance = ref.watch(formattedBalanceProvider);
    final isConnected = ref.watch(walletConnectionStatusProvider);
    final transactions = ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Wallet WebSocket'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Indicateur de connexion WebSocket
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  isConnected ? 'Connecté' : 'Déconnecté',
                  style: TextStyle(
                    fontSize: 12,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(walletProvider.notifier).refreshWallet();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 SECTION TEST TEMPS RÉEL
              _buildTestSection(),

              const SizedBox(height: 20),

              // 💰 SECTION SOLDE
              _buildBalanceCard(walletState, balance, formattedBalance),

              const SizedBox(height: 20),

              // 🔄 SECTION STATUT
              _buildStatusCard(walletState, isConnected),

              const SizedBox(height: 20),

              // 📊 SECTION TRANSACTIONS
              _buildTransactionsSection(transactions, walletState),

              const SizedBox(height: 20),

              // 🛠️ SECTION ACTIONS TEST
              _buildActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestSection() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Test Temps Réel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '🔥 INSTRUCTIONS DE TEST:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Gardez cette page ouverte\n'
              '2. Faites un dépôt via Postman\n'
              '3. Observez le solde changer automatiquement\n'
              '4. Vérifiez que la transaction apparaît',
              style: TextStyle(color: Colors.orange.shade700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Heure actuelle: ${DateTime.now().toString().substring(0, 19)}',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.orange.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    walletState,
    double balance,
    String formattedBalance,
  ) {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Solde Current',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Solde principal (celui qui devrait changer automatiquement)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '💰 SOLDE AUTOMATIQUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedBalance,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Valeur brute: $balance',
                    style: TextStyle(
                      color: Colors.green.shade100,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Timestamp de dernière mise à jour
            if (walletState.wallet != null)
              Text(
                'Dernière MAJ: ${walletState.wallet!.updatedAt.toString().substring(0, 19)}',
                style: TextStyle(fontSize: 12, color: Colors.green.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(walletState, bool isConnected) {
    return Card(
      color: isConnected ? Colors.blue.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  color: isConnected ? Colors.blue : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Statut WebSocket',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isConnected
                            ? Colors.blue.shade800
                            : Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildStatusRow(
              'Connexion:',
              isConnected ? '✅ Connecté' : '❌ Déconnecté',
            ),
            _buildStatusRow(
              'Chargement:',
              walletState.isLoading ? '🔄 En cours' : '✅ Terminé',
            ),
            _buildStatusRow(
              'Actualisation:',
              walletState.isRefreshing ? '🔄 En cours' : '⭐ Prêt',
            ),
            _buildStatusRow('Erreur:', walletState.error ?? '✅ Aucune'),
            _buildStatusRow(
              'PIN requis:',
              walletState.requiresPinAuth ? '🔐 Oui' : '✅ Non',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(transactions, walletState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Transactions Récentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${transactions.length} transactions',
                  style: TextStyle(fontSize: 12, color: Colors.purple.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (transactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '📭 Aucune transaction\n\nFaites un test via Postman pour voir apparaître une transaction ici automatiquement !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...transactions
                  .take(5)
                  .map(
                    (transaction) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            transaction.isIncoming
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              transaction.isIncoming
                                  ? Colors.green.shade200
                                  : Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            transaction.isIncoming
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color:
                                transaction.isIncoming
                                    ? Colors.green
                                    : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.displayTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  transaction.createdAt.toString().substring(
                                    0,
                                    19,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            transaction.formattedAmount,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  transaction.isIncoming
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  'Actions de Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(walletProvider.notifier).refreshWallet();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(walletProvider.notifier).forceReconnect();
                    },
                    icon: const Icon(Icons.wifi),
                    label: const Text('Reconnecter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(walletProvider.notifier)
                      .loadWalletData(forceRefresh: true);
                },
                icon: const Icon(Icons.download),
                label: const Text('Recharger les Données'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
