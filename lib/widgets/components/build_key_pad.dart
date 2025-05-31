// import 'package:akiba/widgets/components/build_keypad_button.dart';
// import 'package:flutter/material.dart';

// Widget buildKeypad() {
//   return Column(
//     children: [
//       // Row 1: 1, 2, 3
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           buildKeypadButton(number: '1', onNumberPressed: (String number) {  }),
//           buildKeypadButton(number: '2'),
//           buildKeypadButton(number: '3'),
//         ],
//       ),
//       // const Gap(20),

//       // Row 2: 4, 5, 6
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildKeypadButton('4'),
//           _buildKeypadButton('5'),
//           _buildKeypadButton('6'),
//         ],
//       ),
//       // const Gap(20),

//       // Row 3: 7, 8, 9
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildKeypadButton('7'),
//           _buildKeypadButton('8'),
//           _buildKeypadButton('9'),
//         ],
//       ),
//       // const Gap(20),

//       // Row 4: empty, 0, backspace
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           const SizedBox(width: 70, height: 70), // Empty space
//           _buildKeypadButton('0'),
//           _buildBackspaceButton(),
//         ],
//       ),
//     ],
//   );
// }
