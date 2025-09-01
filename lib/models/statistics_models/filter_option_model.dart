import 'package:akiba/enum/date_filter_type.dart';

class FilterOptionModel {
  final String label;
  final FilterType type;
  final DateTime? startDate;
  final DateTime? endDate;

  FilterOptionModel({
    required this.label,
    required this.type,
    this.startDate,
    this.endDate,
  });
}
