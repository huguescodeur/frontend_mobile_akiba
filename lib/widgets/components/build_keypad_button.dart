import 'package:flutter/material.dart';

Widget buildKeypadButton({
  required String number,
  required Function(String number) onNumberPressed,
}) {
  return GestureDetector(
    onTap: () => onNumberPressed(number),
    child: Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
}
