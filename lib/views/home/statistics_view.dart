// ? Troisième Version Stats

import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/enum/date_filter_type.dart';
import 'package:akiba/models/statistics_models/filter_option_model.dart';
import 'package:akiba/views/statistics/filter_dialog.dart';
import 'package:akiba/widgets/components/statistics/build_Stat_card.dart';
import 'package:akiba/widgets/components/statistics/build_achievement_item.dart';
import 'package:akiba/widgets/components/statistics/build_achievements_section.dart';
import 'package:akiba/widgets/components/statistics/build_bar_group.dart';
import 'package:akiba/widgets/components/statistics/build_legend_item.dart';
import 'package:akiba/widgets/components/statistics/build_stat_item.dart';
import 'package:akiba/widgets/components/statistics/build_stats_section.dart';
import 'package:akiba/widgets/components/statistics/get_bar_bottom_titles.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  static const String idView = "statisticsview";

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  FilterOptionModel _currentFilter = FilterOptionModel(
    label: 'Janvier 2025',
    type: FilterType.month,
    startDate: DateTime(2025, 1, 1),
    endDate: DateTime(2025, 1, 31),
  );

  bool _isLoading = false;

  // Données simulées qui changent selon le filtre
  Map<String, dynamic> _currentData = {
    'totalSaved': 127500,
    'goalProgress': 75,
    'challenges': '3/5',
    'deposits': 245000,
    'withdrawals': 87500,
    'safes': 3,
    'avgSavings': 15420,
    'achievements': {'completed': 12, 'total': 15},
    'goals': {'completed': 4, 'total': 6},
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _slideController.forward();
    _scaleController.forward();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => FilterDialog(
            currentFilter: _currentFilter,
            onFilterSelected: (filter) {
              _updateFilter(filter);
            },
          ),
    );
  }

  void _updateFilter(FilterOptionModel newFilter) {
    setState(() {
      _isLoading = true;
      _currentFilter = newFilter;
    });

    // Simuler le chargement des nouvelles données
    Future.delayed(Duration(milliseconds: 300), () {
      _updateDataForFilter(newFilter);
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _updateDataForFilter(FilterOptionModel filter) {
    // Simuler des données différentes selon le filtre
    Map<String, dynamic> newData = {};

    switch (filter.type) {
      case FilterType.day:
        newData = {
          'totalSaved': 5200,
          'goalProgress': 15,
          'challenges': '1/2',
          'deposits': 8500,
          'withdrawals': 3300,
          'safes': 3,
          'avgSavings': 1040,
          'achievements': {'completed': 2, 'total': 5},
          'goals': {'completed': 1, 'total': 3},
        };
        break;
      case FilterType.month:
        newData = {
          'totalSaved': 127500,
          'goalProgress': 75,
          'challenges': '3/5',
          'deposits': 245000,
          'withdrawals': 87500,
          'safes': 3,
          'avgSavings': 15420,
          'achievements': {'completed': 12, 'total': 15},
          'goals': {'completed': 4, 'total': 6},
        };
        break;
      case FilterType.year:
        newData = {
          'totalSaved': 1540000,
          'goalProgress': 85,
          'challenges': '28/35',
          'deposits': 2800000,
          'withdrawals': 1260000,
          'safes': 5,
          'avgSavings': 128333,
          'achievements': {'completed': 145, 'total': 180},
          'goals': {'completed': 42, 'total': 50},
        };
        break;
      default:
        newData = {
          'totalSaved': 285000,
          'goalProgress': 68,
          'challenges': '7/12',
          'deposits': 520000,
          'withdrawals': 235000,
          'safes': 4,
          'avgSavings': 35625,
          'achievements': {'completed': 28, 'total': 42},
          'goals': {'completed': 9, 'total': 15},
        };
    }

    setState(() {
      _currentData = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec filtre
              SlideTransition(position: _slideAnimation, child: _buildHeader()),
              SizedBox(height: 24),

              // Résumé mensuel avec animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildSummaryCard(),
              ),
              SizedBox(height: 24),

              // Graphiques avec animations subtiles
              _buildChartSection('Évolution', _buildLineChart(), height: 250),
              SizedBox(height: 24),

              _buildChartSection(
                'Répartition des épargnes',
                _buildPieChart(),
                height: 220,
              ),
              SizedBox(height: 24),

              _buildChartSection('Performance', _buildBarChart(), height: 200),
              SizedBox(height: 24),

              // Stats cards
              _buildStatsSection(),
              SizedBox(height: 24),

              // Achievements
              _buildAchievementsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Statistiques',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: _showFilterDialog,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  _isLoading
                      ? AppColors.backgroundLightGray
                      : AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryLight.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (_isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryLight,
                      ),
                    ),
                  )
                else
                  Icon(
                    Iconsax.calendar_1,
                    size: 16,
                    color: AppColors.primaryLight,
                  ),
                SizedBox(width: 4),
                Text(
                  _currentFilter.label,
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Iconsax.arrow_down_1,
                  size: 12,
                  color: AppColors.primaryLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, Color(0xFF0066FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getperiodLabel(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Total épargné',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 800),
                    tween: Tween(
                      begin: 0,
                      end: _currentData['totalSaved'].toDouble(),
                    ),
                    builder: (context, value, child) {
                      return Text(
                        '${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
              AnimatedRotation(
                duration: Duration(milliseconds: 300),
                turns: _isLoading ? 1 : 0,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Iconsax.trend_up, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: buildStatItem(
                  'Objectif atteint',
                  '${_currentData['goalProgress']}%',
                  Iconsax.activity,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: buildStatItem(
                  'Challenges',
                  _currentData['challenges'],
                  Iconsax.cup,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getperiodLabel() {
    switch (_currentFilter.type) {
      case FilterType.day:
        return 'Aujourd\'hui';
      case FilterType.month:
        return 'Ce mois-ci';
      case FilterType.year:
        return 'Cette année';
      default:
        return 'Période sélectionnée';
    }
  }

  Widget _buildChartSection(String title, Widget chart, {double height = 200}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(height: height, child: chart),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: buildStatsSection('Résumé détaillé', [
        Row(
          children: [
            Expanded(
              child: buildStatCard(
                'Dépôts',
                '${_currentData['deposits'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
                '+12%',
                AppColors.success,
                Iconsax.arrow_up_3,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: buildStatCard(
                'Retraits',
                '${_currentData['withdrawals'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
                '-5%',
                AppColors.error,
                Iconsax.arrow_down,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: buildStatCard(
                'Coffres-forts',
                '${_currentData['safes']} actifs',
                '+1',
                AppColors.accentLight,
                Iconsax.safe_home,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: buildStatCard(
                'Épargne moy.',
                '${_currentData['avgSavings'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
                '/${_getPeriodUnit()}',
                AppColors.primaryLight,
                Iconsax.chart_1,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  String _getPeriodUnit() {
    switch (_currentFilter.type) {
      case FilterType.day:
        return 'jour';
      case FilterType.month:
      case FilterType.monthRange:
        return 'semaine';
      case FilterType.year:
      case FilterType.yearRange:
        return 'mois';
      default:
        return 'période';
    }
  }

  Widget _buildAchievementsSection() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: buildAchievementsSection(currentData: _currentData),
    );
  }

  // Méthodes pour les graphiques (identiques à votre code original)
  Widget _buildLineChart() {
    List<FlSpot> spots = _getChartData();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getHorizontalInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.backgroundLightGray, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toInt()}k',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _getBottomTitles(value.toInt()),
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight,
                AppColors.primaryLight.withOpacity(0.3),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primaryLight,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryLight.withOpacity(0.3),
                  AppColors.primaryLight.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getChartData() {
    switch (_currentFilter.type) {
      case FilterType.day:
        return [
          FlSpot(0, 1000),
          FlSpot(2, 1500),
          FlSpot(4, 2200),
          FlSpot(6, 1800),
          FlSpot(8, 3000),
          FlSpot(10, 2500),
          FlSpot(12, 4200),
          FlSpot(14, 3800),
          FlSpot(16, 5200),
        ];
      case FilterType.year:
        return [
          FlSpot(0, 120000),
          FlSpot(1, 180000),
          FlSpot(2, 150000),
          FlSpot(3, 240000),
          FlSpot(4, 320000),
          FlSpot(5, 280000),
          FlSpot(6, 380000),
          FlSpot(7, 450000),
          FlSpot(8, 520000),
          FlSpot(9, 480000),
          FlSpot(10, 620000),
          FlSpot(11, 580000),
        ];
      default: // month
        return [
          FlSpot(0, 30000),
          FlSpot(1, 45000),
          FlSpot(2, 35000),
          FlSpot(3, 60000),
          FlSpot(4, 80000),
          FlSpot(5, 127500),
        ];
    }
  }

  double _getHorizontalInterval() {
    switch (_currentFilter.type) {
      case FilterType.day:
        return 1000;
      case FilterType.year:
        return 100000;
      default:
        return 20000;
    }
  }

  String _getBottomTitles(int value) {
    switch (_currentFilter.type) {
      case FilterType.day:
        const hours = [
          '00h',
          '02h',
          '04h',
          '06h',
          '08h',
          '10h',
          '12h',
          '14h',
          '16h',
        ];
        return value < hours.length ? hours[value] : '';
      case FilterType.year:
        const months = [
          'Jan',
          'Fév',
          'Mar',
          'Avr',
          'Mai',
          'Jun',
          'Jul',
          'Aoû',
          'Sep',
          'Oct',
          'Nov',
          'Déc',
        ];
        return value < months.length ? months[value] : '';
      default:
        const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
        return value < months.length ? months[value] : '';
    }
  }

  Widget _buildPieChart() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: AppColors.primaryLight,
                  value: 45,
                  title: '45%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: AppColors.accentLight,
                  value: 30,
                  title: '30%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                PieChartSectionData(
                  color: AppColors.success,
                  value: 25,
                  title: '25%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLegendItem(
                'Épargne générale',
                AppColors.primaryLight,
                '${(_currentData['totalSaved'] * 0.45).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
              ),
              SizedBox(height: 8),
              buildLegendItem(
                'Projets',
                AppColors.accentLight,
                '${(_currentData['totalSaved'] * 0.30).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
              ),
              SizedBox(height: 8),
              buildLegendItem(
                'Urgences',
                AppColors.success,
                '${(_currentData['totalSaved'] * 0.25).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    List<BarChartGroupData> barGroups = _getBarChartData();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxBarValue(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  getBarBottomTitles(
                    value: value.toInt(),
                    currentFilter: _currentFilter,
                  ),
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  List<BarChartGroupData> _getBarChartData() {
    switch (_currentFilter.type) {
      case FilterType.day:
        return [
          buildBarGroup(0, 800),
          buildBarGroup(1, 1200),
          buildBarGroup(2, 900),
          buildBarGroup(3, 1500),
          buildBarGroup(4, 1100),
          buildBarGroup(5, 700),
        ];
      case FilterType.year:
        return [
          buildBarGroup(0, 45000),
          buildBarGroup(1, 38000),
          buildBarGroup(2, 52000),
          buildBarGroup(3, 42000),
          buildBarGroup(4, 48000),
          buildBarGroup(5, 35000),
          buildBarGroup(6, 58000),
          buildBarGroup(7, 47000),
          buildBarGroup(8, 53000),
          buildBarGroup(9, 41000),
          buildBarGroup(10, 49000),
          buildBarGroup(11, 44000),
        ];
      default:
        return [
          buildBarGroup(0, 15000),
          buildBarGroup(1, 8000),
          buildBarGroup(2, 22000),
          buildBarGroup(3, 12000),
          buildBarGroup(4, 18000),
          buildBarGroup(5, 5000),
          buildBarGroup(6, 10000),
        ];
    }
  }

  double _getMaxBarValue() {
    switch (_currentFilter.type) {
      case FilterType.day:
        return 2000;
      case FilterType.year:
        return 60000;
      default:
        return 25000;
    }
  }
}

// class StatisticsView extends StatefulWidget {
//   const StatisticsView({super.key});

//   static const String idView = "statisticsview";

//   @override
//   State<StatisticsView> createState() => _StatisticsViewState();
// }

// class _StatisticsViewState extends State<StatisticsView>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late AnimationController _scaleController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;

//   FilterOptionModel _currentFilter = FilterOptionModel(
//     label: 'Janvier 2025',
//     type: FilterType.month,
//     startDate: DateTime(2025, 1, 1),
//     endDate: DateTime(2025, 1, 31),
//   );

//   bool _isLoading = false;

//   // Données simulées qui changent selon le filtre
//   Map<String, dynamic> _currentData = {
//     'totalSaved': 127500,
//     'goalProgress': 75,
//     'challenges': '3/5',
//     'deposits': 245000,
//     'withdrawals': 87500,
//     'safes': 3,
//     'avgSavings': 15420,
//     'achievements': {'completed': 12, 'total': 15},
//     'goals': {'completed': 4, 'total': 6},
//   };

//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _fadeController.forward();
//   }

//   void _initAnimations() {
//     _fadeController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _scaleController = AnimationController(
//       duration: Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
//     );
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
//     );

//     _slideController.forward();
//     _scaleController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _scaleController.dispose();
//     super.dispose();
//   }

//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => FilterDialog(
//             currentFilter: _currentFilter,
//             onFilterSelected: (filter) {
//               _updateFilter(filter);
//             },
//           ),
//     );
//   }

//   void _updateFilter(FilterOptionModel newFilter) {
//     setState(() {
//       _isLoading = true;
//       _currentFilter = newFilter;
//     });

//     // Simuler le chargement des nouvelles données
//     _fadeController.reverse().then((_) {
//       _updateDataForFilter(newFilter);
//       _fadeController.forward();
//       setState(() {
//         _isLoading = false;
//       });
//     });
//   }

//   void _updateDataForFilter(FilterOptionModel filter) {
//     // Simuler des données différentes selon le filtre
//     Map<String, dynamic> newData = {};

//     switch (filter.type) {
//       case FilterType.day:
//         newData = {
//           'totalSaved': 5200,
//           'goalProgress': 15,
//           'challenges': '1/2',
//           'deposits': 8500,
//           'withdrawals': 3300,
//           'safes': 3,
//           'avgSavings': 1040,
//           'achievements': {'completed': 2, 'total': 5},
//           'goals': {'completed': 1, 'total': 3},
//         };
//         break;
//       case FilterType.month:
//         newData = {
//           'totalSaved': 127500,
//           'goalProgress': 75,
//           'challenges': '3/5',
//           'deposits': 245000,
//           'withdrawals': 87500,
//           'safes': 3,
//           'avgSavings': 15420,
//           'achievements': {'completed': 12, 'total': 15},
//           'goals': {'completed': 4, 'total': 6},
//         };
//         break;
//       case FilterType.year:
//         newData = {
//           'totalSaved': 1540000,
//           'goalProgress': 85,
//           'challenges': '28/35',
//           'deposits': 2800000,
//           'withdrawals': 1260000,
//           'safes': 5,
//           'avgSavings': 128333,
//           'achievements': {'completed': 145, 'total': 180},
//           'goals': {'completed': 42, 'total': 50},
//         };
//         break;
//       default:
//         // Pour les intervalles, calculer des moyennes
//         newData = {
//           'totalSaved': 285000,
//           'goalProgress': 68,
//           'challenges': '7/12',
//           'deposits': 520000,
//           'withdrawals': 235000,
//           'safes': 4,
//           'avgSavings': 35625,
//           'achievements': {'completed': 28, 'total': 42},
//           'goals': {'completed': 9, 'total': 15},
//         };
//     }

//     setState(() {
//       _currentData = newData;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: AnimatedBuilder(
//             animation: _fadeAnimation,
//             builder: (context, child) {
//               return Opacity(
//                 opacity: _fadeAnimation.value,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header avec filtre
//                     SlideTransition(
//                       position: _slideAnimation,
//                       child: _buildHeader(),
//                     ),
//                     SizedBox(height: 24),

//                     // Résumé mensuel avec animation
//                     ScaleTransition(
//                       scale: _scaleAnimation,
//                       child: _buildSummaryCard(),
//                     ),
//                     SizedBox(height: 24),

//                     // Graphiques avec animations
//                     _buildAnimatedChartSection(
//                       'Évolution',
//                       _buildLineChart(),
//                       height: 250,
//                       delay: 200,
//                     ),
//                     SizedBox(height: 24),

//                     _buildAnimatedChartSection(
//                       'Répartition des épargnes',
//                       _buildPieChart(),
//                       height: 220,
//                       delay: 400,
//                     ),
//                     SizedBox(height: 24),

//                     _buildAnimatedChartSection(
//                       'Performance',
//                       _buildBarChart(),
//                       height: 200,
//                       delay: 600,
//                     ),
//                     SizedBox(height: 24),

//                     // Stats cards avec animation
//                     _buildAnimatedStatsSection(),
//                     SizedBox(height: 24),

//                     // Achievements avec animation
//                     _buildAnimatedAchievementsSection(),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'Statistiques',
//           style: TextStyle(
//             color: AppColors.textLight,
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         GestureDetector(
//           onTap: _showFilterDialog,
//           child: AnimatedContainer(
//             duration: Duration(milliseconds: 200),
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color:
//                   _isLoading
//                       ? AppColors.backgroundLightGray
//                       : AppColors.primaryLight.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: AppColors.primaryLight.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 if (_isLoading)
//                   SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         AppColors.primaryLight,
//                       ),
//                     ),
//                   )
//                 else
//                   Icon(
//                     Iconsax.calendar_1,
//                     size: 16,
//                     color: AppColors.primaryLight,
//                   ),
//                 SizedBox(width: 4),
//                 Text(
//                   _currentFilter.label,
//                   style: TextStyle(
//                     color: AppColors.primaryLight,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(width: 4),
//                 Icon(
//                   Iconsax.arrow_down_1,
//                   size: 12,
//                   color: AppColors.primaryLight,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryCard() {
//     return Container(
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [AppColors.primaryLight, Color(0xFF0066FF)],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryLight.withOpacity(0.3),
//             blurRadius: 20,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _getperiodLabel(),
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 14,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Total épargné',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   TweenAnimationBuilder<double>(
//                     duration: Duration(milliseconds: 1000),
//                     tween: Tween(
//                       begin: 0,
//                       end: _currentData['totalSaved'].toDouble(),
//                     ),
//                     builder: (context, value, child) {
//                       return Text(
//                         '${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(Iconsax.trend_up, color: Colors.white, size: 24),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: buildStatItem(
//                   'Objectif atteint',
//                   '${_currentData['goalProgress']}%',
//                   Iconsax.activity,
//                 ),
//               ),
//               SizedBox(width: 20),
//               Expanded(
//                 child: buildStatItem(
//                   'Challenges',
//                   _currentData['challenges'],
//                   Iconsax.cup,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _getperiodLabel() {
//     switch (_currentFilter.type) {
//       case FilterType.day:
//         return 'Aujourd\'hui';
//       case FilterType.month:
//         return 'Ce mois-ci';
//       case FilterType.year:
//         return 'Cette année';
//       default:
//         return 'Période sélectionnée';
//     }
//   }

//   Widget _buildAnimatedChartSection(
//     String title,
//     Widget chart, {
//     double height = 200,
//     int delay = 0,
//   }) {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 600),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 20 * (1 - value)),
//           child: Opacity(
//             opacity: value,
//             child: Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 15,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: AppColors.textLight,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   SizedBox(height: height, child: chart),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildAnimatedStatsSection() {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 800),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.scale(
//           scale: 0.8 + (0.2 * value),
//           child: Opacity(
//             opacity: value,
//             child: buildStatsSection('Résumé détaillé', [
//               Row(
//                 children: [
//                   Expanded(
//                     child: buildStatCard(
//                       'Dépôts',
//                       '${_currentData['deposits'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
//                       '+12%',
//                       AppColors.success,
//                       Iconsax.arrow_up_3,
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: buildStatCard(
//                       'Retraits',
//                       '${_currentData['withdrawals'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
//                       '-5%',
//                       AppColors.error,
//                       Iconsax.arrow_down,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: buildStatCard(
//                       'Coffres-forts',
//                       '${_currentData['safes']} actifs',
//                       '+1',
//                       AppColors.accentLight,
//                       Iconsax.safe_home,
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: buildStatCard(
//                       'Épargne moy.',
//                       '${_currentData['avgSavings'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
//                       '/${_getPeriodUnit()}',
//                       AppColors.primaryLight,
//                       Iconsax.chart_1,
//                     ),
//                   ),
//                 ],
//               ),
//             ]),
//           ),
//         );
//       },
//     );
//   }

//   String _getPeriodUnit() {
//     switch (_currentFilter.type) {
//       case FilterType.day:
//         return 'jour';
//       case FilterType.month:
//       case FilterType.monthRange:
//         return 'semaine';
//       case FilterType.year:
//       case FilterType.yearRange:
//         return 'mois';
//       default:
//         return 'période';
//     }
//   }

//   Widget _buildAnimatedAchievementsSection() {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 1000),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 30 * (1 - value)),
//           child: Opacity(
//             opacity: value,
//             child: buildAchievementsSection(currentData: _currentData),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildLineChart() {
//     List<FlSpot> spots = _getChartData();

//     return LineChart(
//       LineChartData(
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: _getHorizontalInterval(),
//           getDrawingHorizontalLine: (value) {
//             return FlLine(color: AppColors.backgroundLightGray, strokeWidth: 1);
//           },
//         ),
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 50,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   '${(value / 1000).toInt()}k',
//                   style: TextStyle(
//                     color: AppColors.textSecondaryLight,
//                     fontSize: 12,
//                   ),
//                 );
//               },
//             ),
//           ),
//           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   _getBottomTitles(value.toInt()),
//                   style: TextStyle(
//                     color: AppColors.textSecondaryLight,
//                     fontSize: 12,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         borderData: FlBorderData(show: false),
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             isCurved: true,
//             gradient: LinearGradient(
//               colors: [
//                 AppColors.primaryLight,
//                 AppColors.primaryLight.withOpacity(0.3),
//               ],
//             ),
//             barWidth: 3,
//             isStrokeCapRound: true,
//             dotData: FlDotData(
//               show: true,
//               getDotPainter: (spot, percent, barData, index) {
//                 return FlDotCirclePainter(
//                   radius: 4,
//                   color: AppColors.primaryLight,
//                   strokeWidth: 2,
//                   strokeColor: Colors.white,
//                 );
//               },
//             ),
//             belowBarData: BarAreaData(
//               show: true,
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   AppColors.primaryLight.withOpacity(0.3),
//                   AppColors.primaryLight.withOpacity(0.05),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<FlSpot> _getChartData() {
//     switch (_currentFilter.type) {
//       case FilterType.day:
//         return [
//           FlSpot(0, 1000),
//           FlSpot(2, 1500),
//           FlSpot(4, 2200),
//           FlSpot(6, 1800),
//           FlSpot(8, 3000),
//           FlSpot(10, 2500),
//           FlSpot(12, 4200),
//           FlSpot(14, 3800),
//           FlSpot(16, 5200),
//         ];
//       case FilterType.year:
//         return [
//           FlSpot(0, 120000),
//           FlSpot(1, 180000),
//           FlSpot(2, 150000),
//           FlSpot(3, 240000),
//           FlSpot(4, 320000),
//           FlSpot(5, 280000),
//           FlSpot(6, 380000),
//           FlSpot(7, 450000),
//           FlSpot(8, 520000),
//           FlSpot(9, 480000),
//           FlSpot(10, 620000),
//           FlSpot(11, 580000),
//         ];
//       default: // month
//         return [
//           FlSpot(0, 30000),
//           FlSpot(1, 45000),
//           FlSpot(2, 35000),
//           FlSpot(3, 60000),
//           FlSpot(4, 80000),
//           FlSpot(5, 127500),
//         ];
//     }
//   }

//   double _getHorizontalInterval() {
//     switch (_currentFilter.type) {
//       case FilterType.day:
//         return 1000;
//       case FilterType.year:
//         return 100000;
//       default:
//         return 20000;
//     }
//   }

//   String _getBottomTitles(int value) {
//     switch (_currentFilter.type) {
//       case FilterType.day:
//         const hours = [
//           '00h',
//           '02h',
//           '04h',
//           '06h',
//           '08h',
//           '10h',
//           '12h',
//           '14h',
//           '16h',
//         ];
//         return value < hours.length ? hours[value] : '';
//       case FilterType.year:
//         const months = [
//           'Jan',
//           'Fév',
//           'Mar',
//           'Avr',
//           'Mai',
//           'Jun',
//           'Jul',
//           'Aoû',
//           'Sep',
//           'Oct',
//           'Nov',
//           'Déc',
//         ];
//         return value < months.length ? months[value] : '';
//       default:
//         const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
//         return value < months.length ? months[value] : '';
//     }
//   }

//   Widget _buildPieChart() {
//     return Row(
//       children: [
//         Expanded(
//           flex: 2,
//           child: PieChart(
//             PieChartData(
//               sectionsSpace: 2,
//               centerSpaceRadius: 40,
//               sections: [
//                 PieChartSectionData(
//                   color: AppColors.primaryLight,
//                   value: 45,
//                   title: '45%',
//                   radius: 50,
//                   titleStyle: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 PieChartSectionData(
//                   color: AppColors.accentLight,
//                   value: 30,
//                   title: '30%',
//                   radius: 50,
//                   titleStyle: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textLight,
//                   ),
//                 ),
//                 PieChartSectionData(
//                   color: AppColors.success,
//                   value: 25,
//                   title: '25%',
//                   radius: 50,
//                   titleStyle: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               buildLegendItem(
//                 'Épargne générale',
//                 AppColors.primaryLight,
//                 '${(_currentData['totalSaved'] * 0.45).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
//               ),
//               SizedBox(height: 8),
//               buildLegendItem(
//                 'Projets',
//                 AppColors.accentLight,
//                 '${(_currentData['totalSaved'] * 0.30).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
//               ),
//               SizedBox(height: 8),
//               buildLegendItem(
//                 'Urgences',
//                 AppColors.success,
//                 '${(_currentData['totalSaved'] * 0.25).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} CFA',
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBarChart() {
//     List<BarChartGroupData> barGroups = _getBarChartData();

//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: _getMaxBarValue(),
//         barTouchData: BarTouchData(enabled: false),
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   getBarBottomTitles(
//                     value: value.toInt(),
//                     currentFilter: _currentFilter,
//                   ),
//                   style: TextStyle(
//                     color: AppColors.textSecondaryLight,
//                     fontSize: 12,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: FlGridData(show: false),
//         barGroups: barGroups,
//       ),
//     );
//   }

//   List<BarChartGroupData> _getBarChartData() {
//     switch (_currentFilter.type) {
//       case FilterType.day:
//         return [
//           buildBarGroup(0, 800),
//           buildBarGroup(1, 1200),
//           buildBarGroup(2, 900),
//           buildBarGroup(3, 1500),
//           buildBarGroup(4, 1100),
//           buildBarGroup(5, 700),
//         ];
//       case FilterType.year:
//         return [
//           buildBarGroup(0, 45000),
//           buildBarGroup(1, 38000),
//           buildBarGroup(2, 52000),
//           buildBarGroup(3, 42000),
//           buildBarGroup(4, 48000),
//           buildBarGroup(5, 35000),
//           buildBarGroup(6, 58000),
//           buildBarGroup(7, 47000),
//           buildBarGroup(8, 53000),
//           buildBarGroup(9, 41000),
//           buildBarGroup(10, 49000),
//           buildBarGroup(11, 44000),
//         ];
//       default:
//         return [
//           buildBarGroup(0, 15000),
//           buildBarGroup(1, 8000),
//           buildBarGroup(2, 22000),
//           buildBarGroup(3, 12000),
//           buildBarGroup(4, 18000),
//           buildBarGroup(5, 5000),
//           buildBarGroup(6, 10000),
//         ];
//     }
//   }

//   double _getMaxBarValue() {
//     switch (_currentFilter.type) {
//       case FilterType.day:
//         return 2000;
//       case FilterType.year:
//         return 60000;
//       default:
//         return 25000;
//     }
//   }
// }
