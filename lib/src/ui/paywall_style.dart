import 'package:flutter/material.dart';

/// Configuration for the Paywall UI styling.
class PaywallStyle {
  final Color primaryColor;
  final Color backgroundColor;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final TextStyle featureTextStyle;
  final Color buttonColor;
  final TextStyle buttonTextStyle;
  final double cornerRadius;

  const PaywallStyle({
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.titleStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    this.descriptionStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black87,
    ),
    this.featureTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black54,
    ),
    this.buttonColor = Colors.blue,
    this.buttonTextStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    this.cornerRadius = 16.0,
  });
}
