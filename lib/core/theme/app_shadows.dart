import 'package:flutter/material.dart';

/// Centralized subtle, modern elevation shadows for cards, bottom sheets, and floating bars.
abstract class AppShadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> yellowGlow = [
    BoxShadow(
      color: Color(0x40FFC107),
      blurRadius: 14,
      spreadRadius: 1,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cyanGlow = yellowGlow;
  static const List<BoxShadow> plumGlow = yellowGlow;

  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, -3),
    ),
  ];

  static const List<BoxShadow> darkSm = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> darkMd = [
    BoxShadow(
      color: Color(0x38000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> darkLg = [
    BoxShadow(
      color: Color(0x50000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}
