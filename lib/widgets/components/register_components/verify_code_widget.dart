import 'dart:developer';

import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

Pinput verifyCodeWidget(
  PinTheme defaultPinTheme,
  PinTheme focusedPinTheme,
  PinTheme submittedPinTheme,
  TextEditingController pinController,
  FocusNode focusNode,
  // Function() handleVerify,
) {
  return Pinput(
    controller: pinController,
    focusNode: focusNode,
    length: 6,
    defaultPinTheme: defaultPinTheme,
    focusedPinTheme: focusedPinTheme,
    submittedPinTheme: submittedPinTheme,
    showCursor: true,
    cursor: Container(width: 2, height: 24, color: AppColors.primaryLight),
    onCompleted: (pin) {
      log('Code completed: $pin');
      // handleVerify();
    },
    onChanged: (value) {
      log("Code Pin: $value");
    },
  );
}
