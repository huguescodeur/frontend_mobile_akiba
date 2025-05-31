import 'package:akiba/enum/transition_direction.dart';
import 'package:flutter/material.dart';

void navigateWithTransition({
  required BuildContext context,
  required Widget page,
  TransitionDirection direction = TransitionDirection.rightToLeft,
  bool replace = false,
}) {
  Offset begin;

  switch (direction) {
    case TransitionDirection.leftToRight:
      begin = const Offset(-1.0, 0.0);
      break;
    case TransitionDirection.rightToLeft:
      begin = const Offset(1.0, 0.0);
      break;
    case TransitionDirection.topToBottom:
      begin = const Offset(0.0, -1.0);
      break;
    case TransitionDirection.bottomToTop:
      begin = const Offset(0.0, 1.0);
      break;
  }

  final route = PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: begin,
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );

  if (replace) {
    // Navigator.pushReplacement(context, route);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (Route route) => false,
    );
  } else {
    Navigator.push(context, route);
  }
}

// void navigateWithTransition({
//   required BuildContext context,
//   required Widget page,
//   TransitionDirection direction = TransitionDirection.rightToLeft,
// }) {
//   Offset begin;

//   switch (direction) {
//     case TransitionDirection.leftToRight:
//       begin = const Offset(-1.0, 0.0);
//       break;
//     case TransitionDirection.rightToLeft:
//       begin = const Offset(1.0, 0.0);
//       break;
//     case TransitionDirection.topToBottom:
//       begin = const Offset(0.0, -1.0);
//       break;
//     case TransitionDirection.bottomToTop:
//       begin = const Offset(0.0, 1.0);
//       break;
//   }

//   Navigator.push(
//     context,
//     PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         final tween = Tween(
//           begin: begin,
//           end: Offset.zero,
//         ).chain(CurveTween(curve: Curves.easeInOut));
//         final offsetAnimation = animation.drive(tween);
//         return SlideTransition(position: offsetAnimation, child: child);
//       },
//     ),
//   );
// }
