import 'package:flutter/material.dart';

Widget buildBackspaceButton({required Function() onBackspacePressed}) {
  return GestureDetector(
    onTap: onBackspacePressed,
    child: Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: const Center(
        child: Icon(Icons.backspace_outlined, size: 24, color: Colors.black),
      ),
    ),
  );
}
