// import 'package:akiba/services/navigation_service/navigation_service.dart';
// import 'package:flutter/material.dart';

// mixin NavigationTrackingMixin<T extends StatefulWidget> on State<T> {
//   @override
//   void initState() {
//     super.initState();

//     // Enregistrer cette page dans la stack de navigation
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _trackCurrentPage();
//     });
//   }

//   void _trackCurrentPage() {
//     // Obtenir l'ID de la page courante
//     final pageId = _getPageId();
//     if (pageId != null) {
//       NavigationService.pushToStack(pageId);
//       print('📍 Page trackée: $pageId');
//     }
//   }

//   String? _getPageId() {
//     // Essayer de récupérer l'idView de la page
//     if (widget is dynamic && (widget as dynamic).idView != null) {
//       return (widget as dynamic).idView as String;
//     }

//     // Fallback sur le nom de la classe
//     return widget.runtimeType.toString().toLowerCase();
//   }
// }
