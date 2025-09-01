import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/enum/date_filter_type.dart';
import 'package:akiba/models/statistics_models/filter_option_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FilterDialog extends StatefulWidget {
  final FilterOptionModel currentFilter;
  final Function(FilterOptionModel) onFilterSelected;

  static const String idView = "profileview";

  const FilterDialog({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrer les statistiques',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Tabs
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primaryLight,
              labelColor: AppColors.primaryLight,
              unselectedLabelColor: AppColors.textSecondaryLight,
              tabs: [
                Tab(text: 'Jour'),
                Tab(text: 'Mois'),
                Tab(text: 'Année'),
                Tab(text: 'Période (J)'),
                Tab(text: 'Période (M)'),
                Tab(text: 'Période (A)'),
              ],
            ),
            SizedBox(height: 20),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDaySelection(),
                  _buildMonthSelection(),
                  _buildYearSelection(),
                  _buildDayRangeSelection(),
                  _buildMonthRangeSelection(),
                  _buildYearRangeSelection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelection() {
    return Column(
      children: [
        Text(
          'Sélectionner un jour',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              final days = [
                'Aujourd\'hui',
                'Hier',
                'Avant-hier',
                '4 jours',
                '5 jours',
                '6 jours',
                '1 semaine',
              ];
              final dates = [
                DateTime.now(),
                DateTime.now().subtract(Duration(days: 1)),
                DateTime.now().subtract(Duration(days: 2)),
                DateTime.now().subtract(Duration(days: 3)),
                DateTime.now().subtract(Duration(days: 4)),
                DateTime.now().subtract(Duration(days: 5)),
                DateTime.now().subtract(Duration(days: 7)),
              ];

              return _buildFilterOption(
                days[index],
                () => _selectFilter(
                  FilterOptionModel(
                    label: days[index],
                    type: FilterType.day,
                    startDate: dates[index],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelection() {
    return Column(
      children: [
        Text(
          'Sélectionner un mois',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final months = [
                'Janvier 2025',
                'Février 2025',
                'Mars 2025',
                'Avril 2025',
                'Mai 2025',
                'Juin 2025',
                'Juillet 2025',
                'Août 2025',
                'Septembre 2025',
                'Octobre 2025',
                'Novembre 2025',
                'Décembre 2025',
              ];

              return _buildFilterOption(
                months[index],
                () => _selectFilter(
                  FilterOptionModel(
                    label: months[index],
                    type: FilterType.month,
                    startDate: DateTime(2025, index + 1, 1),
                    endDate: DateTime(2025, index + 2, 0),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearSelection() {
    return Column(
      children: [
        Text(
          'Sélectionner une année',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2,
            ),
            itemCount: 5,
            itemBuilder: (context, index) {
              final year = 2025 - index;
              return _buildFilterOption(
                '$year',
                () => _selectFilter(
                  FilterOptionModel(
                    label: '$year',
                    type: FilterType.year,
                    startDate: DateTime(year, 1, 1),
                    endDate: DateTime(year, 12, 31),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayRangeSelection() {
    return Column(
      children: [
        Text(
          'Sélectionner une période (jours)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                'Date de début',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDateSelector(
                'Date de fin',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        if (_startDate != null && _endDate != null)
          ElevatedButton(
            onPressed:
                () => _selectFilter(
                  FilterOptionModel(
                    label:
                        '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                    type: FilterType.dayRange,
                    startDate: _startDate,
                    endDate: _endDate,
                  ),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Appliquer'),
          ),
      ],
    );
  }

  Widget _buildMonthRangeSelection() {
    return Column(
      children: [
        Text(
          'Sélectionner une période (mois)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3,
            children: [
              _buildFilterOption(
                'Jan-Mar 2025',
                () => _selectFilter(
                  FilterOptionModel(
                    label: 'Jan-Mar 2025',
                    type: FilterType.monthRange,
                    startDate: DateTime(2025, 1, 1),
                    endDate: DateTime(2025, 3, 31),
                  ),
                ),
              ),
              _buildFilterOption(
                'Avr-Jun 2025',
                () => _selectFilter(
                  FilterOptionModel(
                    label: 'Avr-Jun 2025',
                    type: FilterType.monthRange,
                    startDate: DateTime(2025, 4, 1),
                    endDate: DateTime(2025, 6, 30),
                  ),
                ),
              ),
              _buildFilterOption(
                'Jul-Sep 2025',
                () => _selectFilter(
                  FilterOptionModel(
                    label: 'Jul-Sep 2025',
                    type: FilterType.monthRange,
                    startDate: DateTime(2025, 7, 1),
                    endDate: DateTime(2025, 9, 30),
                  ),
                ),
              ),
              _buildFilterOption(
                'Oct-Déc 2025',
                () => _selectFilter(
                  FilterOptionModel(
                    label: 'Oct-Déc 2025',
                    type: FilterType.monthRange,
                    startDate: DateTime(2025, 10, 1),
                    endDate: DateTime(2025, 12, 31),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYearRangeSelection() {
    return Column(
      children: [
        Text(
          'Sélectionner une période (années)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3,
            children: [
              _buildFilterOption(
                '2024-2025',
                () => _selectFilter(
                  FilterOptionModel(
                    label: '2024-2025',
                    type: FilterType.yearRange,
                    startDate: DateTime(2024, 1, 1),
                    endDate: DateTime(2025, 12, 31),
                  ),
                ),
              ),
              _buildFilterOption(
                '2023-2024',
                () => _selectFilter(
                  FilterOptionModel(
                    label: '2023-2024',
                    type: FilterType.yearRange,
                    startDate: DateTime(2023, 1, 1),
                    endDate: DateTime(2024, 12, 31),
                  ),
                ),
              ),
              _buildFilterOption(
                '2022-2023',
                () => _selectFilter(
                  FilterOptionModel(
                    label: '2022-2023',
                    type: FilterType.yearRange,
                    startDate: DateTime(2022, 1, 1),
                    endDate: DateTime(2023, 12, 31),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryLight.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? date,
    Function(DateTime) onSelected,
  ) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: AppColors.primaryLight),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onSelected(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.backgroundLightGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Sélectionner',
              style: TextStyle(
                fontSize: 14,
                color:
                    date != null
                        ? AppColors.textLight
                        : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectFilter(FilterOptionModel filter) {
    widget.onFilterSelected(filter);
    Navigator.pop(context);
  }
}
