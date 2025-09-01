import 'package:akiba/enum/date_filter_type.dart';
import 'package:akiba/models/statistics_models/filter_option_model.dart';

String getBarBottomTitles({
  required int value,
  required FilterOptionModel currentFilter,
}) {
  switch (currentFilter.type) {
    case FilterType.day:
      const hours = ['4h', '8h', '12h', '16h', '20h', '24h'];
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
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[value];
  }
}
